"""Recover exceptional control-flow edges from Jbed's native catch tables.

ArchBase.handleException searches records in their stored order. A Thumb call
is represented by its last instruction byte (the saved return address minus
one); catch entries receive the exception in r0 after the VM restores the
method's frame and preserved registers. The JVM backend stores that exception
in the lifted r0 reference local before executing the recovered handler.
"""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
import re
from typing import Mapping

from .model import ExceptionRegion, MethodSpec, UnsupportedJava
from .structure import Jump, LiftedCFG, Throw, _successors


_MONITOR = re.compile(r"__jbed_monitor_(enter(?:_nonnull)?|exit)\(\(\(java\.lang\.Object\) (\w+)\)\);")


def _cleanup_lock(cfg: LiftedCFG, start: int) -> str | None:
    """Find the saved lock in a catch that only releases it and rethrows r0."""
    copies = {"v0": "<caught>"}
    seen = set()
    inputs = set()
    lock = None
    here = start
    while here in cfg.blocks and here not in seen:
        seen.add(here)
        block = cfg.blocks[here]
        for stmt in block.statements:
            match = _MONITOR.fullmatch(stmt)
            if match:
                operation, operand = match.groups()
                value = copies.get(operand, operand)
                if operation == "exit" and lock is None and value != "<caught>":
                    lock = value
                    continue
                return None
            assignment = stmt.removesuffix(";").split(" = ")
            if len(assignment) != 2 or not all(word.isidentifier() for word in assignment):
                return None
            dest, source = assignment
            if source not in copies:
                inputs.add(source)
            copies[dest] = copies.get(source, source)
        term = block.terminator
        if isinstance(term, Throw) and lock is not None:
            caught = term.value.removeprefix("((java.lang.Throwable) ").removesuffix(")")
            # The landing pad may read only the saved lock and the exception.
            if copies.get(caught) == "<caught>" and inputs <= {lock}:
                return lock
        if not isinstance(term, Jump):
            return None
        here = term.target
    return None


def _monitor_body(cfg, entry, lock, predecessors, handler_targets):
    """Labels reachable only after acquisition, while the cleanup lock local is still live."""
    start = cfg.blocks[entry].terminator.target
    body = set()
    releases = set()
    pending = [start]
    while pending:
        here = pending.pop()
        if here in body or here in handler_targets or here == entry:
            continue
        block = cfg.blocks[here]
        if any(stmt.startswith(lock + " = ") for stmt in block.statements):
            continue
        body.add(here)
        if any(stmt.startswith("__jbed_monitor_exit(") for stmt in block.statements):
            releases.add(here)
        else:
            pending.extend(_successors(block))
    # A branch into the middle, including a loop after a release, does not
    # establish the lock. Prune that path and its joins until the next enter.
    pending = [node for node in body if any(
        pred in releases or pred not in body and (pred != entry or node != start)
        for pred in predecessors[node])]
    while pending:
        node = pending.pop()
        if node in body:
            body.remove(node)
            pending.extend(_successors(cfg.blocks[node]))
    return body


@dataclass(frozen=True)
class Handler:
    address: int
    catch_type: str
    variable: str = "v0"


@dataclass(frozen=True)
class ExceptionPlan:
    method_start: int
    method_end: int
    regions: tuple[ExceptionRegion, ...]
    handlers: Mapping[int, Handler]

    def catches_for(self, address: int, size: int) -> tuple[ExceptionRegion, ...]:
        """Keep table order, including distinct catch types sharing a handler."""
        position = address + size - 1
        result = []
        for region in self.regions:
            if region.start <= position < region.end:
                result.append(region)
                if region.catch_class is None or region.catch_class == "java/lang/Throwable":
                    break
        return tuple(result)

    def project(self, cfg: LiftedCFG, catches: Mapping[int, tuple[ExceptionRegion, ...]]
                ) -> tuple[ExceptionRegion, ...]:
        """Project native throw sites and the cleanups for JVM synchronized blocks.

        A JVM checkcast/getfield synthesized for a guarded ARM ldr may otherwise
        enter a handler before the native code has even stored its live locals.
        """
        labels = sorted(a for a in cfg.blocks if self.method_start <= a < self.method_end)
        # A synthesized JVM field read or cast inside synchronized must run its
        # unlock/rethrow cleanup even when the corresponding ARM load is plain.
        # Other catches can depend on locals established after such a load.
        cleanups = defaultdict(dict)
        for region in self.regions:
            if region.catch_class in (None, "java/lang/Throwable"):
                lock = _cleanup_lock(cfg, region.handler)
                if lock is not None:
                    cleanups[lock][region.handler] = region
        held = defaultdict(dict)
        if cleanups:
            predecessors = defaultdict(list)
            for source in cfg.blocks.values():
                for target in _successors(source):
                    predecessors[target].append(source.address)
            for block in cfg.blocks.values():
                if len(block.statements) != 1 or not isinstance(block.terminator, Jump):
                    continue
                op = _MONITOR.fullmatch(block.statements[0])
                if not op or op[1] == "exit":
                    continue
                for lock, landings in cleanups.items():
                    pred = predecessors[block.address]
                    if op[2] != lock and (not pred or block.address in self.handlers or any(
                            cfg.blocks[p].statements != (f"{op[2]} = {lock};",) for p in pred)):
                        continue
                    body = _monitor_body(cfg, block.address, lock, predecessors, self.handlers)
                    # The same saved register may be reused by another block.
                    # Bind only landing pads actually reached by a native call
                    # under this acquisition (including the normal release).
                    linked = {r.handler: landings[r.handler] for a in body for r in catches.get(a, ())
                              if r.handler in landings}
                    if linked:
                        for address in body:
                            held[address].update(linked)
        regions = []
        for start, end in zip(labels, labels[1:] + [self.method_end]):
            active = catches.get(start)
            if active is None:
                active = ()
                if start in held:
                    native = self.catches_for(start, 1)
                    if native:
                        # A typed inner catch has priority. Never bypass it to
                        # install a synthesized edge directly to the cleanup.
                        if native[0].handler in held[start]:
                            active = native[:1]
                    elif len(held[start]) == 1:
                        # FCoder can start a protected native range at its
                        # first call. Earlier plain loads still become Java
                        # field or array operations under the same lock.
                        active = held[start].values()
            for region in active:
                regions.append(ExceptionRegion(start, end, region.handler, region.catch_class))
        return tuple(regions)

    def handler_locals(self, cfg: LiftedCFG) -> dict[int, str]:
        return {address: handler.variable for address, handler in self.handlers.items()
                if address in cfg.blocks}


def _common_type(types: tuple[str, ...], superclasses: Mapping[str, str | None]) -> str:
    if len(set(types)) == 1:
        return types[0]
    chains = []
    for name in types:
        chain = []
        while name and name not in chain:
            chain.append(name)
            name = superclasses.get(name)
        chain.append("java/lang/Throwable")
        chains.append(chain)
    return next(name for name in chains[0] if all(name in chain for chain in chains[1:]))


def plan_exceptions(method: MethodSpec,
                    superclasses: Mapping[str, str | None] | None = None) -> ExceptionPlan:
    start = method.address & ~1
    end = start + method.size
    catch_types: dict[int, list[str]] = {}
    for region in method.exception_regions:
        if not (start <= region.start < region.end <= end and start <= region.handler < end):
            raise UnsupportedJava(f"exception range escapes {method.owner}.{method.name}")
        catch_types.setdefault(region.handler, []).append(region.catch_class or "java/lang/Throwable")
    handlers = {address: Handler(address, _common_type(tuple(types), superclasses or {}))
                for address, types in catch_types.items()}
    return ExceptionPlan(start, end, method.exception_regions, handlers)
