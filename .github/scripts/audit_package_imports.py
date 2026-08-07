#!/usr/bin/env python3
"""Audit the CodeEditModules package: every `import` must be declared in the
manifest, and the three rules from docs/ARCHITECTURE.md must hold.

Why: for most targets this script is the ONLY defence against a leaky import.
Xcode workspace builds share one build directory, so an undeclared import of a
sibling target compiles fine. The usual backstop — "it breaks a standalone
`swift build`" — does not exist here: external CodeEditSymbols never declares
its .xcassets under `resources:`, so SwiftPM synthesises no `Bundle.module`
accessor and the dependency itself fails to compile. 7 of the 12 targets need it
transitively, so plain `swift build` is unavailable for them and nothing else
would catch the violation. Hence manifest honesty is a PR gate.

Usage: python3 .github/scripts/audit_package_imports.py  (from anywhere)
"""
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
PACKAGE = REPO / "CodeEditModules"
MANIFEST = PACKAGE / "Package.swift"

# Apple SDK modules used in this codebase; extend when a new system framework is adopted.
SYSTEM_MODULES = {
    "Foundation", "FoundationNetworking", "SwiftUI", "AppKit", "Cocoa", "Combine",
    "CoreGraphics", "OSLog", "os", "PDFKit", "QuickLookUI", "RegexBuilder",
    "UniformTypeIdentifiers", "UserNotifications", "AVKit", "CryptoKit", "Security",
    "Swift", "XCTest", "Testing",
}

UI_FRAMEWORKS = {"SwiftUI", "AppKit", "Cocoa"}

# Rule 4: the single target permitted to opt out of Swift 6.
SWIFT5_ALLOWED = {"CEEditor"}

IMPORT_RE = re.compile(
    r"^\s*(?:@[\w()]+\s+)?import\s+(?:struct\s+|class\s+|enum\s+|func\s+|var\s+)?([A-Za-z_][A-Za-z0-9_]*)",
    re.MULTILINE,
)
TARGET_START_RE = re.compile(r"\.(target|testTarget)\(\s*name:\s*\"([^\"]+)\"")


def balanced_block(text, open_index):
    """Return text from the '(' at open_index through its matching ')'."""
    depth = 0
    for i in range(open_index, len(text)):
        if text[i] == "(":
            depth += 1
        elif text[i] == ")":
            depth -= 1
            if depth == 0:
                return text[open_index:i + 1]
    raise ValueError("unbalanced parentheses in manifest")


def parse_targets(text):
    """Map target name -> {kind, deps, swift_modes} from the manifest."""
    targets = {}
    for match in TARGET_START_RE.finditer(text):
        kind, name = match.group(1), match.group(2)
        paren = text.index("(", match.start())
        block = balanced_block(text, paren)
        deps = set(re.findall(r'"([A-Za-z][\w.\-]*)"', _dependencies_slice(block)))
        deps |= set(re.findall(r'\.product\(\s*name:\s*"([^"]+)"', block))
        deps.discard(name)
        targets[name] = {
            "kind": kind,
            "deps": deps,
            "swift_modes": set(re.findall(r"\.swiftLanguageMode\(\.(\w+)\)", block)),
        }
    return targets


def _dependencies_slice(block):
    """The text inside this target's `dependencies: [...]`, or '' if absent."""
    match = re.search(r"dependencies:\s*\[", block)
    if not match:
        return ""
    start = block.index("[", match.start())
    depth = 0
    for i in range(start, len(block)):
        if block[i] == "[":
            depth += 1
        elif block[i] == "]":
            depth -= 1
            if depth == 0:
                return block[start:i + 1]
    return ""


def main() -> int:
    if not MANIFEST.exists():
        print(f"Package audit FAILED: no manifest at {MANIFEST}")
        return 1

    text = MANIFEST.read_text()
    targets = parse_targets(text)
    library_targets = {n for n, t in targets.items() if t["kind"] == "target"}
    failures = []

    # --- Rule 1: CodeEditCore purity (manifest half) ---
    if targets.get("CodeEditCore", {}).get("deps"):
        failures.append(
            "CodeEditCore must have zero dependencies "
            f"(found {sorted(targets['CodeEditCore']['deps'])})"
        )

    # --- Rule 2: CodeEditUI purity ---
    ui_local = targets.get("CodeEditUI", {}).get("deps", set()) & library_targets
    if ui_local:
        failures.append(
            "CodeEditUI may not depend on local targets — CodeEditSymbols only "
            f"(found {sorted(ui_local)})"
        )

    # --- Rule 4: language-mode assertion ---
    for name, target in sorted(targets.items()):
        if "v5" in target["swift_modes"] and name not in SWIFT5_ALLOWED:
            failures.append(
                f"{name}: only {sorted(SWIFT5_ALLOWED)} may declare .swiftLanguageMode(.v5) — "
                "every other target must stay on Swift 6"
            )

    # --- Rule 3: import honesty, plus Rule 1's no-UI half ---
    for name, target in sorted(targets.items()):
        source_dir = PACKAGE / ("Tests" if target["kind"] == "testTarget" else "Sources") / name
        if not source_dir.is_dir():
            failures.append(f"{name}: declared in the manifest but {source_dir} does not exist")
            continue
        system_modules = SYSTEM_MODULES - UI_FRAMEWORKS if name == "CodeEditCore" else SYSTEM_MODULES
        allowed = target["deps"] | system_modules | {name}
        for swift in sorted(source_dir.rglob("*.swift")):
            rel = swift.relative_to(REPO)
            for module in sorted(set(IMPORT_RE.findall(swift.read_text()))):
                if module not in allowed:
                    failures.append(f"{rel}: import {module} is not declared for target {name}")
                if name == "CodeEditCore" and module in UI_FRAMEWORKS:
                    failures.append(f"{rel}: {module} import violates the CodeEditCore no-UI rule")

    if failures:
        print(f"Package audit FAILED ({len(failures)} violations):")
        for failure in failures:
            print(f"  {failure}")
        return 1

    # --- Norm (informational only): hub heuristic ---
    dependents = {n: 0 for n in targets}
    for target in targets.values():
        for dep in target["deps"]:
            if dep in dependents:
                dependents[dep] += 1
    hubs = sorted(
        n for n, t in targets.items()
        if t["kind"] == "target"
        and dependents[n] >= 3
        and len(t["deps"] & library_targets) >= 3
    )
    if hubs:
        print(f"Note — hub targets under review (>=3 dependents and >=3 local deps): {hubs}")

    print(f"Package audit passed ({len(library_targets)} library targets).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
