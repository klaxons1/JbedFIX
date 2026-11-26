"""Tests for the syscall adapter itself, using tiny ARM ELFs (no compiler)."""
import contextlib
import importlib.util
import io
from pathlib import Path
import struct
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('arm_unicorn', Path(__file__).resolve().parents[1] / 'run-arm-unicorn.py')
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)


class UnicornAdapterTest(unittest.TestCase):
    def run_arm(self, words, **kwargs):
        code = struct.pack('<' + 'I' * len(words), *words)
        base, offset = 0x10000, 84
        ident = b'\x7fELF\x01\x01\x01' + bytes(9)
        header = ident + struct.pack('<HHIIIIIHHHHHH', 2, 40, 1, base + offset, 52, 0,
                                     0x5000200, 52, 32, 1, 40, 0, 0)
        segment = struct.pack('<IIIIIIII', 1, 0, base, base, offset + len(code),
                              offset + len(code), 5, 4096)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'test.elf'
            path.write_bytes(header + segment + code)
            with contextlib.redirect_stdout(io.StringIO()):
                return runner.execute(path, [], seconds=2, **kwargs)

    def test_guest_exit_status_is_preserved(self):
        report = self.run_arm([0xe3a0002a, 0xe3a07001, 0xef000000])
        self.assertEqual(report['exit_status'], 42)
        self.assertIsNone(report['failure'])

    def test_unsupported_syscall_is_failure_not_success(self):
        report = self.run_arm([0xe3a07063, 0xef000000])
        self.assertIsNone(report['exit_status'])
        self.assertIn('Unsupported Linux ARM syscall 99', report['failure'])

    def test_unmapped_access_is_failure(self):
        report = self.run_arm([0xe3a00000, 0xe5800000])
        self.assertIsNone(report['exit_status'])
        self.assertIn('Invalid memory access', report['failure'])

    def test_elf_readonly_code_is_not_writable(self):
        # sub r1, pc, #8; str r0, [r1] -- overwrite this RX code page.
        report = self.run_arm([0xe24f1008, 0xe5810000])
        self.assertIsNone(report['exit_status'])
        self.assertIn('WRITE_PROT', report['failure'])

    def test_instruction_limit_is_not_a_pass(self):
        report = self.run_arm([0xeafffffe], instructions=100)
        self.assertIsNone(report['exit_status'])
        self.assertIn('budget exhausted', report['failure'])


if __name__ == '__main__':
    unittest.main()
