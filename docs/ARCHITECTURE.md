# CodeEdit Architecture Guide

This guide explains how the codebase is organized and — most importantly — **where new code
goes**. CI enforces the rules described here (see [Enforcement](#enforcement)), so reading this
before you add files will save you a failed check.

## Package topology

The workspace contains one app project and nine local Swift packages, grouped by tier:

```
CodeEdit.xcworkspace
├── CodeEdit.xcodeproj                — app shell + composition UI
└── Packages/
    ├── Foundation/
    │   ├── CodeEditCore              — pure types, EventBus, command interfaces (no UI/IO, zero deps)
    │   ├── CodeEditUI                — shared presentation atoms (→ CodeEditSymbols only)
    │   ├── CodeEditDocument          — CodeFileDocument + editor-framework bridging protocols
    │   └── CodeEditSettings          — settings model + store (UI pages stay app-side)
    ├── Features/                     — CEEditor, CESearch, CENotifications, CELSP,
    │                                   CESourceControl, CETerminal (one package per feature)
    └── Services/CodeEditServices     — ShellClient, CEWorkspaceFileManager (one target each)
```

Naming: `CodeEdit*` = foundation substrate (peer-named with the external CodeEdit libraries),
`CE*` = feature packages (peer-named with the `CE*` domain types). Services are named after
their primary type.

All local packages build with Swift 6 strict concurrency. The app target is still Swift 5 —
write new app-side code Swift-6-ready, and don't add `@MainActor` to app types whose callers
aren't isolated (it cascades).

## History: why the 2022 module split failed

The project already tried a single multi-target `CodeEditModules` package. It was deleted on
2022-12-03 (commit `4858de16`) after repeated cyclic-dependency problems, and everything moved into
the app target. **The cycles were not caused by the packaging shape.** The 2022 manifest's own edges
explain them:

| Cause | Evidence in the 2022 manifest |
|---|---|
| **No kernel existed** | No framework-free contracts target. Shared types lived in whichever module happened to own them, so "A and B both need X" was only expressible as a feature→feature edge. |
| **Domain depended on UI** | `WorkspaceClient → TabBar` |
| **Shared UI depended on domain** | `CodeEditUI → WorkspaceClient, Git` |
| **A god-module hub** | `AppPreferences → CodeEditUI, Git, Keybindings, CodeEditUtils, Sparkle, CodeEditTextView`, itself depended on by half the tree |

With the bottom of the graph pointing up into the top, cycles were the steady state rather than an
accident. The same manifest split across eleven separate packages fails identically — SwiftPM refuses
to resolve a cyclic graph either way.

**`CodeEditCore` is the fix, and it now exists.** Zero dependencies, framework-free, holding domain
values, the typed `EventBus`, and the cross-feature command interfaces. Every "A and B both need X"
now resolves *downward*. Both 2022 killers are structurally impossible today: the domain lives in
`CodeEditCore`, which may import nothing, and `CodeEditUI → Git` is blocked by the `CodeEditUI`
purity rule.

### Cycle-resolution playbook

Detection was never the problem — SwiftPM refuses a cyclic target graph as a hard error. The 2022
failure was that detection had no accompanying *resolution* technique, so the exit taken was to
collapse everything into the app target. When you hit a cycle, the legal moves, in preference order:

1. **Push the shared thing down to `CodeEditCore`** — a protocol, an event, or a value type. This is
   what `EventBus` and the command interfaces (`WorkspaceNavigator`, `TasksConfigurationProviding`, …)
   are for. The default answer.
2. **Push the coordination up to the app target** — the app may depend on everything. Two leaf
   features never need to know each other if a doer wires them (`WorkspaceOpener`, `DocumentOpener`).
3. **Merge the two targets** — if A and B genuinely will not separate, the boundary was drawn wrong.
   Merging is a correct outcome, not a defeat; in one package it is a folder move plus a three-line
   manifest edit.

Never resolve a cycle by moving code back into the app target. That is what happened in 2022 and it
cost four years of enforced boundaries.

## Tier charters

| Tier | Package(s) | May depend on | Must never contain |
|---|---|---|---|
| Foundation | CodeEditCore | *nothing* | UI or I/O framework imports (SwiftUI/AppKit), external deps |
| Foundation | CodeEditUI | CodeEditSymbols only | feature semantics, model/service imports |
| Foundation | CodeEditDocument | CodeEditCore + editor libraries | app-tier types |
| Foundation | CodeEditSettings | CodeEditCore | settings *pages* (those are app-side composition UI) |
| Services | CodeEditServices targets | CodeEditCore only | UI imports, sibling service targets |
| Features | `CE*` packages | Foundation tiers + external libraries | **other `CE*` feature packages** |
| App | CodeEdit target | everything | — (it's the composition layer, not the default dumping ground) |

## Where does my code go?

Work through these in order; the first match wins.

1. **A new user-facing feature?** → A new `Packages/Features/CE<Name>` package (see the
   [recipe](#creating-a-new-feature-package)). Features start as packages; the app target is
   not the default. Exception: *shell chrome* that composes multiple features around the
   concrete `Workspace` hub — navigator/inspector/utility areas, the status bar — stays
   app-side, because its interface would effectively be "the whole app".
2. **A type, protocol, event, or command interface needed by two or more features?** →
   `CodeEditCore`, *if* it passes the charter (no UI/IO imports, no external dependencies).
   Events (facts, e.g. `TaskNotificationEvent`) and command interfaces (requests with exactly
   one handler, e.g. `WorkspaceNavigator`) always live here.
3. **A reusable view, style, or view modifier with no feature semantics?** → `CodeEditUI`.
4. **A service that performs I/O and has no UI?** → A new target in `CodeEditServices`
   (Core-only dependencies, its own library product, the app links it directly).
5. **Cross-service orchestration?** → A doer-style role-noun class in the feature that owns
   the operation (`WorkspaceOpener`, `FileMover`, `RepositoryCloner` — the `NSFileCoordinator`
   naming idiom). One doer per operation that touches more than one service; dependencies
   arrive via the initializer.
6. **Everything else — composition, adapters, menu commands, settings pages, app lifecycle?**
   → The app target, inside the owning feature folder.

### The consumer-count litmus

The most common placement mistake is moving something "up" because it *looks* generic.
Don't judge generic-ness — **count consumers**:

- A helper with **one** consumer lives next to that consumer, even if it looks
  general-purpose.
- It moves to `CodeEditCore` only when a **second consumer actually appears** *and* it passes
  the zero-dependency charter.
- The rule runs **both ways**. A type already in `CodeEditCore` that turns out to have a
  single consumer moves *out*, into that consumer's package. Framework-freedom is necessary
  but not sufficient: Core is a shared kernel, and every type in it that isn't actually
  shared is coupling every context pays for and nobody uses.
- The exception is **deliberate contracts**: events, command interfaces, and read-models stay
  in Core even with one publisher or one implementor today, because being a seam is their
  entire purpose. `FileEditorOverrideValues` stays for the same reason — it is the payload of
  Core's `FileEditorOverrides` protocol.

Applying this in July 2026 evicted five types: the registry install cluster
(`InstallationMethod`, `PackageSource`, `PackageManagerType`, `RegistryManagerError`) to
CELSP, and `GitBranchesGroup` to CESourceControl.

Worked example: fuzzy matching earned its place in CodeEditCore — three consumers across two
features (Open Quickly, Theme settings, Language Servers) — but its concurrency helper
depended on CollectionConcurrencyKit, which Core's zero-dependency charter forbids. The fix
was to rewrite the helper over `withTaskGroup` (about ten lines) rather than admit the
dependency, so `Domain/FuzzyMatching/` is now dependency-free.
**Dependency honesty beats tidiness**: never add a dependency to a foundation package to make
a move possible. Rewrite the helper, or mirror it locally, instead.

## Folder conventions (app target)

Grouping is **purpose-first**:

- Group by sub-feature (`ProjectNavigator/`, `History/`, `StatusBarItems/`, `Toolbar/`), never
  by kind — there are no `Models/`, `Views/`, `ViewModels/`, `Services/`, or `UseCases/`
  folders.
- A feature with roughly ten files or fewer stays flat.
- Shell/entry views and the feature's primary models sit at the feature root.
- Single-consumer helpers live next to their consumer.
- `Utils/` is closed. Every file in it carries a justification (an app-wide platform patch, a
  helper genuinely shared by multiple features with no better home). "It's generic" is not a
  justification.

## Communication rules

- **Feature packages never import each other.** Cross-feature signaling is typed:
  - **Facts** (something happened) → an event on the `EventBus` in CodeEditCore.
  - **Requests** (do something, exactly one rightful handler) → a command interface in
    CodeEditCore, implemented by an app-side adapter.
- No custom `Notification.Name`s. `NotificationCenter` is only used to observe platform
  notifications (NSWindow, NSApplication, NSMenu).
- No singletons and no DI container. `AppDependencies` is the app-scope composition root;
  objects receive dependencies through initializers, SwiftUI views through environment keys
  (`appServices(_:)`). Only composition roots may hold the whole `AppDependencies`.
- No SwiftUI view observes a service directly — services expose a concrete view-state object
  (the presentation-state split), and views issue commands through protocol-typed environment
  keys.

## Creating a new feature package

1. Create `Packages/Features/CE<Name>/Package.swift`:

   ```swift
   // swift-tools-version: 6.0

   import PackageDescription

   let package = Package(
       name: "CE<Name>",
       platforms: [.macOS(.v14)],
       products: [
           .library(name: "CE<Name>", targets: ["CE<Name>"])
       ],
       dependencies: [
           .package(path: "../../Foundation/CodeEditCore"),
           .package(path: "../../Foundation/CodeEditUI")
       ],
       targets: [
           .target(
               name: "CE<Name>",
               dependencies: [
                   .product(name: "CodeEditCore", package: "CodeEditCore"),
                   .product(name: "CodeEditUI", package: "CodeEditUI")
               ]
           )
       ]
   )
   ```

2. Add the package to the workspace: in Xcode, drag the folder into the **Features** group of
   the workspace navigator (or add a `FileRef` to `CodeEdit.xcworkspace/contents.xcworkspacedata`).
3. Link the product to the app: CodeEdit target → *General* → *Frameworks, Libraries, and
   Embedded Content* → add `CE<Name>`.
4. Remember the package builds with **Swift 6 strict concurrency** — types crossing actor
   boundaries need `Sendable`, and UI-bound classes are usually `@MainActor`.
5. Known quirk: packages that depend on `CodeEditSymbols` build via Xcode/xcodebuild only —
   standalone `swift build` fails on its `Bundle.module` resolution.
6. Declare **every** module you import in the manifest. The workspace's shared build directory
   makes undeclared imports of sibling packages compile by accident — CI will catch it
   (see below).

## Enforcement

Two automated checks keep this document honest; both run on every PR:

- **SwiftLint** (`swiftlint --strict`, config in `.swiftlint.yml`) — includes custom rules
  that reject UI imports in CodeEditCore, feature→feature imports, and model/feature imports
  in CodeEditUI. These fire inside Xcode while you type.
- **The package audit** (`.github/scripts/audit_package_imports.py`) — verifies every
  `import` in every package is declared in that package's manifest, and that the tier rules
  in the charter table hold. It exists because Xcode workspace builds share one build
  directory, so an undeclared import of a sibling package compiles fine locally and the
  violation stays invisible until a standalone build breaks.

Run both locally from the repo root:

```bash
swiftlint lint --quiet
python3 .github/scripts/audit_package_imports.py
```

### Known weakness in the CodeEditUI charter (2026-08-05)

Both checks constrain **local** packages only. `ui_package_purity` lists sibling module names in
a regex, and the audit script inspects `local_deps`. So `CodeEditUI` is barred from importing
`CodeEditCore` — a zero-dependency, pure-types package — while nothing stops it taking an
arbitrary *external* dependency, up to and including a tree-sitter grammar bundle. The rule as
written is narrower than its own stated intent ("presentation atoms must not know about models
or features") in one direction and far wider in the other.

This surfaced while deduplicating `FileIcon`, which is presentation keyed by a file's identity.
It was designed to take a `URL` rather than a domain type — so it needs neither `CodeEditCore`
nor the loophole — and its three custom colorsets moved into the package as resources, making
`CodeEditUI` self-contained and letting its tests assert colours without an app host. Treat the
asymmetry as a known weakness, not a licence: adding an external dependency to `CodeEditUI` to
sidestep the local-package rule would satisfy the letter of the charter and defeat its purpose.

## Glossary

Several words are overloaded in this codebase. These are the intended meanings; prefer the
qualified term whenever the bare one could be read two ways.

| Term | Means |
| --- | --- |
| **Editor** (`Editor`) | One tab group inside a workspace window — a split pane with its own tab bar and selection. |
| **Editor instance** (`EditorInstance`) | One open file within an editor, holding that file's editing state. |
| **`EditorManager`** | The per-workspace owner of the editor layout (splits, the active editor). |
| **CEEditor** | The package containing the editor feature. |
| **CodeEditSourceEditor** | The external text-editing widget (a separate repository), not part of this codebase. |
| **Search** | *Project* search: find/replace across files, the index, query modes, the Find navigator. Lives in `CESearch`, which owns its whole model. |
| **Fuzzy matching** | Ranking candidates by match quality for typeahead (Open Quickly, theme and language-server pickers). A generic capability in CodeEditCore `Domain/FuzzyMatching/`. It does no searching; nothing here is named `*Search*`. |
| **Workspace** (`Workspace`) | The session aggregate for one open project: the project-scoped services and their lifetime. It owns lifecycle, *not* mutation routing — features mutate the sub-models they are handed. |
| **Workspace window** (`WorkspaceWindow/`) | The window and its chrome around a workspace: navigator, inspector, utility area, status bar. Window-UI state lives on `CodeEditWindowController`, not on `Workspace`. |
| **Document** (`CodeFileDocument`) | An open, editable file backed by NSDocument. Distinct from `CEWorkspaceFile` (a node in the file tree) and from the file on disk. |
| **Doer** | A role-noun class performing one operation that spans services (`WorkspaceOpener`, `FileMover`, `RepositoryCloner`), following the `NSFileCoordinator` naming idiom. Formerly called UseCases. |
