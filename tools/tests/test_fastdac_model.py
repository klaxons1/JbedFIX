"""Static FastDAC metadata checks; no PE or recovered method is executed."""

import os
from pathlib import Path
import struct
import unittest

from tools.jbed_java.fastdac_model import FastDacClass, FastDacImage
from tools.jbed_java.model import split_method_descriptor


class FastDacFormatTest(unittest.TestCase):
    def image(self, data):
        image = FastDacImage.__new__(FastDacImage)
        image.data = bytes(data)
        image.sections = [(0, 0, len(data))]
        image._names = {}
        return image

    def test_bucket_ids_extended_lengths_and_removed_names(self):
        data = bytearray(2048)
        struct.pack_into("<I", data, 4, 0)
        payload = b"\x03foo\xfe\x01\x04" + b"x" * 260 + b"\x00\xff"
        data[1024:1024 + len(payload)] = payload
        image = self.image(data)
        image.NAME_OFFSETS, image.NAME_DATA = 0, 1024
        self.assertEqual(image.name_bytes(0x101), b"foo")
        self.assertEqual(image.name_bytes(0x201), b"x" * 260)
        self.assertEqual(image.name_bytes(0x301), b"")
        self.assertIsNone(image.name_bytes(0x401))
        with self.assertRaises(ValueError):
            image.read(2040, 16)

    def test_signatures_use_resolved_class_ids_and_array_records(self):
        image = self.image(b"")
        image.class_ids = {
            0x270: FastDacClass("example/Value", 0, 0x270, 8, 0, 0, 1, "[Lexample/Value;"),
            0x4901: FastDacClass("example/Other", 0, 0x4901, 0, 0, 0, 0, "Lexample/Other;"),
        }
        records = {1: b"\x02I\x02\x70V", 2: b"\x00LI\x01", 3: b""}
        image.name_bytes = records.get
        self.assertEqual(image.signature(1), "(I[Lexample/Value;)V")
        self.assertEqual(image.signature(2), "()Lexample/Other;")
        self.assertIsNone(image.signature(3))

    def test_compact_method_header_sizes(self):
        data = bytearray(128)
        image = self.image(data)
        for flags, expected in ((0x80173, 56), (0x2E1913, 60), (0x60972, 56), (0, 60)):
            struct.pack_into("<I", data, 60, flags)
            image.data = bytes(data)
            self.assertEqual(image.method_header(64, 0), expected)


@unittest.skipUnless(os.environ.get("JBED_FASTDAC_IMAGE"), "set JBED_FASTDAC_IMAGE to the Xperia PE")
class XperiaMetadataTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.image = FastDacImage(Path(os.environ["JBED_FASTDAC_IMAGE"]))

    def test_method_chains_and_payload_kinds(self):
        image = self.image
        self.assertEqual(len(image.class_records), 1118)
        self.assertEqual(len(image.methods), 9104)
        self.assertEqual(sum(method.has_bytecode for method in image.methods), 7356)
        self.assertEqual(sum(len(method.code) for method in image.methods if method.has_bytecode), 348590)
        self.assertEqual(sum(method.is_native for method in image.methods), 747)
        self.assertEqual(sum(method.is_abstract for method in image.methods), 1001)

    def test_runtime_tables_reconstruct_members_and_constants(self):
        image = self.image
        target = image.direct_method(0x2090)
        self.assertEqual((target.owner, target.name, target.descriptor),
                         ("java/lang/Integer", "toString", "(II)Ljava/lang/String;"))
        self.assertEqual(image.virtual_method("Ljava/lang/Object;", 1).name, "equals")
        source = next(method for method in image.methods if method.pool_address == image.DEFAULT_POOL)
        interface_method = image.pool_method(source, 1162)
        self.assertEqual((interface_method.owner, interface_method.name, interface_method.descriptor),
                         ("javax/microedition/amms/control/EffectControl", "isEnabled", "()Z"))
        covered = {method.address for method in image.direct_methods.values()}
        self.assertTrue(all(method.address in covered for method in image.methods if not method.interface))
        fields = {field.name: field for field in image.classes["java/lang/Math"].fields}
        self.assertEqual(fields["E"].constant_bits, 0x4005BF0A8B145769)
        self.assertEqual(fields["PI"].constant_bits, 0x400921FB54442D18)
        self.assertEqual(sum(len(method.exception_regions) for method in image.methods), 2157)

    def test_private_layout_units_and_override_boundaries(self):
        image = self.image
        self.assertEqual(image.classes["java/lang/String"].instance_size, 12)
        field = image.field_at("Ljava/lang/String;", 8, kind="word")
        self.assertEqual((field.owner, field.offset, field.storage_kind), ("java/lang/String", 8, "word"))
        self.assertEqual(sum(method.name == "getClass" for method in image.methods), 1)
        self.assertEqual(sum(method.name == "wait" for method in image.methods), 3)
        self.assertTrue(all(method.flags & 0x1800 == 0x1000
                            for method in image.methods if method.name == "<init>"))

    def test_compact_call_shapes_agree_with_preserved_descriptors(self):
        for method in self.image.methods:
            if not method.descriptor:
                continue
            arguments, result = split_method_descriptor(method.descriptor)
            words = sum(2 if value in ("J", "D") else 1 for value in arguments) + (not method.is_static)
            self.assertEqual(method.parameter_words, words, method.name)
            kind = ("void" if result == "V" else "wide" if result in ("J", "D")
                    else "ref" if result.startswith(("L", "[")) else "word")
            self.assertEqual(method.return_kind, kind, method.name)


if __name__ == "__main__":
    unittest.main()
