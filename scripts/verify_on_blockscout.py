#!/usr/bin/env python3
"""
Pulls a verified contract's source from Etherscan and re-verifies it on a Blockscout instance.

Usage:
  python3 scripts/verify_on_blockscout.py \
    --src-address 0x1a44076050125825900e736c501f859c50fE728c \
    --dest-address 0x6F475642a6e85809B1c36Fa62763669b1b48DD5B \
    --etherscan-api-key <KEY> \
    --blockscout-url https://explorer.mainnet.citrea.xyz/api?
"""

import argparse
import json
import sys
import time
import urllib.request
import urllib.parse


def fetch_etherscan(address: str, api_key: str) -> dict:
    url = (
        "https://api.etherscan.io/v2/api"
        f"?chainid=1&module=contract&action=getsourcecode"
        f"&address={address}&apikey={api_key}"
    )
    print(f"[*] Fetching source from Etherscan: {url}")
    with urllib.request.urlopen(url) as r:
        data = json.loads(r.read())

    if data["status"] != "1":
        raise RuntimeError(f"Etherscan error: {data.get('result') or data.get('message')}")

    result = data["result"][0]
    return result


def submit_to_blockscout(dest_address: str, blockscout_url: str, etherscan_result: dict) -> str:
    r = etherscan_result

    source_code = r["SourceCode"]
    # Etherscan wraps standard JSON in an extra pair of braces: {{...}}
    if source_code.startswith("{{"):
        source_code = source_code[1:-1]

    compiler_version = r["CompilerVersion"]
    contract_name = r["ContractName"]
    constructor_args = r.get("ConstructorArguments", "")
    optimization_used = r.get("OptimizationUsed", "0")
    runs = r.get("Runs", "200")

    # Determine if it's standard JSON or plain Solidity
    try:
        json.loads(source_code)
        code_format = "solidity-standard-json-input"
        print("[*] Source format: Standard JSON Input")
    except json.JSONDecodeError:
        code_format = "solidity-single-file"
        print("[*] Source format: Single file (flattened)")

    payload = {
        "module": "contract",
        "action": "verifysourcecode",
        "contractaddress": dest_address,
        "sourceCode": source_code,
        "codeformat": code_format,
        "contractname": contract_name,
        "compilerversion": compiler_version,
        "optimizationUsed": optimization_used,
        "runs": runs,
        "constructorArguments": constructor_args,
        "evmversion": r.get("EVMVersion", ""),
        "licenseType": r.get("LicenseType", ""),
    }

    print(f"[*] Contract name  : {contract_name}")
    print(f"[*] Compiler       : {compiler_version}")
    print(f"[*] Optimization   : {optimization_used} (runs={runs})")
    print(f"[*] Constructor    : {constructor_args or '(none)'}")

    encoded = urllib.parse.urlencode(payload).encode()
    req = urllib.request.Request(blockscout_url, data=encoded, method="POST")
    req.add_header("Content-Type", "application/x-www-form-urlencoded")
    req.add_header("User-Agent", "curl/8.7.1")

    print(f"\n[*] Submitting to Blockscout: {blockscout_url}")
    with urllib.request.urlopen(req) as resp:
        response = json.loads(resp.read())

    print(f"[*] Response: {json.dumps(response, indent=2)}")

    if response.get("status") == "1":
        return response["result"]  # GUID for polling
    else:
        raise RuntimeError(f"Blockscout submission failed: {response}")


def poll_blockscout(guid: str, blockscout_url: str, max_wait: int = 120) -> None:
    payload = {
        "module": "contract",
        "action": "checkverifystatus",
        "guid": guid,
    }
    encoded = urllib.parse.urlencode(payload).encode()
    deadline = time.time() + max_wait

    print(f"\n[*] Polling verification status (guid={guid}) ...")
    while time.time() < deadline:
        req = urllib.request.Request(blockscout_url, data=encoded, method="POST")
        req.add_header("Content-Type", "application/x-www-form-urlencoded")
        req.add_header("User-Agent", "curl/8.7.1")
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read())

        result = data.get("result", "")
        print(f"    status: {result}")

        if "Pass" in result or "Already" in result or "successfully" in result.lower():
            print("[+] Contract verified successfully!")
            return
        if "Fail" in result or "fail" in result or "error" in result.lower():
            raise RuntimeError(f"Verification failed: {result}")

        time.sleep(5)

    print("[!] Timed out waiting for verification. Check the explorer manually.")


def main():
    parser = argparse.ArgumentParser(description="Verify a contract on Blockscout using Etherscan source")
    parser.add_argument("--src-address", default="0x1a44076050125825900e736c501f859c50fE728c",
                        help="Address of the verified contract on Etherscan")
    parser.add_argument("--dest-address", default="0x6F475642a6e85809B1c36Fa62763669b1b48DD5B",
                        help="Address to verify on Blockscout")
    parser.add_argument("--etherscan-api-key", default="", help="Etherscan API key")
    parser.add_argument("--blockscout-url", default="https://explorer.mainnet.citrea.xyz/api",
                        help="Blockscout base API URL (no trailing ?)")
    args = parser.parse_args()

    etherscan_result = fetch_etherscan(args.src_address, args.etherscan_api_key)
    guid = submit_to_blockscout(args.dest_address, args.blockscout_url, etherscan_result)
    poll_blockscout(guid, args.blockscout_url)


if __name__ == "__main__":
    main()
