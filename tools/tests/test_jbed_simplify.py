"""Type and evaluation-order invariants for the lifted expression cleanup."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from tools.jbed_java.simplify import _Parser, _pure, _render, _rewrite, _type, simplify
from tools.jbed_java.structure import Block, LiftedCFG, Return, Switch


class ExpressionCleanupTest(unittest.TestCase):
    def expression(self, text, types=None):
        types = types or {}
        return _rewrite(_Parser(text, types).parse(), {}, types)

    def test_unknown_call_keeps_required_narrowing_cast(self):
        expression = self.expression("(int) (Double.doubleToRawLongBits(p0) >>> 32)", {"p0": "double"})
        self.assertEqual((expression.kind, expression.value), ("cast", "int"))
        self.assertIsNone(_type(expression.children[0], {"p0": "double"}))

    def test_local_widening_survives_copy_propagation(self):
        cfg = LiftedCFG(0, {0: Block(0, ("wide = p0;",), Return("wide + wide"))}, {"wide": "long"})
        result = simplify(cfg, {"p0": "int"})
        expression = _Parser(result.blocks[0].terminator.value, {"p0": "int"}).parse()
        self.assertEqual(_type(expression, {"p0": "int"}), "long")
        self.assertEqual(tuple(child.value for child in expression.children), ("long", "long"))

    def test_sign_extension_preserves_int_expression_type(self):
        expression = self.expression("(p0 << 24) >> 24", {"p0": "int"})
        self.assertEqual(_type(expression, {"p0": "int"}), "int")
        self.assertEqual(expression.children[0].value, "byte")

    def test_signed_hex_literal_comparison(self):
        self.assertEqual(_render(self.expression("0xffffffff < 0")), "true")
        self.assertEqual(_render(self.expression("0xffffffffL < 0")), "false")

    def test_array_read_stays_before_mutation(self):
        cfg = LiftedCFG(0, {0: Block(0, ("saved = p0[0];", "p0[0] = 9;"), Return("saved"))}, {"saved": "int"})
        result = simplify(cfg, {"p0": "int[]"})
        self.assertEqual(result.blocks[0].statements, ("saved = p0[0];", "p0[0] = 9;"))

    def test_unused_array_read_still_throws(self):
        cfg = LiftedCFG(0, {0: Block(0, ("unused = p0[0];",), Return("1"))}, {"unused": "int"})
        self.assertEqual(simplify(cfg, {"p0": "int[]"}).blocks[0].statements, ("unused = p0[0];",))

    def test_member_name_is_not_a_local_substitution(self):
        cfg = LiftedCFG(0, {0: Block(0, ("value = p0;", "object.value = value;"), Return())}, {"value": "int"})
        result = simplify(cfg, {"p0": "int", "object": "Example"})
        self.assertEqual(result.blocks[0].statements, ("object.value = p0;",))
        self.assertEqual(self.expression("(Example.value) + 1").children[0].kind, "member")

    def test_array_creation_and_instanceof_ast(self):
        array = self.expression("new int[p0][]", {"p0": "int"})
        self.assertEqual((array.kind, array.value, _type(array, {})), ("new_array", "int[]", "int[][]"))
        self.assertEqual(_render(array), "new int[p0][]")
        check = self.expression("p0 instanceof java.lang.String[]", {"p0": "Object"})
        self.assertEqual((check.kind, check.value, _type(check, {})), ("instanceof", "java.lang.String[]", "boolean"))
        self.assertFalse(_pure(array, {"p0": "int"}))

    def test_switch_keeps_selector_and_successors(self):
        cfg = LiftedCFG(0, {
            0: Block(0, ("selector = p0;",), Switch("selector", ((7, 1),), 2)),
            1: Block(1, (), Return("1")),
            2: Block(2, (), Return("0")),
        }, {"selector": "int"})
        result = simplify(cfg, {"p0": "int"})
        self.assertEqual(result.blocks[0].terminator, Switch("p0", ((7, 1),), 2))
        self.assertEqual(set(result.blocks), {0, 1, 2})
        self.assertEqual(result.locals, {})

    def test_repeated_values_do_not_expand_exponentially(self):
        assignments = ("v0 = p0;",) + tuple(f"v{i} = v{i - 1} + v{i - 1};" for i in range(1, 80))
        cfg = LiftedCFG(0, {0: Block(0, assignments, Return("v79"))},
                        {f"v{i}": "int" for i in range(80)})
        result = simplify(cfg, {"p0": "int"})
        # Large shared values remain named locals instead of recursively
        # duplicating the expression every time the value is consumed.
        self.assertTrue(result.blocks[0].statements)
        self.assertLess(sum(map(len, result.blocks[0].statements)), 20000)


if __name__ == "__main__":
    unittest.main()
