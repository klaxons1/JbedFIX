"""Turn a lifted, typed control-flow graph into structured Java statements.

Loop-carried values are mutable locals in the lifting IR. This pass discovers
natural loops from dominators, uses postdominators for branch joins, and keeps
edge assignments in their original order. It refuses irreducible control flow
instead of introducing a program-counter interpreter into the recovered Java.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class Return:
    value: str | None = None


@dataclass(frozen=True)
class Throw:
    value: str


@dataclass(frozen=True)
class Jump:
    target: int


@dataclass(frozen=True)
class Branch:
    condition: str
    true_target: int
    false_target: int


@dataclass(frozen=True)
class Switch:
    selector: str
    cases: tuple[tuple[int, int], ...]
    default_target: int


@dataclass(frozen=True)
class Block:
    address: int
    statements: tuple[str, ...]
    terminator: Return | Throw | Jump | Branch | Switch


@dataclass(frozen=True)
class LiftedCFG:
    entry: int
    blocks: dict[int, Block]
    locals: dict[str, str]
    calls: tuple[int, ...] = ()


class UnsupportedStructure(ValueError):
    """The CFG cannot be represented by the supported Java control constructs."""


StructureError = UnsupportedStructure


@dataclass(frozen=True)
class _Loop:
    header: int
    nodes: frozenset[int]
    exits: frozenset[int]


@dataclass(frozen=True)
class _ActiveLoop:
    loop: _Loop
    follow: int | None


def _successors(block: Block) -> tuple[int, ...]:
    term = block.terminator
    if isinstance(term, Jump):
        return (term.target,)
    if isinstance(term, Branch):
        return tuple(dict.fromkeys((term.true_target, term.false_target)))
    if isinstance(term, Switch):
        return tuple(dict.fromkeys((term.default_target, *(target for _, target in term.cases))))
    return ()


def _indent(lines: list[str]) -> list[str]:
    return ["    " + line if line else "" for line in lines]


def _negate(condition: str) -> str:
    return f"!({condition})"


class _Structurer:
    def __init__(self, cfg: LiftedCFG):
        self.cfg = cfg
        if any(isinstance(block.terminator, Switch) for block in cfg.blocks.values()):
            raise UnsupportedStructure("switch requires the bytecode backend")
        self.reachable: set[int] = set()
        pending = [cfg.entry]
        while pending:
            node = pending.pop()
            if node in self.reachable:
                continue
            if node not in cfg.blocks:
                raise UnsupportedStructure(f"missing block at 0x{node:x}")
            self.reachable.add(node)
            pending.extend(_successors(cfg.blocks[node]))
        self.predecessors = {node: set() for node in self.reachable}
        for node in self.reachable:
            for target in _successors(cfg.blocks[node]):
                self.predecessors[target].add(node)
        self.dominators = self._dominators()
        self.loops = self._loops()
        self.cyclic_nodes = {node for loop in self.loops.values() for node in loop.nodes}
        self.postdominators = self._postdominators()
        self.emitted: set[int] = set()
        self.labelled_loops: set[int] = set()
        for inner in self.loops.values():
            for outer in self.loops.values():
                if inner.nodes < outer.nodes and outer.header in inner.exits:
                    self.labelled_loops.add(outer.header)

    def _dominators(self) -> dict[int, set[int]]:
        dom = {node: set(self.reachable) for node in self.reachable}
        dom[self.cfg.entry] = {self.cfg.entry}
        changed = True
        while changed:
            changed = False
            for node in sorted(self.reachable):
                if node == self.cfg.entry:
                    continue
                incoming = self.predecessors[node]
                value = {node} | set.intersection(*(dom[pred] for pred in incoming))
                if value != dom[node]:
                    dom[node] = value
                    changed = True
        return dom

    def _loops(self) -> dict[int, _Loop]:
        natural: dict[int, set[int]] = {}
        for latch in sorted(self.reachable):
            for header in _successors(self.cfg.blocks[latch]):
                if header not in self.dominators[latch]:
                    continue
                nodes = {header, latch}
                pending = [] if latch == header else [latch]
                while pending:
                    node = pending.pop()
                    for predecessor in self.predecessors[node]:
                        if predecessor not in nodes:
                            nodes.add(predecessor)
                            pending.append(predecessor)
                natural.setdefault(header, set()).update(nodes)
        # Removing dominator backedges must make a reducible CFG acyclic.
        indegree = {node: 0 for node in self.reachable}
        forward: dict[int, list[int]] = {node: [] for node in self.reachable}
        for node in self.reachable:
            for target in _successors(self.cfg.blocks[node]):
                if target in self.dominators[node]:
                    continue
                forward[node].append(target)
                indegree[target] += 1
        pending = [node for node, degree in indegree.items() if not degree]
        visited = 0
        while pending:
            node = pending.pop()
            visited += 1
            for target in forward[node]:
                indegree[target] -= 1
                if not indegree[target]:
                    pending.append(target)
        if visited != len(self.reachable):
            raise UnsupportedStructure("irreducible control flow has a cycle without a dominating header")
        result = {}
        for header, nodes in natural.items():
            for node in nodes - {header}:
                if self.predecessors[node] - nodes:
                    raise UnsupportedStructure(f"loop at 0x{header:x} has an entry through 0x{node:x}")
            exits = {target for node in nodes for target in _successors(self.cfg.blocks[node]) if target not in nodes}
            result[header] = _Loop(header, frozenset(nodes), frozenset(exits))
        values = list(result.values())
        for index, first in enumerate(values):
            for second in values[index + 1:]:
                if first.nodes & second.nodes and not (first.nodes <= second.nodes or second.nodes <= first.nodes):
                    raise UnsupportedStructure("natural loops overlap without nesting")
        return result

    def _postdominators(self) -> dict[int | None, set[int | None]]:
        # None is the common method exit. Blocks in endless loops have no such
        # postdominator and retain only themselves in this relation.
        terminating = {node for node in self.reachable if not _successors(self.cfg.blocks[node])}
        pending = list(terminating)
        while pending:
            for predecessor in self.predecessors[pending.pop()]:
                if predecessor not in terminating:
                    terminating.add(predecessor)
                    pending.append(predecessor)
        universe: set[int | None] = set(terminating) | {None}
        post: dict[int | None, set[int | None]] = {None: {None}}
        post.update({node: set(universe) if node in terminating else {node} for node in self.reachable})
        changed = True
        while changed:
            changed = False
            for node in sorted(terminating, reverse=True):
                successors = _successors(self.cfg.blocks[node]) or (None,)
                value = {node} | set.intersection(*(post[target] for target in successors))
                if value != post[node]:
                    post[node] = value
                    changed = True
        return post

    def _common_follow(self, targets: tuple[int, ...] | frozenset[int]) -> int | None:
        if not targets:
            return None
        common = set.intersection(*(self.postdominators[target] for target in targets))
        common.discard(None)
        if not common:
            return None
        return max(common, key=lambda node: (len(self.postdominators[node]), -node))

    def _loop_follow(self, loop: _Loop) -> int | None:
        term = self.cfg.blocks[loop.header].terminator
        if isinstance(term, Branch):
            outside = [target for target in _successors(self.cfg.blocks[loop.header]) if target not in loop.nodes]
            if len(outside) == 1:
                return outside[0]
        if len(loop.exits) == 1:
            return next(iter(loop.exits))
        return self._common_follow(loop.exits)

    def _exit_tail(self, start: int, loop: _ActiveLoop, active: tuple[_ActiveLoop, ...]) -> tuple[list[str], bool]:
        # Outside blocks may contain assignments before their common loop exit
        # or return directly. They must not silently re-enter this loop body.
        pending, seen = [start], set()
        outer_headers = {item.loop.header for item in active[:-1]}
        while pending:
            node = pending.pop()
            if node == loop.follow or node in outer_headers or node in seen:
                continue
            if node in loop.loop.nodes:
                raise UnsupportedStructure(f"exit at 0x{start:x} re-enters loop 0x{loop.loop.header:x}")
            seen.add(node)
            pending.extend(_successors(self.cfg.blocks[node]))
        lines, reaches_follow = self._sequence(start, loop.follow, active[:-1])
        if reaches_follow:
            lines.append("break;")
        return lines, False

    def _emit_loop(self, loop: _Loop, active: tuple[_ActiveLoop, ...]) -> tuple[list[str], int | None]:
        follow = self._loop_follow(loop)
        context = active + (_ActiveLoop(loop, follow),)
        header = self.cfg.blocks[loop.header]
        term = header.terminator
        label = [f"loop_{loop.header:x}:"] if loop.header in self.labelled_loops else []
        if not header.statements and isinstance(term, Branch):
            inside = [target for target in _successors(header) if target in loop.nodes]
            if len(inside) == 1 and follow in _successors(header):
                condition = term.condition if term.true_target == inside[0] else _negate(term.condition)
                self.emitted.add(loop.header)
                body, _ = self._sequence(inside[0], loop.header, context)
                return label + [f"while ({condition}) {{"] + _indent(body) + ["}"], follow
        body, _ = self._sequence(loop.header, None, context, initial_header=loop.header)
        return label + ["while (true) {"] + _indent(body) + ["}"], follow

    def _sequence(self, start: int | None, stop: int | None,
                  active: tuple[_ActiveLoop, ...], initial_header: int | None = None) -> tuple[list[str], bool]:
        lines: list[str] = []
        current = start
        while current is not None and current != stop:
            if active and current != initial_header:
                if current == active[-1].loop.header:
                    lines.append("continue;")
                    return lines, False
                for outer in active[:-1]:
                    if current == outer.loop.header:
                        lines.append(f"continue loop_{current:x};")
                        return lines, False
                if current == active[-1].follow:
                    lines.append("break;")
                    return lines, False
                if current not in active[-1].loop.nodes:
                    tail, _ = self._exit_tail(current, active[-1], active)
                    return lines + tail, False
            # Short-circuit branches can share an acyclic tail that is not a
            # postdominator of either immediate branch (for example both bounds
            # failures assigning false). Duplicate that tail in the mutually
            # exclusive source regions; each execution still visits it once.
            # Loop regions need a structured join instead of such duplication.
            if current in self.emitted and current in self.cyclic_nodes and _successors(self.cfg.blocks[current]):
                raise UnsupportedStructure(f"shared block at 0x{current:x} has no structured join")
            if current in self.loops and current != initial_header:
                body, current = self._emit_loop(self.loops[current], active)
                lines.extend(body)
                continue
            initial_header = None
            block = self.cfg.blocks[current]
            self.emitted.add(current)
            lines.extend(block.statements)
            term = block.terminator
            if isinstance(term, Return):
                lines.append("return;" if term.value is None else f"return {term.value};")
                return lines, False
            if isinstance(term, Throw):
                lines.append(f"throw {term.value};")
                return lines, False
            if isinstance(term, Jump):
                current = term.target
                continue
            # A terminating guard does not need an else containing the entire
            # remaining method. This is common for compiled null/index checks
            # and for searches that return from inside a loop.
            true_terminal = not _successors(self.cfg.blocks[term.true_target])
            false_terminal = not _successors(self.cfg.blocks[term.false_target])
            if true_terminal != false_terminal:
                terminal = term.true_target if true_terminal else term.false_target
                remainder = term.false_target if true_terminal else term.true_target
                if not active or terminal != active[-1].follow:
                    condition = term.condition if true_terminal else _negate(term.condition)
                    guard, _ = self._sequence(terminal, None, active)
                    lines.extend([f"if ({condition}) {{"] + _indent(guard) + ["}"])
                    current = remainder
                    continue
            join = self._common_follow((term.true_target, term.false_target))
            # The caller's region boundary is already a valid join. Do not
            # consume it as part of a longer enclosing postdominator chain.
            if stop is not None and stop in self.postdominators[term.true_target] & self.postdominators[term.false_target]:
                if join is None or join not in self.postdominators[stop]:
                    pass
                else:
                    join = stop
            yes, yes_reaches = self._sequence(term.true_target, join, active)
            no, no_reaches = self._sequence(term.false_target, join, active)
            if yes and no:
                lines.extend([f"if ({term.condition}) {{"] + _indent(yes) + ["} else {"] + _indent(no) + ["}"])
            elif yes:
                lines.extend([f"if ({term.condition}) {{"] + _indent(yes) + ["}"])
            elif no:
                lines.extend([f"if ({_negate(term.condition)}) {{"] + _indent(no) + ["}"])
            if join is None or not (yes_reaches or no_reaches):
                return lines, False
            current = join
        return lines, current == stop

    def run(self) -> tuple[str, ...]:
        lines, _ = self._sequence(self.cfg.entry, None, ())
        missing = self.reachable - self.emitted
        if missing:
            address = min(missing)
            raise UnsupportedStructure(f"structured output omitted reachable block at 0x{address:x}")
        declarations = [f"{kind} {name};" for name, kind in self.cfg.locals.items()]
        return tuple(declarations + ([""] if declarations and lines else []) + lines)


def structure(cfg: LiftedCFG) -> tuple[str, ...]:
    """Return indented Java body lines, excluding the surrounding method braces."""
    return _Structurer(cfg).run()


structure_cfg = structure
