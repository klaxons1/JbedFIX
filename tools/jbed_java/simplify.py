"""Conservative expression and dataflow cleanup for lifted Java CFGs.

Only expressions with no side effects or exceptions are propagated. Java
field/array reads, calls, allocation, and potentially failing casts remain at
their original evaluation point. Substitution operates on parsed expressions,
never on textual matches inside member names, types, or string literals.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass, replace
from functools import cached_property
import re
from typing import Mapping

from .structure import Block, Branch, Jump, LiftedCFG, Return, Switch, Throw
from .wide import bit_conversion, fold_word_transport


_TOKEN = re.compile(r'''\s*(?:(0[xX][0-9a-fA-F]+[lL]?|\d+[lL]?)|([A-Za-z_$][\w$]*)|("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')|(>>>|>>|<<|<=|>=|==|!=|&&|\|\||[()+\-*/%&|^~!?:.,\[\]=<>]))''')
_PRECEDENCE = {"||": 1, "&&": 2, "|": 3, "^": 4, "&": 5,
               "==": 6, "!=": 6, "<": 7, ">": 7, "<=": 7, ">=": 7,
               "<<": 8, ">>": 8, ">>>": 8, "+": 9, "-": 9,
               "*": 10, "/": 10, "%": 10}
_PRIMITIVES = {"boolean", "byte", "char", "short", "int", "long", "float", "double"}
_MAX_INLINE_NODES = 64


class _CleanupBudget(Exception):
    """Optional cleanup exceeded its bounded analysis work."""


class _TypeContext(dict[str, str]):
    """A method's type map, never mutated after construction."""


@dataclass(frozen=True)
class _Expr:
    kind: str
    value: str = ""
    children: tuple[_Expr, ...] = ()

    @cached_property
    def referenced_names(self) -> frozenset[str]:
        if self.kind == "name":
            return frozenset((self.value,))
        return frozenset().union(*(child.referenced_names for child in self.children))

    def names(self) -> frozenset[str]:
        return self.referenced_names

    @cached_property
    def node_count(self) -> int:
        return min(_MAX_INLINE_NODES + 1, 1 + sum(child.node_count for child in self.children))

    @cached_property
    def bit_cast(self):
        return bit_conversion(self)

    @cached_property
    def may_propagate(self) -> bool:
        if self.kind == "call":
            return bool(self.bit_cast and self.bit_cast[3].may_propagate)
        if self.kind in ("member", "index", "new", "new_array", "class_literal", "instanceof"):
            return False
        if self.kind == "binary" and self.value in ("/", "%"):
            return False
        return all(child.may_propagate for child in self.children)


class _ParseError(ValueError):
    pass


class _Parser:
    def __init__(self, text: str, types: Mapping[str, str]):
        self.tokens: list[str] = []
        position = 0
        while position < len(text):
            match = _TOKEN.match(text, position)
            if not match:
                if not text[position:].strip():
                    break
                raise _ParseError(text)
            self.tokens.append(match.group(match.lastindex))
            position = match.end()
        self.position = 0
        self.types = types

    def peek(self) -> str:
        return self.tokens[self.position] if self.position < len(self.tokens) else ""

    def take(self, expected: str | None = None) -> str:
        token = self.peek()
        if not token or expected is not None and token != expected:
            raise _ParseError(f"expected {expected}, found {token}")
        self.position += 1
        return token

    def cast(self) -> str | None:
        end = self.position
        while end < len(self.tokens) and self.tokens[end] != ")":
            end += 1
        parts = self.tokens[self.position:end]
        if not parts or end == len(self.tokens):
            return None
        joined = "".join(parts)
        if not re.fullmatch(r"[A-Za-z_$][\w$]*(?:\.[A-Za-z_$][\w$]*)*(?:\[\])*", joined):
            return None
        base = joined.removesuffix("[]")
        known = base in _PRIMITIVES or base == "Object" or joined in self.types.values()
        if not known and "." not in joined and "[" not in joined:
            return None
        if joined in self.types:
            return None
        following = self.tokens[end + 1] if end + 1 < len(self.tokens) else ""
        starts_operand = bool(following and (following[0].isalnum() or following[0] in "_$\"'(!~"))
        if not starts_operand and not (base in _PRIMITIVES and following in ("+", "-")):
            return None
        self.position = end + 1
        return joined

    def arguments(self) -> tuple[_Expr, ...]:
        self.take("(")
        arguments = []
        if self.peek() != ")":
            while True:
                arguments.append(self.expression())
                if self.peek() != ",":
                    break
                self.take(",")
        self.take(")")
        return tuple(arguments)

    def type_name(self) -> str:
        name = self.take()
        if not re.fullmatch(r"[A-Za-z_$][\w$]*", name):
            raise _ParseError(f"invalid type {name}")
        while self.peek() == ".":
            self.take(".")
            name += "." + self.take()
        return name

    def class_literal(self, expression: _Expr, dimensions: int = 0) -> _Expr:
        parts = []
        while expression.kind == "member":
            parts.append(expression.value)
            expression = expression.children[0]
        if expression.kind != "name" or expression.value in self.types:
            raise _ParseError("class literal requires a type name")
        parts.append(expression.value)
        return _Expr("class_literal", ".".join(reversed(parts)) + "[]" * dimensions)

    def expression(self, minimum: int = 0) -> _Expr:
        token = self.take()
        if token == "(":
            saved = self.position
            cast = self.cast()
            if cast is not None:
                left = _Expr("cast", cast, (self.expression(11),))
            else:
                self.position = saved
                left = self.expression()
                self.take(")")
        elif token in ("+", "-", "~", "!"):
            left = _Expr("unary", token, (self.expression(11),))
        elif token == "new":
            name = self.type_name()
            if self.peek() == "[":
                dimensions = []
                trailing = 0
                while self.peek() == "[":
                    self.take("[")
                    if self.peek() == "]":
                        trailing += 1
                    elif trailing:
                        raise _ParseError("allocated dimension after an empty array dimension")
                    else:
                        dimensions.append(self.expression())
                    self.take("]")
                if not dimensions:
                    raise _ParseError("array allocation needs a dimension")
                left = _Expr("new_array", name + "[]" * trailing, tuple(dimensions))
            else:
                left = _Expr("new", name, self.arguments())
        elif token[0].isdigit() or token[0] in "\"'" or token in ("true", "false", "null"):
            left = _Expr("literal", token)
        else:
            left = _Expr("name", token)
        while True:
            token = self.peek()
            if token == ".":
                self.take(".")
                member = self.take()
                left = self.class_literal(left) if member == "class" else _Expr("member", member, (left,))
            elif token == "[":
                self.take("[")
                if self.peek() == "]":
                    self.take("]")
                    dimensions = 1
                    while self.peek() == "[":
                        self.take("[")
                        self.take("]")
                        dimensions += 1
                    self.take(".")
                    self.take("class")
                    left = self.class_literal(left, dimensions)
                else:
                    index = self.expression()
                    self.take("]")
                    left = _Expr("index", "", (left, index))
            elif token == "(":
                left = _Expr("call", "", (left,) + self.arguments())
            elif token == "?" and minimum == 0:
                self.take("?")
                yes = self.expression()
                self.take(":")
                left = _Expr("conditional", "", (left, yes, self.expression()))
            elif token == "instanceof" and minimum <= 7:
                self.take()
                name = self.type_name()
                while self.peek() == "[":
                    self.take("[")
                    self.take("]")
                    name += "[]"
                left = _Expr("instanceof", name, (left,))
            elif token in _PRECEDENCE and _PRECEDENCE[token] >= minimum:
                self.take()
                left = _Expr("binary", token, (left, self.expression(_PRECEDENCE[token] + 1)))
            else:
                break
        return left

    def parse(self) -> _Expr:
        result = self.expression()
        if self.peek():
            raise _ParseError(f"trailing token {self.peek()}")
        return result


def _render(expr: _Expr) -> str:
    children = tuple(_render(child) for child in expr.children)
    if expr.kind in ("name", "literal"):
        return expr.value
    if expr.kind == "class_literal":
        return expr.value + ".class"
    if expr.kind == "unary":
        return f"({expr.value}{children[0]})"
    if expr.kind == "binary":
        return f"({children[0]} {expr.value} {children[1]})"
    if expr.kind == "cast":
        return f"(({expr.value}) {children[0]})"
    if expr.kind == "member":
        return f"{children[0]}.{expr.value}"
    if expr.kind == "index":
        return f"{children[0]}[{children[1]}]"
    if expr.kind == "call":
        return f"{children[0]}({', '.join(children[1:])})"
    if expr.kind == "new":
        return f"new {expr.value}({', '.join(children)})"
    if expr.kind == "new_array":
        base = expr.value.rstrip("[]")
        suffix = expr.value[len(base):]
        return f"new {base}{''.join('[' + child + ']' for child in children)}{suffix}"
    if expr.kind == "instanceof":
        return f"({children[0]} instanceof {expr.value})"
    if expr.kind == "conditional":
        return f"({children[0]} ? {children[1]} : {children[2]})"
    raise _ParseError(expr.kind)


def _type(expr: _Expr, types: Mapping[str, str]) -> str | None:
    if not isinstance(types, _TypeContext):
        return _infer_type(expr, types)
    cache = expr.__dict__
    if cache.get("type_context") is types:
        return cache["type_value"]
    result = _infer_type(expr, types)
    cache["type_context"], cache["type_value"] = types, result
    return result


def _infer_type(expr: _Expr, types: Mapping[str, str]) -> str | None:
    if expr.kind == "name":
        return types.get(expr.value)
    if expr.kind == "class_literal":
        return "Class"
    if expr.kind == "literal":
        if expr.value in ("true", "false"):
            return "boolean"
        if expr.value == "null":
            return "null"
        if expr.value.startswith('"'):
            return "String"
        if expr.value.startswith("'"):
            return "char"
        return "long" if expr.value[-1:] in "lL" else "int"
    if expr.kind == "cast":
        return expr.value
    if expr.kind == "new":
        return expr.value
    if expr.kind == "new_array":
        return expr.value + "[]" * len(expr.children)
    if expr.kind == "instanceof":
        return "boolean"
    if expr.kind == "call":
        return expr.bit_cast[1] if expr.bit_cast else None
    if expr.kind == "unary":
        if expr.value == "!":
            return "boolean"
        operand = _type(expr.children[0], types)
        return "int" if operand in ("byte", "short", "char") else operand
    if expr.kind == "binary":
        if expr.value in ("==", "!=", "<", ">", "<=", ">=", "&&", "||"):
            return "boolean"
        left, right = (_type(child, types) for child in expr.children)
        if expr.value in ("&", "|", "^") and left == right == "boolean":
            return "boolean"
        if expr.value in ("<<", ">>", ">>>"):
            return "long" if left == "long" else "int" if left in ("byte", "char", "short", "int") else None
        if "String" in (left, right):
            return "String"
        if left not in _PRIMITIVES or right not in _PRIMITIVES:
            return None
        return next((kind for kind in ("double", "float", "long") if kind in (left, right)), "int")
    if expr.kind == "conditional":
        first, second = (_type(child, types) for child in expr.children[1:])
        return first if first == second else None
    return None


def _pure(expr: _Expr, types: Mapping[str, str]) -> bool:
    if not expr.may_propagate:
        return False
    if not isinstance(types, _TypeContext):
        return _is_pure(expr, types)
    cache = expr.__dict__
    if cache.get("pure_context") is types:
        return cache["pure_value"]
    result = _is_pure(expr, types)
    cache["pure_context"], cache["pure_value"] = types, result
    return result


def _is_pure(expr: _Expr, types: Mapping[str, str]) -> bool:
    if expr.kind in ("name", "literal"):
        return True
    if expr.kind == "call":
        conversion = expr.bit_cast
        return bool(conversion and _type(conversion[3], types) == conversion[2]
                    and _pure(conversion[3], types))
    if expr.kind == "cast":
        source = _type(expr.children[0], types)
        if expr.value in _PRIMITIVES:
            if source not in _PRIMITIVES or (source == "boolean") != (expr.value == "boolean"):
                return False
        elif source not in (expr.value, "null"):
            return False
    elif expr.kind == "binary":
        if expr.value in ("/", "%") or _type(expr, types) == "String":
            return False
        left, right = (_type(child, types) for child in expr.children)
        if expr.value in ("==", "!="):
            if (left in _PRIMITIVES) != (right in _PRIMITIVES):
                return False
        elif left not in _PRIMITIVES or right not in _PRIMITIVES:
            return False
    elif expr.kind == "unary":
        source = _type(expr.children[0], types)
        if source not in _PRIMITIVES or (source == "boolean") != (expr.value == "!"):
            return False
    elif expr.kind not in ("unary", "conditional"):
        return False
    return all(_pure(child, types) for child in expr.children)


def _integer(expr: _Expr) -> int | None:
    if expr.kind == "unary" and expr.value in ("-", "+"):
        value = _integer(expr.children[0])
        if value is not None and expr.value == "-":
            bits = 64 if _type(expr, {}) == "long" else 32
            return ((-value + (1 << (bits - 1))) % (1 << bits)) - (1 << (bits - 1))
        return value
    if expr.kind != "literal" or expr.value in ("true", "false", "null") or expr.value[:1] in "\"'":
        return None
    try:
        value = int(expr.value.rstrip("lL"), 16 if expr.value.lower().startswith("0x") else 10)
        bits = 64 if expr.value[-1:] in "lL" else 32
        return ((value + (1 << (bits - 1))) % (1 << bits)) - (1 << (bits - 1))
    except ValueError:
        return None


def _integral(expr: _Expr, types: Mapping[str, str]) -> bool:
    return _type(expr, types) in ("byte", "char", "short", "int", "long")


def _negated(expr: _Expr, types: Mapping[str, str]) -> _Expr:
    if expr.kind == "unary" and expr.value == "!" and _type(expr.children[0], types) == "boolean":
        return expr.children[0]
    if expr == _Expr("literal", "true"):
        return _Expr("literal", "false")
    if expr == _Expr("literal", "false"):
        return _Expr("literal", "true")
    if expr.kind == "binary":
        inverse = {"==": "!=", "!=": "=="}
        if all(_integral(child, types) for child in expr.children):
            inverse |= {"<": ">=", ">=": "<", ">": "<=", "<=": ">"}
        if expr.value in inverse:
            return replace(expr, value=inverse[expr.value])
    return _Expr("unary", "!", (expr,))


def _rewrite(expr: _Expr, available: Mapping[str, _Expr], types: Mapping[str, str]) -> _Expr:
    if expr.kind == "name":
        return available.get(expr.value, expr)
    if not expr.children:
        return expr
    children = tuple(_rewrite(child, available, types) for child in expr.children)
    if children != expr.children:
        expr = _Expr(expr.kind, expr.value, children)
    if expr.kind == "call" or expr.kind == "binary" and expr.value == "|":
        expr = fold_word_transport(expr, lambda value: _type(value, types),
                                   lambda value: _pure(value, types))
    if expr.kind == "cast" and _type(expr.children[0], types) == expr.value:
        return expr.children[0]
    if expr.kind == "unary" and expr.value == "!":
        return _negated(expr.children[0], types)
    if expr.kind == "binary":
        left, right = expr.children
        a, b = _integer(left), _integer(right)
        # Object-to-payload addressing adds the 16-byte header before an
        # index, then subtracts it at the JVM array operation.
        if (b is not None and expr.value in ("+", "-") and left.kind == "binary"
                and left.value == "+" and _type(expr, types) == "int"):
            for base, offset in (left.children, tuple(reversed(left.children))):
                previous = _integer(offset)
                if previous is not None and _type(base, types) == "int":
                    total = ((previous + (b if expr.value == "+" else -b) + 0x80000000)
                             & 0xffffffff) - 0x80000000
                    if total == 0:
                        return base
                    return _Expr("binary", "+", (base, _Expr("literal", str(total))))
        if a is not None and b is not None and expr.value in ("==", "!=", "<", "<=", ">", ">="):
            result = {"==": a == b, "!=": a != b, "<": a < b, "<=": a <= b, ">": a > b, ">=": a >= b}[expr.value]
            return _Expr("literal", "true" if result else "false")
        if left == right and _pure(left, types) and _integral(left, types):
            if expr.value in ("==", "<=", ">="):
                return _Expr("literal", "true")
            if expr.value in ("!=", "<", ">"):
                return _Expr("literal", "false")
        if (expr.value in (">>", ">>>") and left.kind == "binary" and left.value == "<<"
                and _type(left.children[0], types) == "int"
                and (shift := _integer(right)) == _integer(left.children[1]) and shift in (16, 24)):
            value = left.children[0]
            if expr.value == ">>":
                narrowed = _Expr("cast", "short" if shift == 16 else "byte", (value,))
                return _Expr("cast", "int", (narrowed,))
            return _Expr("binary", "&", (value, _Expr("literal", str((1 << (32 - shift)) - 1))))
        if _type(expr, types) == _type(left, types) and _type(expr, types) in ("int", "long"):
            if right == _Expr("literal", "0") and expr.value in ("+", "-", "|", "^", "<<", ">>", ">>>"):
                return left
            if right == _Expr("literal", "1") and expr.value == "*":
                return left
    if expr.kind == "conditional":
        condition, yes, no = expr.children
        if condition == _Expr("literal", "true") and _type(expr, types) == _type(yes, types) is not None:
            return yes
        if condition == _Expr("literal", "false") and _type(expr, types) == _type(no, types) is not None:
            return no
        if yes == no and _pure(condition, types):
            return yes
    return expr


@dataclass(frozen=True)
class _Statement:
    text: str
    left: _Expr | None = None
    right: _Expr | None = None
    expression: _Expr | None = None

    @classmethod
    def parse(cls, text: str, types: Mapping[str, str]) -> _Statement:
        if not text.endswith(";"):
            return cls(text)
        try:
            parser = _Parser(text[:-1], types)
            left = parser.expression()
            if parser.peek() == "=":
                parser.take("=")
                right = parser.expression()
                if parser.peek():
                    raise _ParseError(text)
                return cls(text, left, right)
            if parser.peek():
                raise _ParseError(text)
            return cls(text, expression=left)
        except _ParseError:
            return cls(text)

    def target(self, locals: Mapping[str, str]) -> str | None:
        return self.left.value if self.left and self.left.kind == "name" and self.left.value in locals else None

    def reads(self, locals: Mapping[str, str]) -> set[str]:
        if self.right:
            names = self.right.referenced_names
            if not self.target(locals):
                names |= self.left.referenced_names
            return set(names) & locals.keys()
        if self.expression:
            return set(self.expression.referenced_names) & locals.keys()
        # An unparsed statement is retained and forms a conservative barrier.
        return set(locals)

    def render(self) -> str:
        if self.right:
            return f"{_render(self.left)} = {_render(self.right)};"
        return _render(self.expression) + ";" if self.expression else self.text


def _successors(block: Block) -> tuple[int, ...]:
    term = block.terminator
    if isinstance(term, Jump):
        return (term.target,)
    if isinstance(term, Branch):
        return tuple(dict.fromkeys((term.true_target, term.false_target)))
    if isinstance(term, Switch):
        return tuple(dict.fromkeys((term.default_target, *(target for _, target in term.cases))))
    return ()


def _coalesce(cfg: LiftedCFG) -> LiftedCFG:
    blocks = dict(cfg.blocks)
    predecessors = {node: set() for node in blocks}
    for node, block in blocks.items():
        for target in _successors(block):
            predecessors[target].add(node)
    pending = deque((cfg.entry,))
    visited = set()
    while pending:
        address = pending.popleft()
        block = blocks.get(address)
        if block is None or address in visited:
            continue
        visited.add(address)
        statements = list(block.statements)
        term = block.terminator
        while isinstance(term, Jump):
            target = term.target
            if target in (address, cfg.entry) or predecessors[target] != {address}:
                break
            successor = blocks.pop(target)
            statements.extend(successor.statements)
            term = successor.terminator
            for destination in _successors(successor):
                predecessors[destination].discard(target)
                predecessors[destination].add(address)
            del predecessors[target]
        blocks[address] = replace(block, statements=tuple(statements), terminator=term)
        pending.extend(_successors(blocks[address]))
    return replace(cfg, blocks=blocks)


def _term_expression(term, types: Mapping[str, str]) -> _Expr | None:
    text = term.condition if isinstance(term, Branch) else term.selector if isinstance(term, Switch) else term.value if isinstance(term, (Return, Throw)) else None
    if text is None:
        return None
    try:
        return _Parser(text, types).parse()
    except _ParseError:
        return None


def _transfer(statements: tuple[_Statement, ...], incoming: Mapping[str, _Expr],
              locals: Mapping[str, str], types: Mapping[str, str], *,
              materialize: bool = True) -> tuple[tuple[_Statement, ...], dict[str, _Expr]]:
    available = dict(incoming)
    result = []
    for statement in statements:
        target = statement.target(locals)
        if statement.right:
            if not materialize and (not target or not statement.right.may_propagate):
                if target:
                    available = {name: expr for name, expr in available.items()
                                 if name != target and target not in expr.referenced_names}
                continue
            right = _rewrite(statement.right, available, types)
            if target:
                source, destination = _type(right, types), types[target]
                if (source in _PRIMITIVES - {"boolean"} and destination in _PRIMITIVES - {"boolean"}
                        and source != destination):
                    right = _Expr("cast", destination, (right,))
            if materialize:
                left = statement.left if target else _rewrite(statement.left, available, types)
                result.append(_Statement(statement.text, left, right))
            if target:
                available = {name: expr for name, expr in available.items()
                             if name != target and target not in expr.referenced_names}
                # A paired wide store held this value for reuse in the same
                # registers. Keep its computation at the store.
                saved_computation = target.startswith("stored_") and right.node_count > 1
                if (not saved_computation and right.node_count <= _MAX_INLINE_NODES
                        and _pure(right, types) and target not in right.referenced_names):
                    available[target] = right
        elif statement.expression:
            if materialize:
                result.append(_Statement(statement.text, expression=_rewrite(statement.expression, available, types)))
        else:
            if materialize:
                result.append(statement)
            available.clear()
    return tuple(result), available


def _simplify_values(cfg: LiftedCFG, parameters: Mapping[str, str] | None = None) -> LiftedCFG:
    """Coalesce blocks, propagate safe values, and discard dead local copies."""
    cfg = _coalesce(cfg)
    types = _TypeContext(dict(parameters or {}) | cfg.locals)
    statements = {node: tuple(_Statement.parse(text, types) for text in block.statements)
                  for node, block in cfg.blocks.items()}
    predecessors = {node: set() for node in cfg.blocks}
    for node, block in cfg.blocks.items():
        for target in _successors(block):
            predecessors[target].add(node)
    incoming: dict[int, dict[str, _Expr]] = {cfg.entry: {}}
    outgoing: dict[int, dict[str, _Expr]] = {}
    queue = deque((cfg.entry,))
    queued = {cfg.entry}
    work = 0
    work_limit = min(100000, max(256, len(cfg.blocks) * 32))
    while queue:
        node = queue.popleft()
        queued.discard(node)
        work += 1
        if work > work_limit:
            raise _CleanupBudget
        known = [outgoing[pred] for pred in sorted(predecessors[node]) if pred in outgoing]
        values_at_entry = {}
        if node != cfg.entry and known:
            values_at_entry = {name: expr for name, expr in known[0].items()
                               if all(other.get(name) == expr for other in known[1:])}
        if node in outgoing and incoming.get(node) == values_at_entry:
            continue
        incoming[node] = values_at_entry
        _, values = _transfer(statements[node], values_at_entry, cfg.locals, types, materialize=False)
        if outgoing.get(node) != values:
            outgoing[node] = values
            for target in _successors(cfg.blocks[node]):
                if target not in queued:
                    queue.append(target)
                    queued.add(target)
    blocks = {}
    term_exprs = {}
    for node, block in cfg.blocks.items():
        rewritten, values = _transfer(statements[node], incoming.get(node, {}), cfg.locals, types)
        statements[node] = rewritten
        term = block.terminator
        expression = _term_expression(term, types)
        if expression:
            expression = _rewrite(expression, values, types)
            field = "condition" if isinstance(term, Branch) else "selector" if isinstance(term, Switch) else "value"
            term = replace(term, **{field: _render(expression)})
        term_exprs[node] = expression
        blocks[node] = replace(block, terminator=term)

    changed = True
    while changed:
        live_in = {node: set() for node in blocks}
        live_out = {node: set() for node in blocks}
        more = True
        while more:
            more = False
            for node, block in reversed(tuple(blocks.items())):
                work += 1
                if work > work_limit:
                    raise _CleanupBudget
                live = set().union(*(live_in[target] for target in _successors(block)))
                live_out[node] = set(live)
                expression = term_exprs[node]
                if expression:
                    live |= expression.referenced_names & cfg.locals.keys()
                elif isinstance(block.terminator, (Branch, Switch, Throw)) or isinstance(block.terminator, Return) and block.terminator.value:
                    live |= cfg.locals.keys()
                for statement in reversed(statements[node]):
                    target = statement.target(cfg.locals)
                    if target:
                        live.discard(target)
                    live |= statement.reads(cfg.locals)
                if live != live_in[node]:
                    live_in[node] = live
                    more = True
        changed = False
        for node, block in blocks.items():
            live = set(live_out[node])
            expression = term_exprs[node]
            if expression:
                live |= expression.referenced_names & cfg.locals.keys()
            elif isinstance(block.terminator, (Branch, Switch, Throw)) or isinstance(block.terminator, Return) and block.terminator.value:
                live |= cfg.locals.keys()
            kept = []
            for statement in reversed(statements[node]):
                target = statement.target(cfg.locals)
                if target and (statement.right == statement.left or target not in live and _pure(statement.right, types)):
                    changed = True
                    continue
                if target:
                    live.discard(target)
                live |= statement.reads(cfg.locals)
                kept.append(statement)
            statements[node] = tuple(reversed(kept))
    used = set()
    for node, block in tuple(blocks.items()):
        for statement in statements[node]:
            used |= statement.reads(cfg.locals)
            target = statement.target(cfg.locals)
            if target:
                used.add(target)
        if term_exprs[node]:
            used |= term_exprs[node].referenced_names & cfg.locals.keys()
        elif isinstance(block.terminator, (Branch, Switch, Throw)) or isinstance(block.terminator, Return) and block.terminator.value:
            used |= cfg.locals.keys()
        blocks[node] = replace(block, statements=tuple(statement.render() for statement in statements[node]))
    return replace(cfg, blocks=blocks, locals={name: kind for name, kind in cfg.locals.items() if name in used})


def _throw_is(block: Block, exception: str, types: Mapping[str, str]) -> bool:
    if block.statements or not isinstance(block.terminator, Throw):
        return False
    expression = _term_expression(block.terminator, types)
    return expression == _Expr("new", exception)


def _unsigned_operand(expression: _Expr) -> _Expr | None:
    if expression.kind == "binary" and expression.value == "&":
        left, right = expression.children
        if right.kind == "literal" and right.value.lower() in ("0xffffffffl", "4294967295l"):
            return left
    return None


def _unused_after(cfg: LiftedCFG, node: int, position: int, name: str,
                  types: Mapping[str, str]) -> bool:
    """Whether every continuation overwrites a local before reading it."""
    pending = [(node, position)]
    seen = set()
    while pending:
        current, start = pending.pop()
        if (current, start) in seen:
            continue
        seen.add((current, start))
        block = cfg.blocks[current]
        for text in block.statements[start:]:
            statement = _Statement.parse(text, types)
            if name in statement.reads(cfg.locals):
                return False
            if statement.target(cfg.locals) == name:
                break
        else:
            expression = _term_expression(block.terminator, types)
            if expression is not None:
                if name in expression.referenced_names:
                    return False
            elif isinstance(block.terminator, (Branch, Switch, Throw)) or isinstance(block.terminator, Return) and block.terminator.value:
                return False
            pending.extend((target, 0) for target in _successors(block))
    return True


def _reachable(cfg: LiftedCFG) -> LiftedCFG:
    pending, reachable = [cfg.entry], set()
    while pending:
        node = pending.pop()
        if node not in reachable:
            reachable.add(node)
            pending.extend(_successors(cfg.blocks[node]))
    return replace(cfg, blocks={node: block for node, block in cfg.blocks.items() if node in reachable})


def _array_access(statement: _Statement) -> _Expr | None:
    if statement.left and statement.left.kind == "index":
        return statement.left
    if statement.right and statement.right.kind == "index":
        return statement.right
    return None


def _checked_arrays(cfg: LiftedCFG, types: Mapping[str, str]) -> LiftedCFG:
    """Recover Jbed's checked array access, including its scaled address.

    Memory.newArray (0xdfa24) and xKniNewArray (0xdfb38) reject lengths
    >= 0x7fff0000 >> elementShift. On a successful unsigned bounds edge,
    index << elementShift therefore cannot overflow. Only this proven
    compiler pattern loses its shifts; ordinary integer shifts stay intact.
    """
    blocks = dict(cfg.blocks)
    predecessors = {node: set() for node in blocks}
    for node, block in blocks.items():
        for target in _successors(block):
            predecessors[target].add(node)
    for node, block in tuple(blocks.items()):
        term = block.terminator
        condition = _term_expression(term, types)
        if not isinstance(term, Branch) or condition is None or condition.kind != "binary":
            continue
        if condition.value == ">":
            length, index = map(_unsigned_operand, condition.children)
        elif condition.value == "<":
            index, length = map(_unsigned_operand, condition.children)
        else:
            continue
        if length is None or index is None or length.kind != "name" or index.kind not in ("name", "literal"):
            continue
        if not _throw_is(blocks[term.false_target], "ArrayIndexOutOfBoundsException", types):
            continue
        if predecessors[term.true_target] != {node} or not block.statements:
            continue
        check = _Statement.parse(block.statements[-1], types)
        if check.left != length or not check.right or check.right.kind != "member" or check.right.value != "length":
            continue
        array = check.right.children[0]
        if any(not (statement := _Statement.parse(text, types)).target(cfg.locals)
               or not _pure(statement.right, types)
               or statement.target(cfg.locals) in array.referenced_names | index.referenced_names
               for text in block.statements[:-1]):
            continue
        array_type = _type(array, types)
        if not array_type or not array_type.endswith("[]") or not _pure(array, types):
            continue
        component = array_type[:-2]
        shift = 0 if component in ("boolean", "byte") else 1 if component in ("char", "short") else 3 if component in ("long", "double") else 2
        success = blocks[term.true_target]
        statements = [_Statement.parse(text, types) for text in success.statements]
        removed_scale = None
        access_position = None
        for position, statement in enumerate(statements):
            access = _array_access(statement)
            if access:
                if access.children[0] != array:
                    break
                if statement.right == access and not statement.target(cfg.locals):
                    break
                if statement.left == access and not _pure(statement.right, types):
                    break
                subscript = access.children[1]
                if subscript == index:
                    access_position = position
                    break
                if shift and position and subscript.kind == "binary" and subscript.value == ">>":
                    scaled, amount = subscript.children
                    scale = statements[position - 1]
                    expected = _Expr("binary", "<<", (index, _Expr("literal", str(shift))))
                    if (amount == _Expr("literal", str(shift)) and scaled.kind == "name"
                            and scale.left == scaled and scale.right == expected
                            and scale.target(cfg.locals)
                            and (statement.target(cfg.locals) == scaled.value
                                 or _unused_after(cfg, term.true_target, position + 1, scaled.value, types))):
                        # A store must not also consume the scaled temporary as its value.
                        if statement.left == access and (not _pure(statement.right, types) or scaled.value in statement.right.referenced_names):
                            break
                        new_access = replace(access, children=(array, index))
                        statements[position] = replace(statement, **{"left" if statement.left == access else "right": new_access})
                        removed_scale = position - 1
                        access_position = position
                break
            # Moving the check across local arithmetic preserves its effects;
            # field reads, calls, other array accesses and local overwrites do not.
            if not statement.target(cfg.locals) or not _pure(statement.right, types):
                break
            if statement.target(cfg.locals) in (array.referenced_names | index.referenced_names):
                expected = _Expr("binary", "<<", (index, _Expr("literal", str(shift))))
                if statement.right != expected:
                    break
        if access_position is None:
            continue
        if removed_scale is not None:
            del statements[removed_scale]
        blocks[term.true_target] = replace(success, statements=tuple(statement.render() for statement in statements))
        prefix = block.statements
        if _unused_after(cfg, term.true_target, 0, length.value, types):
            prefix = prefix[:-1]
        blocks[node] = replace(block, statements=prefix, terminator=Jump(term.true_target))
        for predecessor in predecessors[node]:
            guard = blocks[predecessor]
            guard_term = guard.terminator
            guard_expr = _term_expression(guard_term, types)
            if not isinstance(guard_term, Branch) or not guard_expr or guard_expr.kind != "binary":
                continue
            if guard_expr.children != (array, _Expr("literal", "null")):
                continue
            good, bad = ((guard_term.true_target, guard_term.false_target) if guard_expr.value == "!=" else
                         (guard_term.false_target, guard_term.true_target) if guard_expr.value == "==" else (None, None))
            if good == node and _throw_is(blocks[bad], "NullPointerException", types):
                blocks[predecessor] = replace(guard, terminator=Jump(node))
    return _reachable(replace(cfg, blocks=blocks))


def simplify(cfg: LiftedCFG, parameters: Mapping[str, str] | None = None) -> LiftedCFG:
    """Recover values and compiler idioms before source or bytecode emission."""
    original = cfg
    try:
        cfg = _simplify_values(cfg, parameters)
        arrays = _checked_arrays(cfg, _TypeContext(dict(parameters or {}) | cfg.locals))
        return _simplify_values(arrays, parameters) if arrays != cfg else cfg
    except (_CleanupBudget, RecursionError):
        return original
