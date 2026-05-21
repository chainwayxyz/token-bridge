#!/usr/bin/env python3
"""Unit tests for foundry_to_safe_batch.py.

Run from anywhere:
    python3 -m unittest scripts.test_foundry_to_safe_batch
Or from the scripts/ directory:
    python3 -m unittest test_foundry_to_safe_batch
"""

import json
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import foundry_to_safe_batch as m  # noqa: E402

ADDR = "0x1a44076050125825900e736c501f859c50fe728c"
CHECKSUM_ADDR = "0x1a44076050125825900e736c501f859c50fE728c"


def _call(to=ADDR, value="0x0", input_="0x", tx_type="CALL", **inner):
    """Build a minimal newer-Foundry transaction entry (nested layout)."""
    transaction = {"to": to, "value": value, "input": input_}
    transaction.update(inner)
    return {"transactionType": tx_type, "transaction": transaction}


class TestParseValue(unittest.TestCase):
    def test_value_forms(self):
        cases = {
            "0x0": "0",
            "0": "0",
            0: "0",
            None: "0",
            "": "0",
            "0xde0b6b3a7640000": "1000000000000000000",  # 1 ether in hex
            1000: "1000",
            "1000": "1000",
        }
        for raw, expected in cases.items():
            with self.subTest(raw=raw):
                self.assertEqual(m.parse_value_to_decimal_string(raw), expected)

    def test_bool_is_rejected(self):
        with self.assertRaises(m.ConversionError):
            m.parse_value_to_decimal_string(True)

    def test_garbage_string_is_rejected(self):
        with self.assertRaises(m.ConversionError):
            m.parse_value_to_decimal_string("not-a-number")


class TestAddressValidation(unittest.TestCase):
    def test_valid_lower_and_mixed_case(self):
        self.assertTrue(m.is_valid_evm_address(ADDR))
        self.assertTrue(m.is_valid_evm_address(CHECKSUM_ADDR))

    def test_invalid(self):
        for bad in ["0x123", "1a44076050125825900e736c501f859c50fe728c", "", None, 42]:
            with self.subTest(bad=bad):
                self.assertFalse(m.is_valid_evm_address(bad))


class TestHexData(unittest.TestCase):
    def test_valid(self):
        self.assertTrue(m.is_valid_hex_data("0x"))        # empty calldata
        self.assertTrue(m.is_valid_hex_data("0xabcd"))

    def test_invalid(self):
        for bad in ["0xabc", "abcd", "0xZZ", None]:        # odd length / no prefix
            with self.subTest(bad=bad):
                self.assertFalse(m.is_valid_hex_data(bad))


class TestDataExtraction(unittest.TestCase):
    def test_prefers_data_over_input(self):
        tx = {"transaction": {"data": "0xaa", "input": "0xbb"}}
        self.assertEqual(m.get_tx_data(tx), "0xaa")

    def test_falls_back_to_input(self):
        tx = {"transaction": {"input": "0xbb"}}
        self.assertEqual(m.get_tx_data(tx), "0xbb")

    def test_both_missing_defaults_to_0x(self):
        self.assertEqual(m.get_tx_data({"transaction": {}}), "0x")

    def test_missing_nested_transaction_is_fatal(self):
        with self.assertRaises(m.ConversionError):
            m.get_tx_data({"to": ADDR})


class TestSkipDeployments(unittest.TestCase):
    def test_skip_create(self):
        safe_tx, reason = m.convert_foundry_tx_to_safe_tx(
            _call(to=None, tx_type="CREATE"), 0
        )
        self.assertIsNone(safe_tx)
        self.assertIn("CREATE", reason)

    def test_skip_create2(self):
        safe_tx, reason = m.convert_foundry_tx_to_safe_tx(
            _call(to=None, tx_type="CREATE2"), 0
        )
        self.assertIsNone(safe_tx)
        self.assertIn("CREATE2", reason)

    def test_skip_missing_to_on_call(self):
        safe_tx, reason = m.convert_foundry_tx_to_safe_tx(_call(to=None), 0)
        self.assertIsNone(safe_tx)
        self.assertIn("to", reason)


class TestConvertNormalCall(unittest.TestCase):
    def test_convert_basic_call(self):
        safe_tx, reason = m.convert_foundry_tx_to_safe_tx(
            _call(value="0x0", input_="0xabcdef"), 0
        )
        self.assertIsNone(reason)
        self.assertEqual(
            safe_tx,
            {
                "to": ADDR,
                "value": "0",
                "data": "0xabcdef",
                "contractMethod": None,
                "contractInputsValues": None,
            },
        )

    def test_preserves_mixed_case_address(self):
        safe_tx, _ = m.convert_foundry_tx_to_safe_tx(_call(to=CHECKSUM_ADDR), 0)
        self.assertEqual(safe_tx["to"], CHECKSUM_ADDR)

    def test_empty_calldata_is_allowed(self):
        safe_tx, reason = m.convert_foundry_tx_to_safe_tx(_call(input_="0x"), 0)
        self.assertIsNone(reason)
        self.assertEqual(safe_tx["data"], "0x")

    def test_invalid_to_on_call_is_fatal(self):
        with self.assertRaises(m.ConversionError):
            m.convert_foundry_tx_to_safe_tx(_call(to="0xnotanaddress"), 0)


class TestBatchAndLoad(unittest.TestCase):
    def test_chain_id_int_or_str_becomes_string(self):
        broadcast = {"transactions": []}
        for chain_id in (1, "1"):
            with self.subTest(chain_id=chain_id):
                batch = m.convert_broadcast_to_safe_batch(broadcast, ADDR, chain_id)
                self.assertEqual(batch["chainId"], "1")

    def test_batch_skips_deploys_and_keeps_calls(self):
        broadcast = {
            "transactions": [
                _call(to=None, tx_type="CREATE"),
                _call(value="0", input_="0x11223344"),
            ]
        }
        batch = m.convert_broadcast_to_safe_batch(broadcast, ADDR, 1)
        self.assertEqual(len(batch["transactions"]), 1)
        self.assertEqual(batch["transactions"][0]["data"], "0x11223344")

    def test_load_rejects_missing_or_non_list_transactions(self):
        for payload in ("{}", '{"transactions": 123}', '{"transactions": null}'):
            with self.subTest(payload=payload):
                with tempfile.NamedTemporaryFile(
                    "w", suffix=".json", delete=False
                ) as f:
                    f.write(payload)
                    path = f.name
                try:
                    with self.assertRaises(m.ConversionError):
                        m.load_foundry_broadcast(path)
                finally:
                    os.remove(path)

    def test_load_rejects_missing_file(self):
        with self.assertRaises(m.ConversionError):
            m.load_foundry_broadcast("/tmp/does-not-exist-foundry-safe.json")

    def test_load_valid_roundtrip(self):
        broadcast = {"transactions": [_call(input_="0xdeadbeef")]}
        with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as f:
            json.dump(broadcast, f)
            path = f.name
        try:
            loaded = m.load_foundry_broadcast(path)
            self.assertEqual(len(loaded["transactions"]), 1)
        finally:
            os.remove(path)


if __name__ == "__main__":
    unittest.main()
