#!/usr/bin/env python3
"""Convert a Foundry `forge script` broadcast artifact into a Safe
Transaction Builder JSON batch.

This tool ONLY produces a JSON file for review and manual import into the
Safe{Wallet} Transaction Builder. It never uses private keys, never signs,
and never broadcasts anything to a chain.

Usage:
  python3 scripts/foundry_to_safe_batch.py \
    --input broadcast/MyScript.s.sol/1/run-latest.json \
    --output safe-batch.json \
    --safe 0xYourSafeAddress \
    --chain-id 1 \
    --name "Bridge ownership handover"

Input might be under `broadcast/**/**/dry-run/` if --broadcast was not used.

See the usage notes in this repo's README for the full workflow.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time

# Safe Transaction Builder format constants.
SAFE_BATCH_VERSION = "1.0"
TX_BUILDER_VERSION = "1.18.0"
DEFAULT_BATCH_NAME = "Foundry generated Safe batch"

# Foundry transactionType values that represent contract deployments
# (CREATE / CREATE2). These have no `to` address and cannot be expressed as a
# Safe Transaction Builder call, so they are skipped.
DEPLOYMENT_TX_TYPES = {"CREATE", "CREATE2"}

_EVM_ADDRESS_RE = re.compile(r"^0x[0-9a-fA-F]{40}$")
# Even number of hex nibbles after the 0x prefix ("0x" alone is allowed).
_HEX_DATA_RE = re.compile(r"^0x([0-9a-fA-F]{2})*$")


class ConversionError(Exception):
    """Raised for fatal, user-facing conversion problems."""


# ---------------------------------------------------------------------------
# Pure / testable helpers
# ---------------------------------------------------------------------------
def load_foundry_broadcast(path: str) -> dict:
    """Load and minimally validate a Foundry broadcast artifact.

    Returns the parsed JSON object. Raises ConversionError if the file is
    missing, not valid JSON, or does not contain a top-level `transactions`
    array.
    """
    if not os.path.isfile(path):
        raise ConversionError(f"input file does not exist: {path}")

    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except json.JSONDecodeError as exc:
        raise ConversionError(f"input file is not valid JSON ({path}): {exc}") from exc
    except OSError as exc:
        raise ConversionError(f"could not read input file ({path}): {exc}") from exc

    if not isinstance(data, dict):
        raise ConversionError(
            f"unexpected broadcast format: top-level JSON is "
            f"{type(data).__name__}, expected an object"
        )
    if not isinstance(data.get("transactions"), list):
        raise ConversionError(
            "unexpected broadcast format: missing top-level `transactions` array"
        )
    return data


def is_valid_evm_address(value: str) -> bool:
    """True if `value` is a 0x-prefixed 20-byte hex address."""
    return isinstance(value, str) and bool(_EVM_ADDRESS_RE.match(value.strip()))


def is_valid_hex_data(value: str) -> bool:
    """True if `value` is 0x-prefixed, even-length hex (calldata)."""
    return isinstance(value, str) and bool(_HEX_DATA_RE.match(value.strip()))


def parse_value_to_decimal_string(value) -> str:
    """Normalize a wei `value` (hex string, decimal string, int, None or
    missing) into a decimal string. Always returns a string; defaults to "0".
    """
    if value is None:
        return "0"
    # bool is a subclass of int; reject it explicitly to avoid True -> "1".
    if isinstance(value, bool):
        raise ConversionError(f"invalid `value`: expected a number, got {value!r}")
    if isinstance(value, int):
        return str(value)
    if isinstance(value, str):
        s = value.strip()
        if s == "":
            return "0"
        try:
            if s.lower().startswith("0x"):
                return str(int(s, 16))
            return str(int(s, 10))
        except ValueError as exc:
            raise ConversionError(f"could not parse `value` {value!r}: {exc}") from exc
    raise ConversionError(f"unsupported `value` type {type(value).__name__}: {value!r}")


def _inner_tx(tx: dict) -> dict:
    """Return the nested `transaction` sub-object that holds `to`/`value`/
    `input`/`data`. Modern Foundry (forge-std) always nests these fields here;
    only this layout is supported.
    """
    inner = tx.get("transaction")
    if not isinstance(inner, dict):
        raise ConversionError(
            "transaction entry is missing the nested `transaction` object "
            "(unsupported Foundry broadcast format)"
        )
    return inner


def get_tx_data(tx: dict) -> str:
    """Resolve calldata for a tx: prefer `data`, fall back to `input`, then
    default to "0x". Reads from the nested `transaction` sub-object.
    """
    inner = _inner_tx(tx)
    data = inner.get("data")
    if isinstance(data, str) and data.strip():
        return data.strip()
    inp = inner.get("input")
    if isinstance(inp, str) and inp.strip():
        return inp.strip()
    return "0x"


def _first_str(value):
    """Return value as-is if it's a string, else None. Guards against
    unexpected types in optional metadata fields."""
    return value if isinstance(value, str) else None


def convert_foundry_tx_to_safe_tx(tx: dict, index: int):
    """Convert one Foundry transaction entry into a Safe Transaction Builder
    transaction object.

    Returns a tuple ``(safe_tx, reason)``:
      * ``(dict, None)``  -> include this transaction
      * ``(None, str)``   -> skip this transaction (reason is the explanation)

    Raises ConversionError for transactions that should be included but fail
    validation (bad address / bad calldata) -- these are fatal, not skips.
    """
    tx_type = (_first_str(tx.get("transactionType")) or "").upper()
    inner = _inner_tx(tx)
    to = inner.get("to")

    # Deployments (CREATE/CREATE2) have no `to` and cannot be a Safe call.
    if tx_type in DEPLOYMENT_TX_TYPES:
        return None, f"deployment transaction (transactionType={tx_type})"

    if to is None or (isinstance(to, str) and to.strip() == ""):
        return None, "no `to` address (looks like a contract deployment)"

    if not isinstance(to, str):
        raise ConversionError(
            f"transaction #{index}: `to` is not a string: {to!r}"
        )
    to = to.strip()
    if not is_valid_evm_address(to):
        raise ConversionError(
            f"transaction #{index}: invalid `to` address: {to!r}"
        )

    data = get_tx_data(tx)
    if not is_valid_hex_data(data):
        raise ConversionError(
            f"transaction #{index}: invalid `data` "
            f"(must be 0x-prefixed, even-length hex): {data!r}"
        )

    value = parse_value_to_decimal_string(inner.get("value"))

    safe_tx = {
        "to": to,
        "value": value,
        "data": data,
        "contractMethod": None,
        "contractInputsValues": None,
    }
    return safe_tx, None


def process_transactions(transactions: list):
    """Split Foundry transactions into included / skipped buckets.

    Returns ``(included, skipped)`` where:
      * included: list of dicts {index, safe_tx, function}
      * skipped:  list of dicts {index, reason, transactionType, contractName}

    Does no printing; raises ConversionError on fatal validation errors.
    """
    included = []
    skipped = []
    for index, tx in enumerate(transactions):
        if not isinstance(tx, dict):
            raise ConversionError(
                f"transaction #{index}: expected an object, got {type(tx).__name__}"
            )
        safe_tx, reason = convert_foundry_tx_to_safe_tx(tx, index)
        if safe_tx is None:
            skipped.append(
                {
                    "index": index,
                    "reason": reason,
                    "transactionType": _first_str(tx.get("transactionType")),
                    "contractName": _first_str(tx.get("contractName")),
                }
            )
        else:
            included.append(
                {
                    "index": index,
                    "safe_tx": safe_tx,
                    "function": _first_str(tx.get("function")),
                }
            )
    return included, skipped


def convert_broadcast_to_safe_batch(
    broadcast: dict,
    safe_address: str,
    chain_id: str,
    name: str | None = None,
    created_at: int | None = None,
) -> dict:
    """Build the full Safe Transaction Builder batch object from a parsed
    Foundry broadcast artifact. Skips deployment transactions here -- callers
    should surface the skip warnings via process_transactions().
    """
    included, _skipped = process_transactions(broadcast.get("transactions", []))
    if created_at is None:
        created_at = int(time.time() * 1000)

    return {
        "version": SAFE_BATCH_VERSION,
        "chainId": str(chain_id),
        "createdAt": created_at,
        "meta": {
            "name": name or DEFAULT_BATCH_NAME,
            "description": "",
            "txBuilderVersion": TX_BUILDER_VERSION,
            "createdFromSafeAddress": safe_address,
        },
        "transactions": [entry["safe_tx"] for entry in included],
    }


def write_safe_batch(path: str, batch: dict) -> None:
    """Write the Safe batch JSON to `path`, pretty-printed."""
    try:
        with open(path, "w", encoding="utf-8") as f:
            json.dump(batch, f, indent=2)
            f.write("\n")
    except OSError as exc:
        raise ConversionError(f"could not write output file ({path}): {exc}") from exc


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
def _data_byte_len(data: str) -> int:
    """Length of 0x-prefixed calldata in bytes."""
    body = data[2:] if data.lower().startswith("0x") else data
    return len(body) // 2


def print_warnings(skipped: list) -> None:
    """Print a warning per skipped transaction. Never silently drops."""
    for s in skipped:
        bits = [f"index={s['index']}"]
        if s["transactionType"]:
            bits.append(f"transactionType={s['transactionType']}")
        if s["contractName"]:
            bits.append(f"contractName={s['contractName']}")
        bits.append(f"reason={s['reason']}")
        print("WARNING: skipped transaction (" + ", ".join(bits) + ")", file=sys.stderr)


def print_dry_run_summary(total: int, included: list, skipped: list) -> None:
    print("=== DRY RUN: no file written ===")
    print(f"Foundry transactions read: {total}")
    print(f"  included: {len(included)}")
    print(f"  skipped:  {len(skipped)}")

    if included:
        print("\nIncluded transactions:")
        for entry in included:
            tx = entry["safe_tx"]
            line = (
                f"  [{entry['index']}] to={tx['to']} "
                f"value={tx['value']} dataBytes={_data_byte_len(tx['data'])}"
            )
            if entry["function"]:
                line += f" fn={entry['function']}"
            print(line)

    if skipped:
        print("\nSkipped transactions:")
        for s in skipped:
            line = f"  [{s['index']}] reason={s['reason']}"
            if s["transactionType"]:
                line += f" transactionType={s['transactionType']}"
            if s["contractName"]:
                line += f" contractName={s['contractName']}"
            print(line)


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="foundry_to_safe_batch.py",
        description=(
            "Convert a Foundry forge-script broadcast artifact into a Safe "
            "Transaction Builder JSON batch. Only normal calls to existing "
            "contracts are converted; deployments (CREATE/CREATE2) are skipped."
        ),
    )
    parser.add_argument(
        "-i", "--input", required=True,
        help="Path to the Foundry broadcast JSON (e.g. broadcast/My.s.sol/1/run-latest.json)",
    )
    parser.add_argument(
        "-o", "--output", required=True,
        help="Path to write the Safe Transaction Builder JSON batch",
    )
    parser.add_argument(
        "-s", "--safe", required=True,
        help="Safe multisig address (createdFromSafeAddress)",
    )
    parser.add_argument(
        "-c", "--chain-id", required=True,
        help="Chain ID of the target network (numeric)",
    )
    parser.add_argument(
        "-n", "--name", default=None,
        help='Optional batch name (default: "%s")' % DEFAULT_BATCH_NAME,
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Print a summary instead of writing the output file",
    )
    return parser


def main(argv: list | None = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)

    # ---- validate CLI inputs -------------------------------------------
    if not is_valid_evm_address(args.safe):
        print(f"ERROR: invalid Safe address: {args.safe!r}", file=sys.stderr)
        return 2

    chain_id = str(args.chain_id).strip()
    if not chain_id.isdigit():
        print(f"ERROR: chain id must be numeric, got: {args.chain_id!r}", file=sys.stderr)
        return 2

    safe_address = args.safe.strip()

    try:
        broadcast = load_foundry_broadcast(args.input)
        transactions = broadcast.get("transactions", [])
        included, skipped = process_transactions(transactions)

        # Always surface skips -- never silently drop anything.
        print_warnings(skipped)

        if not included:
            print(
                "WARNING: no convertible transactions found "
                "(all entries were deployments or skipped).",
                file=sys.stderr,
            )

        batch = convert_broadcast_to_safe_batch(
            broadcast, safe_address, chain_id, args.name
        )

        if args.dry_run:
            print_dry_run_summary(len(transactions), included, skipped)
            return 0

        write_safe_batch(args.output, batch)
        print(
            f"Wrote {len(included)} transaction(s) to {args.output} "
            f"({len(skipped)} skipped). Import this file into the Safe "
            f"Transaction Builder for review and signing."
        )
        return 0

    except ConversionError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
