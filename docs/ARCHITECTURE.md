# CodeEdit Architecture Guide

This guide explains how the codebase is organized and — most importantly — **where new code
goes**. CI enforces the rules described here (see [Enforcement](#enforcement)), so reading this
before you add files will save you a failed check.

## Package topology

The workspace contains one app project and one local Swift package holding 12 library targets
and 5 test targets:

```
CodeEdit.xcworkspace
├── CodeEdit.xcodeproj                — app shell + composition UI
└── CodeEditModules/
    ├── Package.swift                 — the entire local dependency graph, in one file
    ├── Sources/
    │   ├── CodeEditCore              — pure types, EventBus, command interfaces (no UI/IO, zero deps)
    │   ├── CodeEditUI                — shared presentation atoms (→ CodeEditSymbols only)
    │   ├── CodeEditSettings          — settings seam + store + theme (UI pages stay app-side)
    │   ├── CodeEditDocument          — CodeFileDocument + editor-framework bridging protocols
    │   │                               (consumed only by CEEditor and CELSP)
    │   ├── ShellClient               — Process adapter (app-linked; no package-internal consumer)
    │   ├── CEWorkspaceFileManager    — FileManager + FSEvents workspace tree (app-linked, ditto)
    │   └── CEEditor, CESearch, CENotifications, CELSP, CESourceControl, CETerminal
    │                                 — one target per feature
    └── Tests/                        — CodeEditCoreTests, CodeEditUIUnitTests, CESearchTests,
                                        CELSPTests, CESourceControlTests
```

Each library target publishes a like-named `.library` product, and the app target links the ones
it needs. Inside the manifest, targets reference each other by bare name, so the whole graph is
legible in a single file — which is the point. See
[History](#history-why-the-2022-module-split-failed) for what the previous arrangement cost.

Naming: `CodeEdit*` marks substrate peer-named with the external CodeEdit libraries
(`CodeEditSourceEditor`, `CodeEditSymbols`, …); `CE*` marks app-internal feature contexts,
peer-named with the `CE*` domain types. Apply `CE` only where the bare name would collide with a
stdlib/SwiftUI/AppKit/vendor type — it is a collision-avoider, not a namespace.

Every target builds with Swift 6 strict concurrency **except `CEEditor`**, which declares
`.swiftLanguageMode(.v5)` and is the sole exception. The app target is still Swift 5 — write new
app-side code Swift-6-ready, and don't add `@MainActor` to app types whose callers aren't
isolated (it cascades).

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

## Rules

Three checks are enforced in CI. Each one blocks a specific failure documented in
[History](#history-why-the-2022-module-split-failed) — none is enforced on principle alone.

1. **`CodeEditCore` purity.** Zero dependencies, local or external. No `SwiftUI`, `AppKit`, or
   `Cocoa` import. Blocks 2022's `WorkspaceClient → TabBar`. Keep it platform-free too: it is the one
   target that would port to iPadOS unchanged.
2. **`CodeEditUI` purity.** No local target dependencies; external `CodeEditSymbols` only. Blocks
   2022's `CodeEditUI → Git`. This is why `FileIcon` is keyed on `URL` rather than on a domain type —
   a deliberate consequence, not an accident.
3. **Import honesty.** Every `import` in a target's sources must be declared in that target's
   manifest dependencies. Xcode workspace builds share one build directory, so an undeclared import
   of a sibling compiles fine and nothing else catches it. For the 7 targets that transitively need
   `CodeEditSymbols`, a standalone `swift build` is not available as a backstop either — see
   [Enforcement](#enforcement) — so this check is their only defence, not a redundant one.

Plus one assertion: **only `CEEditor` may declare `.swiftLanguageMode(.v5)`.** Every other target
inherits Swift 6 from the package's tools version. A target silently dropping to Swift 5 would lose
strict-concurrency enforcement without anything failing.

### Norms (review-time, not gates)

**Prefer features to be leaves.** Nothing should depend on a feature target. When an edge between two
features is genuinely needed, try the three
[cycle-resolution moves](#cycle-resolution-playbook) first, then declare the edge in the manifest
where it is visible to everyone. Acyclicity itself needs no rule — SwiftPM enforces it.

**Hub heuristic.** Any target both depended on by three or more others *and* itself depending on
three or more is a hub under review. 2022's `AppPreferences` was exactly this and would have been
flagged years before it became fatal. `CodeEditSettings` is the current watch item: four dependents
(`CEEditor`, `CELSP`, `CESourceControl`, `CETerminal`) but only one dependency (`CodeEditCore`), so
it stays a well-formed shared substrate rather than a hub — and it imports `AppKit` in 1 file and
`SwiftUI` in 7.

## Where does my code go?

Work through these in order; the first match wins.

1. **A new user-facing feature?** → A new target at `CodeEditModules/Sources/CE<Name>` (see the
   [recipe](#creating-a-new-feature-target)). Features start as targets; the app target is
   not the default. Exception: *shell chrome* that composes multiple features around the
   concrete `Workspace` hub — navigator/inspector/utility areas, the status bar — stays
   app-side, because its interface would effectively be "the whole app".
2. **A type, protocol, event, or command interface needed by two or more features?** →
   `CodeEditModules/Sources/CodeEditCore`, *if* it passes the charter (no UI/IO imports, no
   external dependencies). Events (facts, e.g. `TaskNotificationEvent`) and command interfaces
   (requests with exactly one handler, e.g. `WorkspaceNavigator`) always live here.
3. **A reusable view, style, or view modifier with no feature semantics?** →
   `CodeEditModules/Sources/CodeEditUI`.
4. **A service that performs I/O and has no UI?** → A new target at
   `CodeEditModules/Sources/<ServiceName>` (Core-only dependencies, its own library product, the
   app links it directly).
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

## Reading and writing settings

Feature packages reach settings through the **settings seam** in `CodeEditSettings`
(`Store/SettingsValue.swift`, `Store/SettingsAccessing.swift`) — never through a singleton and
never by naming the app-wide `SettingsData` aggregate. Three roles, pick by consumer kind:

| Consumer | Use | Why |
| --- | --- | --- |
| SwiftUI view | `@SettingsValue(TerminalSettings.self, \.cursorBlink)` | Resolves from the environment; `$`-projects a `Binding` for `Toggle`/`TextField`. |
| Read-only object (managers, services) | `SettingsReading` by initializer | No environment outside a view; narrow protocol makes read-only visible at the call site. |
| Object that also writes | `SettingsAccessing` by initializer | The read+write half; every `SettingsAccessing` satisfies `SettingsReading`. |

Access is **section-granular**: `value(_:)`/`setValue(_:)` deal in whole `SettingsSection` values,
so a caller changing one field reads its section, mutates it and writes it back.

- **`@AppSettings` is app-target only.** It resolves through the same `settingsAccessor`/
  `settingsRevision` environment as `SettingsValue`, addressing a section field through the
  app-wide `SettingsData` façade instead of naming one section directly. There is no
  `Settings.shared` singleton any more — `AppSettingsStore` (owned by `AppDependencies`) is the
  concrete accessor, injected like everything else. `@AppSettings` is what 29 app-target files
  still use (46 declarations); feature packages must not use it, and new app-target code should
  prefer the seam.
- **Neither wrapper works in a `Commands` conformer.** `.commands { }` attaches beside a scene's
  content, not inside it, so nothing guarantees the environment `SettingsSceneInjector` supplies
  reaches menu-bar code. `CodeEditCommands`/`ViewCommands` are handed `AppSettingsStore` by
  initializer and `@ObservedObject` it — reads, writes and menu invalidation all stop depending on
  undocumented behaviour.
- **`@Environment` does not cross an `NSHostingView`/`NSHostingController` boundary.** A new
  standalone hosting root must be given `.appServices(_:)` or wrapped in `SettingsInjector`, or its
  subtree falls back to `DefaultSettingsReader` — plausible defaults, and **writes discarded**.
  That fallback `assertionFailure`s outside SwiftUI previews precisely because it is otherwise
  silent.
- **Invalidation is explicit.** `SettingsValue` also depends on the `Equatable`
  `\.settingsRevision` environment key, fed from `AppSettingsStore.revision`. Rewriting the
  accessor is not a re-render signal: it is a stateless value behind an existential. Any injection
  point that *observes* the store supplies the revision (`SettingsInjector`, `CodeEditApp`);
  `appServices(_:)` observes nothing, so it supplies the accessor only.
- **`AppSettingsStore` is the concrete accessor.** Section-keyed storage, owned by
  `AppDependencies` (no `shared`), driving the same throttled save pipeline `Settings.shared` used
  to own. Sections nothing here decodes are held verbatim and re-emitted on save, so a disabled
  extension's configuration survives. The same holds for a section that is present but
  *undecodable*: it reads as defaults but is re-emitted unchanged, and the one write that would
  replace it is announced through `SettingsStore.willReplaceUndecodableSection` so the file is
  copied to `settings.json.corrupt-<timestamp>` first.

## Creating a new feature target

1. Create the folder `CodeEditModules/Sources/CE<Name>/` and add a target and product for it in
   `CodeEditModules/Package.swift`:

   ```swift
   .library(name: "CE<Name>", targets: ["CE<Name>"]),
   ```

   ```swift
   .target(
       name: "CE<Name>",
       dependencies: [
           "CodeEditCore",
           "CodeEditUI"
       ]
   ),
   ```

2. Link the product to the app: CodeEdit target → *General* → *Frameworks, Libraries, and
   Embedded Content* → add `CE<Name>`.
3. Remember the target builds with **Swift 6 strict concurrency** — types crossing actor
   boundaries need `Sendable`, and UI-bound classes are usually `@MainActor`. (`CEEditor` is the
   sole exception — see [Rules](#rules).)
4. Known quirk: targets that depend on `CodeEditSymbols` build via Xcode/xcodebuild only —
   standalone `swift build` fails on its `Bundle.module` resolution.
5. Declare **every** module you import in the manifest. The workspace's shared build directory
   makes undeclared imports of sibling targets compile by accident — CI will catch it
   (see below).

## Enforcement

Two automated checks keep this document honest; both run on every PR:

- **SwiftLint** (`swiftlint --strict`, config in `.swiftlint.yml`) — includes custom rules
  that reject UI imports in CodeEditCore and model/feature imports in CodeEditUI. These fire
  inside Xcode while you type.
- **The package audit** (`.github/scripts/audit_package_imports.py`) — verifies every `import`
  in every target is declared in that target's manifest dependencies, and that the three
  [Rules](#rules) plus the language-mode assertion hold. It exists because Xcode workspace
  builds share one build directory, so an undeclared import of a sibling target compiles fine
  locally. For the 7 targets that transitively need `CodeEditSymbols` there is no standalone
  `swift build` to fall back on either (see the quirk above), so for most of the graph this
  audit is the only thing standing between a leaky import and `main`.

Run both locally from the repo root:

```bash
swiftlint lint --quiet
python3 .github/scripts/audit_package_imports.py
```

### Known weakness in the CodeEditUI charter (2026-08-05)

Both checks constrain **local** targets only. `ui_package_purity` lists sibling module names in
a regex, and the audit script intersects the target's declared dependencies with the package's
library targets. So `CodeEditUI` is barred from importing
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
