#!/usr/bin/env python3
"""Audit local Swift packages: every `import` must be declared in the package
manifest, and the tier rules from docs/ARCHITECTURE.md must hold.

Why: Xcode workspace builds share one build directory, so an undeclared import
of a sibling local package compiles fine ("leaky import") and only breaks a
standalone `swift build`. This script makes manifest honesty a PR gate.

Usage: python3 .github/scripts/audit_package_imports.py  (from anywhere)
"""
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
PACKAGES = REPO / "Packages"

# Apple SDK modules used in this codebase; extend when a new system framework is adopted.
SYSTEM_MODULES = {
    "Foundation", "FoundationNetworking", "SwiftUI", "AppKit", "Cocoa", "Combine",
    "CoreGraphics", "OSLog", "os", "PDFKit", "QuickLookUI", "RegexBuilder",
    "UniformTypeIdentifiers", "UserNotifications", "AVKit", "CryptoKit", "Security",
    "Swift", "XCTest", "Testing",
}

LOCAL_PRODUCTS = {
    "CodeEditCore", "CodeEditUI", "CodeEditDocument", "CodeEditSettings",
    "CEEditor", "CESearch", "CENotifications", "CELSP", "CESourceControl",
    "CETerminal", "ShellClient", "CEWorkspaceFileManager",
}
FEATURE_PRODUCTS = {"CEEditor", "CESearch", "CENotifications", "CELSP", "CESourceControl", "CETerminal"}
UI_FRAMEWORKS = {"SwiftUI", "AppKit", "Cocoa"}

IMPORT_RE = re.compile(
    r"^\s*(?:@[\w()]+\s+)?import\s+(?:struct\s+|class\s+|enum\s+|func\s+|var\s+)?([A-Za-z_][A-Za-z0-9_]*)",
    re.MULTILINE,
)
PRODUCT_DEP_RE = re.compile(r'\.product\(\s*name:\s*"([^"]+)"')
TARGET_RE = re.compile(r'\.(?:target|executableTarget|testTarget)\(\s*name:\s*"([^"]+)"')


def manifest_declared(manifest_text: str) -> set:
    """Modules a target in this package may legitimately import."""
    declared = set(PRODUCT_DEP_RE.findall(manifest_text))
    declared |= set(TARGET_RE.findall(manifest_text))  # own targets
    # bare-string dependencies inside dependencies: [...] arrays
    for match in re.findall(r"dependencies:\s*\[([^\]]*)\]", manifest_text, re.DOTALL):
        declared |= set(re.findall(r'"([A-Za-z][\w-]*)"', match))
    return declared


def main() -> int:
    failures = []
    manifests = sorted(PACKAGES.glob("*/*/Package.swift"))
    if not manifests:
        print(f"Package audit FAILED: no manifests found under {PACKAGES}")
        return 1

    for manifest in manifests:
        pkg_dir = manifest.parent
        pkg_name = pkg_dir.name
        tier = pkg_dir.parent.name  # Foundation | Services | Features
        text = manifest.read_text()
        declared = manifest_declared(text)
        own_targets = set(TARGET_RE.findall(text)) | {pkg_name}
        # A package's own targets are not dependencies — exclude them from tier analysis.
        local_deps = (declared - own_targets) & LOCAL_PRODUCTS

        # --- tier rules on the manifest itself ---
        if pkg_name == "CodeEditCore" and PRODUCT_DEP_RE.search(text):
            failures.append(f"{pkg_name}: CodeEditCore must have zero dependencies")
        if pkg_name == "CodeEditUI" and local_deps:
            failures.append(f"{pkg_name}: CodeEditUI may not depend on local packages (CodeEditSymbols only)")
        if tier == "Services" and local_deps - {"CodeEditCore"}:
            failures.append(
                f"{pkg_name}: service targets may depend on CodeEditCore only "
                f"(found {sorted(local_deps - {'CodeEditCore'})})"
            )
        if tier == "Features" and (local_deps & FEATURE_PRODUCTS) - {pkg_name}:
            failures.append(
                f"{pkg_name}: feature packages may not depend on other feature packages "
                f"(found {sorted((local_deps & FEATURE_PRODUCTS) - {pkg_name})})"
            )

        # --- import honesty per source file ---
        allowed = declared | SYSTEM_MODULES | {pkg_name}
        for swift in sorted((pkg_dir / "Sources").rglob("*.swift")):
            rel = swift.relative_to(REPO)
            for module in sorted(set(IMPORT_RE.findall(swift.read_text()))):
                if module not in allowed:
                    failures.append(f"{rel}: import {module} is not declared in {pkg_name}/Package.swift")
                if pkg_name == "CodeEditCore" and module in UI_FRAMEWORKS:
                    failures.append(f"{rel}: {module} import violates the CodeEditCore no-UI charter")

    if failures:
        print(f"Package audit FAILED ({len(failures)} violations):")
        for failure in failures:
            print(f"  {failure}")
        return 1
    print(f"Package audit passed ({len(manifests)} packages).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
