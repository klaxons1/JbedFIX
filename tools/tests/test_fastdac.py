"""FastDAC opcode and private-member type reconstruction checks."""

from __future__ import annotations

import unittest
from types import SimpleNamespace

from tools.jbed_java.fastdac import ReverseQuickener, UnsupportedFastDac, decode


def method(name, descriptor, code, *, owner="Sample", static=True):
    return SimpleNamespace(name=name, descriptor=descriptor, code=bytes.fromhex(code),
                           owner=owner, is_static=static, max_locals=8,
                           exception_regions=(), is_synchronized=False)


class FastDacTest(unittest.TestCase):
    def test_compact_reference_comparison(self):
        # Object.equals at 0x14ba48 uses the same E3 word comparison as integers.
        body = ReverseQuickener(SimpleNamespace()).compile(method(
            "equals", "(Ljava/lang/Object;)Z", "2a2be30404ac03ac", static=False))
        self.assertEqual(body.bytecode[:3], bytes.fromhex("2a2ba5"))
        self.assertEqual(body.max_stack, 2)

    def test_compact_signed_switch(self):
        code = "1ac4ab0a02ff08070a04ac03ac"
        instructions = decode(bytes.fromhex(code))
        self.assertEqual(instructions[1].operands, (11, ((-1, 9), (7, 11))))
        body = ReverseQuickener(SimpleNamespace()).compile(method("select", "(I)I", code))
        self.assertEqual(body.bytecode[1], 0xab)
        self.assertEqual(body.max_stack, 1)

    def test_private_field_type_from_return(self):
        member = SimpleNamespace(owner="Sample", name="$romField0", descriptor=None,
                                 offset=0, is_static=False, flags=0, address=0,
                                 storage_kind="word", initializer_error=None)
        image = SimpleNamespace(field_at=lambda *_args, **_kwargs: member)
        quickener = ReverseQuickener(image)
        body = quickener.compile(method("value", "()I", "d800ac", static=False))
        self.assertEqual(member.descriptor, "I")
        self.assertEqual(body.bytecode[0:2], b"\x2a\xb4")
        self.assertEqual(body.bytecode[-1], 0xac)
        self.assertIn((9, "Sample", "$romField0", "I"), quickener.pool.indices)

    def test_private_call_parameter_contract(self):
        target = SimpleNamespace(owner="Sample", name="$romMethod100", descriptor=None,
                                 address=0x100, is_static=True, parameter_words=1,
                                 return_kind="void")
        image = SimpleNamespace(direct_method=lambda _index: target)
        body = ReverseQuickener(image).compile(method("call", "(I)V", "1adb0000b1"))
        self.assertEqual(target.descriptor, "(I)V")
        self.assertEqual(body.bytecode[1], 0xb8)

    def test_branch_must_land_on_instruction(self):
        with self.assertRaisesRegex(UnsupportedFastDac, "instruction boundaries"):
            decode(bytes.fromhex("e801b1"))


if __name__ == "__main__":
    unittest.main()
