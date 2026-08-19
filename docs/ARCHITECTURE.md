# CodeEdit Architecture Guide

This guide explains how the codebase is organized and — most importantly — **where new code
goes**. CI enforces the rules described here (see [Enforcement](#enforcement)), so reading this
before you add files will save you a failed check.

## Package topology

The workspace contains one app project and one local Swift package holding 12 library targets
and 6 test targets:

```
CodeEdit.xcworkspace
├── CodeEdit.xcodeproj                — app shell + composition UI
└── CodeEditModules/
    ├── Package.swift                 — the entire local dependency graph, in one file
    ├── Sources/
    │   ├── CodeEditCore              — domain types, EventBus, command interfaces (no UI, zero deps)
    │   ├── CodeEditUI                — shared presentation atoms (→ CodeEditSymbols only)
    │   ├── CodeEditSettings          — settings seam + store (UI pages stay app-side)
    │   ├── CodeEditDocument          — CodeFileDocument + editor-framework bridging protocols
    │   │                               (consumed only by CEEditor and CELSP)
    │   ├── ShellClient               — Process adapter (app-linked; no package-internal consumer)
    │   ├── CEWorkspaceFileManager    — FileManager + FSEvents workspace tree (app-linked, ditto)
    │   └── CEEditor, CESearch, CENotifications, CELSP, CESourceControl, CETerminal
    │                                 — one target per feature
    └── Tests/                        — CodeEditCoreTests, CodeEditSettingsTests,
                                        CodeEditUIUnitTests, CESearchTests, CELSPTests,
                                        CESourceControlTests
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
   `Cocoa` import. Blocks 2022's `WorkspaceClient → TabBar`. The two constraints earn their keep
   separately: **zero local dependencies** is the acyclicity guarantee — it makes Core a sink, so
   every "A and B both need X" resolves downward, which is the direct fix for the "no kernel
   existed" failure above. **No UI frameworks** keeps the placement question answerable — without
   it, Core becomes the place everything shared goes, which is what `AppPreferences` was and one of
   the two documented causes of the 2022 collapse.

   The friction this produces is usually the rule working. Four worked examples already in this
   codebase: `FileIcon` is keyed on `URL` rather than a domain type, so it needs neither
   `CodeEditCore` nor a charter exception (see rule 2 below); `WorkspacePanelContribution` was shaped
   to need only SwiftUI, so it lives in `CodeEditUI`
   (`CodeEditModules/Sources/CodeEditUI/WorkspacePanelContribution.swift`); fuzzy matching's
   concurrency helper was rewritten over `withTaskGroup` rather than admit `CollectionConcurrencyKit`
   (below); and `ActiveTheme` — the active light/dark theme, observed by the editor and terminal —
   lives *in* Core, because `ObservableObject` comes from Combine rather than SwiftUI. That last one
   is worth remembering: the charter forbids `SwiftUI`/`AppKit`/`Cocoa` specifically, so observation
   is available in Core and an "it needs to be observable, therefore it needs SwiftUI" argument is
   simply false.

   The counter-example people will cite: `TextEditingSettings` and `TerminalSettings.Font` carry
   `NSFont.Weight`, which forces them out of Core. That is the rule flagging a presentation type
   inside a settings model, not the rule obstructing a reasonable design — storing the weight as a
   `Double` and converting at the presentation boundary would make both structs Core-eligible with
   no rule change.
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

**Keep I/O out of Core.** A norm, not a gate — and worth being precise about, because the guide
previously implied it was enforced. It is not: the SwiftLint rule forbids `SwiftUI`/`AppKit`/`Cocoa`
and nothing more, and `Foundation` — which Core needs for `URL`, `Data` and `Codable`, and which 47
of its files import — *is* the I/O surface, so an import check cannot express this.

The reason to keep it out anyway: Core stays deterministic and testable with no filesystem, and I/O
already has a designated home — rule 4 of [Where does my code go?](#where-does-my-code-go) sends
services to their own target, which is what `CEWorkspaceFileManager` and `ShellClient` are.

**Known exception, recorded rather than pretended away:** `CEWorkspaceFile` exposes
`static let fileManager = FileManager.default` and uses it for `isEmptyFolder` and `doesExist`.
Those are filesystem reads from a domain type. Moving them onto the file-manager service is the pure fix; it is
not worth it today against 294 references. What was worth fixing, and has been, is code *outside*
Core borrowing that static to mutate the filesystem — a write routed through the domain layer. There
is now no such caller.

**Hub heuristic.** Any target both depended on by three or more others *and* itself depending on
three or more is a hub under review. 2022's `AppPreferences` was exactly this and would have been
flagged years before it became fatal. `CodeEditSettings` is the current watch item: five dependents
as of the panel-contributions work (`CEEditor`, `CELSP`, `CESearch`, `CESourceControl`, `CETerminal`
— up from four; `CESearch` joined when `FindNavigatorContribution` started reading its own settings
instead of taking them from an app-side wrapper) but only one dependency (`CodeEditCore`), so it
stays a well-formed shared substrate rather than a hub — and it imports `AppKit` in 1 file and
`SwiftUI` in 4, down from 7 once the theme moved to Core and the colour conversion to `CodeEditUI`
(re-measured 2026-08-16, not carried forward).

## Where does my code go?

Work through these in order; the first match wins.

1. **A new user-facing feature?** → A new target at `CodeEditModules/Sources/CE<Name>` (see the
   [recipe](#creating-a-new-feature-target)). Features start as targets; the app target is
   not the default. Exception: *shell chrome* that composes multiple features around the
   concrete `Workspace` hub — navigator/inspector/utility areas, the status bar — stays
   app-side, because its interface would effectively be "the whole app". **This exemption is
   about the panel, not any one tab inside it.** `NavigatorAreaView` hosts a tab bar over many
   features' tabs and has no single owner, so it stays app-side; a *tab* is one feature's own
   UI and belongs in that feature's package — `CESearch` owns `FindNavigatorContribution` for
   exactly this reason (see [Panel tab contributions](#panel-tab-contributions)). The only
   app-side tabs that stay are the ones with no owning package to move to —
   `ProjectNavigatorContribution`, `FileInspectorContribution`,
   `InternalDevelopmentInspectorContribution`, `DebugConsoleUtilityContribution` and
   `OutputUtilityContribution`. `TerminalUtilityContribution` is the one expected to move, to
   `CETerminal`. None of them stays because it is a tab.
2. **A type, protocol, event, or command interface needed by two or more features?** →
   `CodeEditModules/Sources/CodeEditCore`, *if* it passes the charter (no UI imports, no
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
  by kind — the app target has no `Models/`, `Views/`, `ViewModels/`, `Services/` or `UseCases/`
  folders.
- **`CEEditor` is the worked example** (2026-08-16). Its `Models/`, `Views/` and `UseCases/` were
  replaced by nine groups named for what their files are about — `Editor/`, `Layout/`,
  `FileViews/`, `TabBar/` (with `Tabs/` and `Tab/`), `JumpBar/`, `Documents/`, `Restoration/`,
  `Theme/`, `Adapters/`. Pure renames: 55 files, zero content changes, because Swift ignores
  directory layout and SwiftPM takes the whole target tree.
- **Five targets still group by kind** — `CENotifications`, `CESourceControl`, `CETerminal`,
  `CodeEditSettings` and `CodeEditUI`, 10 such folders — and `CESourceControl/UseCases/` is the
  last one carrying the retired name, though the type inside was correctly renamed to a doer
  (`RepositoryCloner`). Follow the convention in new code; those folders are a pending cleanup,
  not a counter-precedent.
- **Two placements from `CEEditor` worth reusing.** A conformance file belongs beside the protocol
  it satisfies (`CEWorkspaceFile+Editor` sits in `TabBar/Tab/` with `EditorTabRepresentable`), and
  environment keys are distributed to their subject rather than gathered into an `Environment/`
  group — which would be grouping by kind again.
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
- **No DI container.** `AppDependencies` is the app-scope composition root; objects receive
  dependencies through initializers, SwiftUI views through environment keys (`appServices(_:)`).
  Only composition roots may hold the whole `AppDependencies`. A container — ask for a type, get
  an instance — was removed deliberately: it hides who owns a thing and how long it lives, which
  is the question this section exists to answer.
- **Scope determines owner; nothing scoped is reached ambiently.** See
  [Scopes and ownership](#scopes-and-ownership) below. A `static shared` is legitimate only where
  the platform constructs the object and no initialiser parameter is available — today that is
  `CodeFileDocument`, which is why `delegateProvider` is a static closure set at launch. Eight
  other singletons remain, listed there as known exceptions.
- No SwiftUI view observes a service directly — services expose a concrete view-state object
  (the presentation-state split), and views issue commands through protocol-typed environment
  keys.

### Scopes and ownership

Four lifetimes exist. Each has an owner, and a type belongs to the narrowest one that fits.

| Scope | Owner | Examples |
| --- | --- | --- |
| Process | `AppDependencies` | `eventBus`, `lspService`, `settingsStore`, `workspaceWindowManager` |
| Workspace | `Workspace` | `editorManager`, `workspaceFileManager`, `sourceControlManager`, `taskManager` |
| Window | `CodeEditWindowController` | `utilityAreaModel`, `statusBarViewModel`, `notificationPanel`, `openQuicklyViewModel` |
| Document | `CodeFileDocument` | per-file editing state |

Window scope is not a subdivision of workspace scope: two windows may show one project, and their
utility areas, status bars and palettes must not be shared. That is why window-UI state lives on
`CodeEditWindowController` and not on `Workspace`.

Document scope is where the platform pushes back. `NSDocument` subclasses are created by the
document architecture, not by us, so no initialiser parameter is available — hence
`CodeFileDocument.delegateProvider`, a static closure set at launch. That is the shape of a
legitimate exception: the platform owns construction.

**Note on idiom:** "no singletons" is not the goal and never was. Apple's own frameworks are full of
them (`NSApplication.shared`, `FileManager.default`, `NSDocumentController.shared`). What was
removed was a *container*. A `shared` is a problem here only when it gives ambient access to
something whose lifetime is narrower than the process, or when it hides an owner that could hold it.

#### Known exceptions (2026-08-16)

Eight singletons remain. None is load-bearing; each is listed with the scope it actually has.

| Singleton | True scope | Note |
| --- | --- | --- |
| `ThemeModel` | process | already takes its settings store via `configure(_:)` at launch |
| `FeedbackModel` | process | ditto |
| `SearchSettingsModel` | process | ditto |
| `ExtensionManager` | process | |
| `ExtensionDiscovery` | process | |
| `InternalDevelopmentOutputSource` | process | debug-only |
| `EditorStateRestoration` | process | a GRDB database; `nonisolated(unsafe)` and optional |
| `TerminalCache` | **workspace** | see below |

The first seven are process-scoped services that simply have not moved to `AppDependencies`; doing
so is mechanical and changes no behaviour.

`TerminalCache` is different, and is the one worth fixing rather than relocating. It is a
process-global `[UUID: CELocalShellTerminalView]` holding views that belong to a workspace window.
Eviction is per-terminal only — nothing clears it when a workspace or window closes — so two open
projects share one bag of live terminal views. It works because UUIDs do not collide, but the
lifetime is wrong, and a wrong lifetime surfaces as a leak rather than as a compile error.

## Panel tab contributions

The navigator, inspector and utility area no longer switch on closed enums (`NavigatorTab`,
`InspectorTab`, `UtilityAreaTab`). Each panel is a list of `WorkspacePanelContribution` values —
a tab is a value, not a case — assembled by one function per panel in
`CodeEdit/WorkspaceWindow/WorkspacePanel/PanelContributions.swift`: first-party entries named
directly, conditional ones (`InternalDevelopmentInspectorContribution`) as a plain `if`, then
extension-provided ones appended through a single adapter call. The panel that renders the list
cannot tell a first-party tab from an extension's — that indistinguishability is the point; it is
what lets a new contribution source arrive without the panel code changing.

`WorkspacePanelContribution` lives in `CodeEditUI`
(`CodeEditModules/Sources/CodeEditUI/WorkspacePanelContribution.swift`), not `CodeEditCore`: a
contribution vends a `content: AnyView`, and Core's charter (rule 1, above) forbids UI imports
outright. `CodeEditUI`'s own charter (rule 2) is satisfied too — the protocol needs SwiftUI and
nothing else.

A contribution vends two views. `content` is the tab itself. `bottomView` is an optional bar pinned
below it — the navigator's filter field and sort controls are the existing examples — defaulted to
`nil` so a tab with no such bar says nothing about it. It is a *requirement* rather than something
the panel is handed deliberately: it arrived from upstream as a `switch` over the retired tab enum,
where every new tab had to remember to add its case, and a package could not contribute one at all
because the switch lived app-side. Vended by the contribution, a tab cannot forget, and where the bar
is placed stays the panel's business — pre-Tahoe it insets the tab's own content, from macOS 26 it
spans the panel below the tab bar.

**A panel's tab list changes at runtime**, so a stored selection can outlive the tab it names: the
inspector rebuilds its list when a setting changes, and any panel's list changes when an extension is
enabled or disabled. `Collection.reconcilingSelection(_:)` (alongside the protocol) keeps a selection
that still resolves and otherwise falls back to the first tab; `WorkspacePanelView` applies it on
appear and on every change to the list. Without it the panel reads "No Selection" until the user
clicks something, because the stored id is stale rather than absent and nothing recovers on its own.
The rule lives in the package rather than the view so it holds for every panel and can be tested
without one.

A contribution's owner follows the same placement rule as everything else in
[Where does my code go?](#where-does-my-code-go): a feature that owns a tab vends its own
contribution from its package, reading whatever it needs (including settings, through the seam)
directly rather than having the app assemble it. `CESearch`'s `FindNavigatorContribution`
(`CodeEditModules/Sources/CESearch/FindNavigatorContribution.swift`) replaced an app-side
`FindNavigatorTab` wrapper that existed only to shuttle settings values down — once the feature
could read its own settings, the wrapper had no reason to exist. The tab's id is now owned by the
same package (`FindNavigatorContribution.tabID`); the app's `PanelTabID.search` references it
rather than duplicating the literal, so there is exactly one source of truth even though the app
still needs a compile-checked constant to select the tab by.

`ProjectNavigatorContribution` (`CodeEdit/WorkspaceWindow/NavigatorArea/NavigatorContributions.swift`)
stays app-side — not because it is a tab (see the
[chrome exemption correction](#where-does-my-code-go)) but because the project navigator has no
owning package to move to. The same holds for the file inspector, the internal-development
inspector, and the debug and output utility tabs. `TerminalUtilityContribution` is the one that
should move, to `CETerminal`; it has not because it is coupled to app-side utility-area chrome.

`CESourceControl` is the second feature package to own a panel tab, after `CESearch`.
`SourceControlNavigatorContribution` and `GitHistoryInspectorContribution`
(`CodeEditModules/Sources/CESourceControl/SourceControlNavigator/` and `.../HistoryInspector/`)
vend `SourceControlNavigatorView` and `HistoryInspectorView` from the package; the app-side
`WorkspaceWindow/NavigatorArea/SourceControlNavigator/` and
`WorkspaceWindow/InspectorArea/HistoryInspector/` groups no longer exist. The relocation is the
shape a future one follows: whatever the view needs that the package cannot see becomes a
**required** initialiser parameter on the contribution — `WorkspaceNavigator` for the navigator
tab, `ActiveEditorState` for the inspector tab — rather than an environment key moved down with
it; both are non-optional so a missing injection at the call site
(`PanelContributions.swift`) is a compile error, not a silently no-op tab. Each contribution still
owns its own `tabID` constant, and the app's `PanelTabID.sourceControl` / `.gitHistory` reference
it rather than duplicating the literal, same as `PanelTabID.search`. A third relocation onto this
shape is expected.

Extensions are the third contribution source. `ExtensionPanelContribution`
(`CodeEdit/WorkspaceWindow/WorkspacePanel/ExtensionPanelContribution.swift`) is the **only** app
file, outside the pre-existing extension-management UI under `AuxiliaryWindows/Extensions/`, that
may name `AppExtensionIdentity` or `ResolvedSidebar`. Confining ExtensionKit's vocabulary to this
one adapter is what let the app-side panel-contribution list above be written without an
ExtensionKit import in sight, and is what would let a second, non-ExtensionKit contribution source
arrive later without touching the panels.

## Reading and writing settings

Feature packages reach settings through the **settings seam** in `CodeEditSettings`
(`Store/SettingsValue.swift`, `Store/SettingsAccessing.swift`) — never through a singleton and
never by naming the app-wide `SettingsData` aggregate. Three roles, pick by consumer kind:

| Consumer | Use | Why |
| --- | --- | --- |
| SwiftUI view | `@SettingsValue(TerminalSettings.self, \.cursorBlink)` | Observes the injected `PersistentSettingsStore`; `$`-projects a `Binding` for `Toggle`/`TextField`. |
| Read-only object (managers, services) | `SettingsReading` by initializer | No environment outside a view; narrow protocol makes read-only visible at the call site. |
| Object that also writes | `SettingsAccessing` by initializer | The read+write half; every `SettingsAccessing` satisfies `SettingsReading`. |

Access is **section-granular**: `value(_:)`/`setValue(_:)` deal in whole `SettingsSection` values,
so a caller changing one field reads its section, mutates it and writes it back.

- **`@AppSettings` is app-target only.** It observes the same store as `SettingsValue`, but
  addresses a section field through the app-wide `SettingsData` façade instead of naming one
  section directly. There is no `Settings.shared` singleton any more — `PersistentSettingsStore`
  (owned by `AppDependencies`) is the concrete store, injected like everything else. `@AppSettings`
  is what 24 app-target files still use (40 declarations, re-counted 2026-08-16); feature packages must not use it, and
  new app-target code should prefer the seam.
- **Neither wrapper works in a `Commands` conformer.** `.commands { }` attaches beside a scene's
  content, not inside it, so nothing guarantees the environment `SettingsSceneInjector` supplies
  reaches menu-bar code. `CodeEditCommands`/`ViewCommands` are handed `PersistentSettingsStore` by
  initializer and `@ObservedObject` it — reads, writes and menu invalidation all stop depending on
  undocumented behaviour.
- **The environment does not cross an `NSHostingView`/`NSHostingController` boundary.** A new
  standalone hosting root must be wrapped in `SettingsInjector` (or `SettingsSceneInjector` for a
  scene), or every `@SettingsValue` under it **traps**. That is deliberate: this replaced a pair of
  environment keys whose failure modes were silent — a subtree given neither read plausible
  defaults and discarded writes, and a subtree given the value but not the separate `Int`
  invalidation key read correctly and never re-rendered. `@EnvironmentObject` makes both
  unrepresentable, because SwiftUI subscribes to the store itself. Those two injectors are the only
  places the store is injected, which is what makes the coverage question answerable by grep rather
  than by reachability analysis.
- **A protocol double cannot be substituted into a view.** `@EnvironmentObject` cannot carry an
  existential, so a view-level test injects a real `PersistentSettingsStore` on a temporary file.
  The protocol seam still applies to every initializer-injected consumer, which is where
  `RecordingSettingsStore` and `SnapshotSettingsReader` are used.
- **`DefaultSettingsReader` is not the environment's fallback any more** — there is no fallback. It
  survives as the stand-in four singletons (`ThemeModel`, `FeedbackModel`, `SearchSettingsModel`,
  `HistoryInspectorModel`) hold between construction and `configure(_:)`. It still
  `assertionFailure`s outside previews, since reaching it means a real store never arrived.
- **`PersistentSettingsStore` is the concrete store.** Section-keyed storage, owned by
  `AppDependencies` (no `shared`), driving the same throttled save pipeline `Settings.shared` used
  to own. Sections nothing here decodes are held verbatim and re-emitted on save, so a disabled
  extension's configuration survives. The same holds for a section that is present but
  *undecodable*: it reads as defaults but is re-emitted unchanged, and the one write that would
  replace it is announced through `SettingsStore.willReplaceUndecodableSection` so the file is
  copied to `settings.json.corrupt-<timestamp>` first.

### Where a settings section lives

A section lives with **its owner**:

| Readers | Home | Examples |
| --- | --- | --- |
| Exactly one feature package | that package | `TerminalSettings` → `CETerminal`, `LanguageServerSettings` → `CELSP`, `SourceControlSettings`/`AccountsSettings` → `CESourceControl` |
| More than one module, or only the app | `CodeEditSettings` | `TextEditing`, `Theme`, `General`, `Navigation`, `Developer`, `Search`, `Keybindings` |

**Never `CodeEditCore` or `CodeEditUI`.** A `Codable` config bag has no natural boundary and
accretes — that is precisely how Core became `AppPreferences` the first time, and Core's purity
rationale is that the placement question stays answerable. `CodeEditUI` is excluded mechanically:
it may not depend on a local target, so it cannot see settings types at all.

**Migration trigger:** when a section's readers collapse to a single feature, it moves with that
feature. That is how the four package-owned sections got where they are.

App-only sections (`SearchSettings`, `KeybindingsSettings`) stay in `CodeEditSettings` rather than
moving app-side: `SettingsFormatTests` guards the on-disk format for every section in one place
using `Bundle.module` fixtures, and splitting two sections into the app target would split that
guard across two bundle mechanisms to satisfy a boundary nothing enforces.

Two field-level misplacements are **recorded but not fixed**, because both keys live in users'
`settings.json` and moving a field is a data migration rather than a refactor:
`GeneralSettings.findNavigatorDetail` is read by `CESearch` (a feature-specific field in a shared
section), and `SearchSettings.ignoreGlobPatterns` is wired to its settings page and persisted but
never read by `CESearch` — the control works and has no effect, which is worse than dead code
because nothing looks unused.

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

Two tools enforce the three [Rules](#rules) above; both run on every PR:

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
swiftlint lint --strict --quiet
python3 .github/scripts/audit_package_imports.py
```

`--strict` matters: without it SwiftLint reports violations as warnings and exits 0, so a local run
looks clean and CI fails on the same tree.

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
