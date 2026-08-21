# CodeEdit Architecture Guide

This guide explains how the codebase is organized and, most importantly, **where new code goes**.
The CI enforces the rules described here (see [Enforcement](#enforcement)), so reading this before you add files will save you a failed check.

## Package topology

The workspace contains one app project and one local Swift package holding 12 library targets and 6 test targets:

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

Each library target publishes a like-named `.library` product, and the app target links the ones it needs.
Inside the manifest, targets reference each other by bare name, so the whole graph is legible in a single file, which is the point.
See [History](#history-why-the-2022-module-split-failed) for what the previous arrangement cost.

Naming: `CodeEdit*` marks substrate peer-named with the external CodeEdit libraries (`CodeEditSourceEditor`, `CodeEditSymbols`, …); `CE*` marks app-internal feature contexts, peer-named with the `CE*` domain types.
Apply `CE` only where the bare name would collide with a stdlib/SwiftUI/AppKit/vendor type, it is a collision-avoider, not a namespace.

Every target builds with Swift 6 strict concurrency **except `CEEditor`**, which declares `.swiftLanguageMode(.v5)` and is the sole exception.
The app target is still Swift 5, write new app-side code Swift-6-ready, and don't add `@MainActor` to app types whose callers aren't isolated (it cascades).

## Design principles

Verified against the codebase on 2026-08-21.
Each is a claim about how the code is arranged today, not an aspiration.

1. **Dependencies point one way.**
   App shell, then features, then services, then foundation, with dependency-free `CodeEditCore` at the base.
   Acyclic, every edge pointing at something more fundamental, and no peer edges between features: there are currently zero feature-to-feature imports.
   Enforced by package boundaries, not convention.
2. **Every boundary is a protocol.**
   Anything performing I/O or reached across a feature boundary is protocol-backed and substitutable in tests: `ShellClientProtocol`, `GitClientProtocol`, `LSPServiceProtocol`, `RegistryManaging`, `KeybindingManaging`, `NotificationManaging`, `WorkspaceWindowManaging`, `SettingsAccessing`.
3. **Features are islands.**
   No feature imports another.
   Cross-feature interaction happens only through events, command interfaces, and shared substrate.
4. **State has one owner.**
   See [State ownership](#state-ownership) below.
5. **Facts are broadcast; commands have one handler.**
   The mechanism follows the intent, see [Communication rules](#communication-rules).
6. **Native first, framework-light.**
   SwiftUI and AppKit plus one local package.
   No meta-frameworks: there is no Composable Architecture or equivalent anywhere in the tree.
   The architecture is conventions plus compile-time boundaries.
7. **Testability is the acceptance test.**
   If a feature cannot be tested without building the whole app graph, the architecture has failed at that spot.
8. **Idiomatic by default.**
   Follow standard Swift and Xcode conventions rather than inventing project-specific layouts.
   Local code lives in one multi-target package, `CodeEditModules`, whose whole dependency graph is legible in a single manifest.
   The Swift API Design Guidelines and the repo's SwiftLint rules govern code.
   When a choice is unclear, prefer the community-idiomatic option over a bespoke one.

### State ownership

**Domain state lives in the object that owns the domain**: `SourceControlManager` for git status, `TaskManager` for running tasks, `LSPService` for language servers, `CEWorkspaceFileManager` for the file tree.
Note that most of those live in the *feature* that owns them (`CESourceControl`, `CETerminal`, `CELSP`), not in a service target; only the file tree does.
Such an object never holds UI state: `SourceControlManager` does not know that sheets exist.

**Presentation state lives in a view-state object**, which is the presentation-state split described under [Communication rules](#communication-rules).
Sheet and popover flags, selection, expansion, scroll targets.

**Views own only ephemera**, via `@State`: hover, focus, in-progress text.

Data flows down through observation, actions flow up through method calls and operation doers, and cross-feature effects travel only via events and command interfaces.

### Deliberately not chosen (or not yet)

- **The `@Observable` macro.**
  Not adopted.
  Every observable model is `ObservableObject` with `@Published` (48 conformances); the only two mentions of `@Observable` in the tree are TODO comments.
  Note that the deployment target *is* macOS 14 in both `project.pbxproj` and `Package.swift`, so the blocker is team agreement on that minimum rather than the code, and adopting `@Observable` would make the 14+ floor irreversible.
- **Swapping the `EventBus` off Combine cheaply.**
  It is not cheap, contrary to an earlier claim in this guide.
  `subscribe(_:)` returns `AnyPublisher`, so Combine is in the bus's public signature rather than hidden behind it, and all five subscribers use `sink` and `AnyCancellable`.
  An `AsyncStream` backend would change the return type and rewrite every call site.
  The bus is still regarded as a stopgap, with the platform's typed notifications as its natural replacement, but treat that as a migration rather than a substitution.
- **DI frameworks.**
  The explicit `AppDependencies` composition root is the whole mechanism, and there is no container anywhere in the tree.
  Dependencies are visible in initialisers and resolution failures are compile errors.
- **Architecture frameworks such as TCA.**
  The cost, meaning a learning curve for a community codebase, framework lock-in, and fighting AppKit interop, outweighs the benefit.
  Conventions plus package boundaries achieve the same testability.
- **Per-feature interface micro-packages.**
  Interface and implementation splits per feature are overkill at this scale.
  `CodeEditCore` carries the interfaces, 12 files under `Infrastructure/`.

## History: Why the 2022 module split failed

The project already tried a single multi-target `CodeEditModules` package.
It was deleted on 2022-12-03 (commit `4858de16`) after repeated cyclic-dependency problems, and everything moved into the app target.
**The cycles were not caused by the packaging shape.** The 2022 manifest's own edges explain them:

| Cause | Evidence in the 2022 manifest |
|---|---|
| **No kernel existed** | No framework-free contracts target. Shared types lived in whichever module happened to own them, so "A and B both need X" was only expressible as a feature→feature edge. |
| **Domain depended on UI** | `WorkspaceClient → TabBar` |
| **Shared UI depended on domain** | `CodeEditUI → WorkspaceClient, Git` |
| **A god-module hub** | `AppPreferences → CodeEditUI, Git, Keybindings, CodeEditUtils, Sparkle, CodeEditTextView`, itself depended on by half the tree |

With the bottom of the graph pointing up into the top, cycles were the steady state rather than an accident.
The same manifest split across eleven separate packages fails identically, SwiftPM refuses to resolve a cyclic graph either way.

**`CodeEditCore` is the fix, and it now exists.** Zero dependencies, framework-free, holding domain values, the typed `EventBus`, and the cross-feature command interfaces.
Every "A and B both need X" now resolves *downward*.
Both 2022 killers are structurally impossible today: the domain lives in `CodeEditCore`, which may import nothing, and `CodeEditUI → Git` is blocked by the `CodeEditUI` purity rule.

### Cycle-resolution playbook

Detection was never the problem, SwiftPM refuses a cyclic target graph as a hard error.
The 2022 failure was that detection had no accompanying *resolution* technique, so the exit taken was to collapse everything into the app target.
When you hit a cycle, the legal moves, in preference order:

1. **Push the shared thing down to `CodeEditCore`** — a protocol, an event, or a value type.
   This is what `EventBus` and the command interfaces (`WorkspaceNavigator` `TasksConfigurationProviding`, …) are for.
   The default answer.
2. **Push the coordination up to the app target** — the app may depend on everything.
   Two leaf features never need to know each other if a doer wires them (`WorkspaceOpener`, `DocumentOpener`).
3. **Merge the two targets** — if A and B genuinely will not separate, the boundary was drawn wrong.
   Merging is a correct outcome, not a defeat; in one package it is a folder move plus a three-line manifest edit.

Never resolve a cycle by moving code back into the app target.
That is what happened in 2022 and it cost four years of enforced boundaries.

## Rules

Three checks are enforced in CI.
Each one blocks a specific failure documented in [History](#history-why-the-2022-module-split-failed), none is enforced on principle alone.

1. **`CodeEditCore` purity.** Zero dependencies, local or external. No `SwiftUI`, `AppKit`, or `Cocoa` import.
   Blocks 2022's `WorkspaceClient → TabBar`.
   The two constraints earn their keep separately: **zero local dependencies** is the acyclicity guarantee, because it makes Core a sink, so every "A and B both need X" resolves downward, which is the direct fix for the "no kernel existed" failure above.
   **No UI frameworks** keeps the placement question answerable.
   Without it, Core becomes the place everything shared goes, which is what `AppPreferences` was and one of the two documented causes of the 2022 collapse.

   The friction this produces is usually the rule working, not obstructing you.
   Four worked examples, and the `NSFont.Weight` counter-example people cite, are in [docs/architecture-decisions.md](docs/architecture-decisions.md).
2. **`CodeEditUI` purity.** No local target dependencies; external `CodeEditSymbols` only.
   Blocks 2022's `CodeEditUI → Git`.
   This is why `FileIcon` is keyed on `URL` rather than on a domain type: a deliberate consequence, not an accident.
3. **Import honesty.** Every `import` in a target's sources must be declared in that target's manifest dependencies.
   Xcode workspace builds share one build directory, so an undeclared import of a sibling compiles fine and nothing else catches it.
   For the 7 targets that transitively need `CodeEditSymbols`, a standalone `swift build` is not available as a backstop either (see [Enforcement](#enforcement)), so this check is their only defence, not a redundant one.

Plus one assertion: **only `CEEditor` may declare `.swiftLanguageMode(.v5)`.** Every other target inherits Swift 6 from the package's tools version.
A target silently dropping to Swift 5 would lose strict-concurrency enforcement without anything failing.

### Norms (review-time, not gates)

**Prefer features to be leaves.** Nothing should depend on a feature target.
When an edge between two features is genuinely needed, try the three [cycle-resolution moves](#cycle-resolution-playbook) first, then declare the edge in the manifest where it is visible to everyone.
Acyclicity itself needs no rule, SwiftPM enforces it.

**Keep I/O out of Core.** A norm, not a gate.
It is worth being precise about, because the guide previously implied it was enforced.
It is not: the SwiftLint rule forbids `SwiftUI`/`AppKit`/`Cocoa` and nothing more, and `Foundation`, which Core needs for `URL`, `Data` and `Codable`, and which 47 of its files import, *is* the I/O surface, so an import check cannot express this.

The reason to keep it out anyway is concrete, not decorative.
`CodeEditCoreTests` is five files with zero use of `FileManager`, `temporaryDirectory` or `Data(contentsOf:)`: Core's tests need no filesystem, no temp directories and no cleanup.
And I/O already has a designated home, since rule 4 of [Where does my code go?](#where-does-my-code-go) sends services to their own target, which is what `CEWorkspaceFileManager` and `ShellClient` are.

See [docs/architecture-decisions.md](docs/architecture-decisions.md) for what this norm has actually prevented, and for why `ShellClient`, `CEWorkspaceFileManager`, `CodeEditDocument` and `CELSP` each stay separate targets.


**Known exception, recorded rather than pretended away:** `CEWorkspaceFile` exposes `static let fileManager = FileManager.default` and uses it for `isEmptyFolder` and `doesExist`.
Those are filesystem reads from a domain type.
Moving them onto the file-manager service is the pure fix; it is not worth it today against 294 references.
What was worth fixing, and has been, is code *outside* Core borrowing that static to mutate the filesystem, a write routed through the domain layer.
There is now no such caller.

**Hub heuristic.** Any target both depended on by three or more others *and* itself depending on three or more is a hub under review.
2022's `AppPreferences` was exactly this and would have been flagged years before it became fatal. `CodeEditSettings` is the current watch item: five dependents as of the panel-contributions work (`CEEditor`, `CELSP`, `CESearch`, `CESourceControl`, `CETerminal`, up from four; `CESearch` joined when `FindNavigatorContribution` started reading its own settings instead of taking them from an app-side wrapper) but only one dependency (`CodeEditCore`), so it stays a well-formed shared substrate rather than a hub, and it imports `AppKit` in 1 file and `SwiftUI` in 4, down from 7 once the theme moved to Core and the colour conversion to `CodeEditUI` (re-measured 2026-08-16, not carried forward).

## Where does my code go?

Work through these in order; the first match wins.

1. **A new user-facing feature?** → A new target at `CodeEditModules/Sources/CE<Name>` (see the [recipe](#creating-a-new-feature-target)).
   Features start as targets; the app target is not the default.
   Exception: *shell chrome* that composes multiple features around the concrete `Workspace` hub (navigator/inspector/utility areas, the status bar) stays app-side, because its interface would effectively be "the whole app".
   **This exemption is about the panel, not any one tab inside it.** `NavigatorAreaView` hosts a tab bar over many features' tabs and has no single owner, so it stays app-side; a *tab* is one feature's own UI and belongs in that feature's package.
   `CESearch` owns `FindNavigatorContribution` for exactly this reason (see [Panel tab contributions](#panel-tab-contributions)).
   The only app-side tabs that stay are the ones with no owning package to move to: `ProjectNavigatorContribution`, `FileInspectorContribution`, `InternalDevelopmentInspectorContribution`, `DebugConsoleUtilityContribution` and `OutputUtilityContribution`.
   `TerminalUtilityContribution` is the one expected to move, to `CETerminal`.
   None of them stays because it is a tab.
2. **A type, protocol, event, or command interface needed by two or more features?** → `CodeEditModules/Sources/CodeEditCore`, *if* it passes the charter (no UI imports, no external dependencies).
   Events (facts, e.g. `TaskNotificationEvent`) and command interfaces (requests with exactly one handler, e.g. `WorkspaceNavigator`) always live here.
3. **A reusable view, style, or view modifier with no feature semantics?** → `CodeEditModules/Sources/CodeEditUI`.
4. **A service that performs I/O and has no UI?** → A new target at `CodeEditModules/Sources/<ServiceName>` (Core-only dependencies, its own library product, the app links it directly).
5. **Cross-service orchestration?** → A doer-style role-noun class in the feature that owns the operation (`WorkspaceOpener`, `FileMover`, `RepositoryCloner`, following the `NSFileCoordinator` naming idiom).
   One doer per operation that touches more than one service; dependencies arrive via the initializer.
6. **Everything else: composition, adapters, menu commands, settings pages, app lifecycle?** → The app target, inside the owning feature folder.

### The consumer-count litmus

The most common placement mistake is moving something "up" because it *looks* generic.
Don't judge generic-ness.
**Count consumers**:

- A helper with **one** consumer lives next to that consumer, even if it looks general-purpose.
- It moves to `CodeEditCore` only when a **second consumer actually appears** *and* it passes the zero-dependency charter.
- The rule runs **both ways**.
  A type already in `CodeEditCore` that turns out to have a single consumer moves *out*, into that consumer's package.
  Framework-freedom is necessary but not sufficient: Core is a shared kernel, and every type in it that isn't actually shared is coupling every context pays for and nobody uses.
- The exception is **deliberate contracts**: events, command interfaces, and read-models stay in Core even with one publisher or one implementor today, because being a seam is their entire purpose.
  `FileEditorOverrideValues` stays for the same reason: it is the payload of Core's `FileEditorOverrides` protocol.

Applying this in July 2026 evicted five types: the registry install cluster (`InstallationMethod`, `PackageSource`, `PackageManagerType`, `RegistryManagerError`) to CELSP, and `GitBranchesGroup` to CESourceControl.

Worked example: fuzzy matching earned its place in CodeEditCore, with three consumers across two features (Open Quickly, Theme settings, Language Servers), but its concurrency helper depended on CollectionConcurrencyKit, which Core's zero-dependency charter forbids.
The fix was to rewrite the helper over `withTaskGroup` (about ten lines) rather than admit the dependency, so `Domain/FuzzyMatching/` is now dependency-free.
**Dependency honesty beats tidiness**: never add a dependency to a foundation package to make a move possible.
Rewrite the helper, or mirror it locally, instead.

## Folder conventions

Grouping is **by purpose, never by kind**.
There are no `Models/`, `Views/`, `ViewModels/`, `Services/`, `Protocols/`, `UseCases/` or `Extensions/` folders.

- Group by sub-feature or subject (`ProjectNavigator/`, `Restoration/`, `TabBar/`, `Shell/`), and if you cannot name the group without saying what kind of type it holds, it is not a group.
  A conformance file belongs beside the protocol it satisfies, and environment keys belong with their subject rather than in an `Environment/` folder.
- A feature with roughly ten files or fewer stays flat.
- Shell and entry views, plus the feature's primary models, sit at the feature root.
- Single-consumer helpers live next to their consumer.
- `Utils/` is closed. Place a new utility next to its consumer, and argue the case if you think it belongs in `Utils/`.

**Worked example.** `CEEditor` had 55 files under `Models/`, `Views/` and `UseCases/`.
They became `Editor/`, `Layout/`, `FileViews/`, `TabBar/` (with `Tabs/` and `Tab/`), `JumpBar/`, `Documents/`, `Restoration/`, `Theme/` and `Adapters/`, as pure renames with no content change.
Two placements are worth copying: `CEWorkspaceFile+Editor` sits in `TabBar/Tab/` beside the `EditorTabRepresentable` protocol it conforms to, and `UndoManagerRegistry` sits in `Documents/` rather than `Restoration/`, because it performs no saving.

**Two targets are stated exceptions.**
`CodeEditCore` keeps its `Domain/` and `Infrastructure/` split, because there the layer *is* the purpose.
`CodeEditUI` keeps `Styles/`, `Views/` and `EnvironmentKeys/`, because it is a component library with no feature semantics by charter, so kind is the subject a consumer browses by.
Do not "fix" either.

## Communication rules

- **Feature packages never import each other.** Cross-feature signaling is typed:
  - **Facts** (something happened) → an event on the `EventBus` in CodeEditCore.
  - **Requests** (do something, exactly one rightful handler) → a command interface in CodeEditCore, implemented by an app-side adapter.
- No custom `Notification.Name`s.
  `NotificationCenter` is only used to observe platform notifications (NSWindow, NSApplication, NSMenu).
- **No DI container.** `AppDependencies` is the app-scope composition root; objects receive dependencies through initializers, SwiftUI views through environment keys (`appServices(_:)`).
  Only composition roots may hold the whole `AppDependencies`.
  A container (ask for a type, get an instance) was removed deliberately: it hides who owns a thing and how long it lives, which is the question this section exists to answer.
- **Scope determines owner; nothing scoped is reached ambiently.** See [Scopes and ownership](#scopes-and-ownership) below.
  A `static shared` is legitimate only where the platform constructs the object and no initialiser parameter is available.
  Today that is `CodeFileDocument`, which is why `delegateProvider` is a static closure set at launch.
  Eight other singletons remain, listed there as known exceptions.
- No SwiftUI view observes a service directly.
  Services expose a concrete view-state object (the presentation-state split), and views issue commands through protocol-typed environment keys.

### Scopes and ownership

Four lifetimes exist.
Each has an owner, and a type belongs to the narrowest one that fits.

| Scope | Owner | Examples |
| --- | --- | --- |
| Process | `AppDependencies` | `eventBus`, `lspService`, `settingsStore`, `workspaceWindowManager` |
| Workspace | `Workspace` | `editorManager`, `workspaceFileManager`, `sourceControlManager`, `taskManager` |
| Window | `CodeEditWindowController` | `utilityAreaModel`, `statusBarViewModel`, `notificationPanel`, `openQuicklyViewModel` |
| Document | `CodeFileDocument` | per-file editing state |

Window scope is not a subdivision of workspace scope: two windows may show one project, and their utility areas, status bars and palettes must not be shared.
That is why window-UI state lives on `CodeEditWindowController` and not on `Workspace`.

Document scope is where the platform pushes back.
`NSDocument` subclasses are created by the document architecture, not by us, so no initialiser parameter is available, hence `CodeFileDocument.delegateProvider`, a static closure set at launch.
That is the shape of a legitimate exception: the platform owns construction.

**Note on idiom:** "no singletons" is not the goal and never was.
Apple's own frameworks are full of them (`NSApplication.shared`, `FileManager.default`, `NSDocumentController.shared`).
What was removed was a *container*.
A `shared` is a problem here only when it gives ambient access to something whose lifetime is narrower than the process, or when it hides an owner that could hold it.

Eight singletons remain, none load-bearing.
They are listed with the scope each actually has, plus the one that is a scope error rather than a leftover, in [docs/architecture-decisions.md](docs/architecture-decisions.md).

## Panel tab contributions

The navigator, inspector and utility area do not switch on closed enums.
Each panel is a `[any WorkspacePanelContribution]` assembled by one function per panel in `CodeEdit/WorkspaceWindow/WorkspacePanel/PanelContributions.swift`, so a first-party tab, app shell chrome and an extension's tab are the same kind of value.

**This is the pattern any future seam should follow**, and there will be others (settings pages, menu commands, the extension contract):

- The feature vends its own contribution from its own package, reading whatever it needs directly.
- The app assembles the list at a composition root.
- Whatever the contribution needs and its package cannot see becomes a **required initialiser parameter**, never a defaulted one, so a missing injection is a compile error rather than a silently empty tab.
- Vendor vocabulary stays in one adapter: `ExtensionPanelContribution` is the only app file outside `AuxiliaryWindows/Extensions/` permitted to name `AppExtensionIdentity` or `ResolvedSidebar`.

`WorkspacePanelContribution` lives in `CodeEditUI` because it needs SwiftUI and nothing else; it cannot live in `CodeEditCore`, which forbids UI imports.
Specifics of this seam, including `bottomView` and selection reconciliation, are documented on the protocol itself and in [docs/architecture-decisions.md](docs/architecture-decisions.md).

## Reading and writing settings

Feature packages reach settings through the **settings seam** in `CodeEditSettings` (`Store/SettingsValue.swift`, `Store/SettingsAccessing.swift`), never through a singleton and never by naming the app-wide `SettingsData` aggregate.
Three roles, pick by consumer kind:

| Consumer | Use | Why |
| --- | --- | --- |
| SwiftUI view | `@SettingsValue(TerminalSettings.self, \.cursorBlink)` | Observes the injected `PersistentSettingsStore`; `$`-projects a `Binding` for `Toggle`/`TextField`. |
| Read-only object (managers, services) | `SettingsReading` by initializer | No environment outside a view; narrow protocol makes read-only visible at the call site. |
| Object that also writes | `SettingsAccessing` by initializer | The read+write half; every `SettingsAccessing` satisfies `SettingsReading`. |

Access is **section-granular**: `value(_:)`/`setValue(_:)` deal in whole `SettingsSection` values, so a caller changing one field reads its section, mutates it and writes it back.

- **`@AppSettings` is app-target only.** It observes the same store as `SettingsValue`, but addresses a section field through the app-wide `SettingsData` façade instead of naming one section directly.
  There is no `Settings.shared` singleton any more, `PersistentSettingsStore` (owned by `AppDependencies`) is the concrete store, injected like everything else.
  `@AppSettings` is what 24 app-target files still use (40 declarations, re-counted 2026-08-16); feature packages must not use it, and new app-target code should prefer the seam.
- **Neither wrapper works in a `Commands` conformer.** `.commands { }` attaches beside a scene's content, not inside it, so nothing guarantees the environment `SettingsSceneInjector` supplies reaches menu-bar code.
  `CodeEditCommands`/`ViewCommands` are handed `PersistentSettingsStore` by initializer and `@ObservedObject` it, reads, writes and menu invalidation all stop depending on undocumented behaviour.
- **The environment does not cross an `NSHostingView`/`NSHostingController` boundary.** A new standalone hosting root must be wrapped in `SettingsInjector` (or `SettingsSceneInjector` for a scene), or every `@SettingsValue` under it **traps**.
  That is deliberate: this replaced a pair of environment keys whose failure modes were silent, a subtree given neither read plausible defaults and discarded writes, and a subtree given the value but not the separate `Int` invalidation key read correctly and never re-rendered.
  `@EnvironmentObject` makes both unrepresentable, because SwiftUI subscribes to the store itself.
  Those two injectors are the only places the store is injected, which is what makes the coverage question answerable by grep rather than by reachability analysis.
- **A protocol double cannot be substituted into a view.** `@EnvironmentObject` cannot carry an existential, so a view-level test injects a real `PersistentSettingsStore` on a temporary file.
  The protocol seam still applies to every initializer-injected consumer, which is where `RecordingSettingsStore` and `SnapshotSettingsReader` are used.
- **`DefaultSettingsReader` is not the environment's fallback any more** — there is no fallback.
  It survives as the stand-in four singletons (`ThemeModel`, `FeedbackModel`, `SearchSettingsModel`, `HistoryInspectorModel`) hold between construction and `configure(_:)`.
  It still `assertionFailure`s outside previews, since reaching it means a real store never arrived.
- **`PersistentSettingsStore` is the concrete store.** Section-keyed storage, owned by `AppDependencies` (no `shared`), driving the same throttled save pipeline `Settings.shared` used to own.
  Sections nothing here decodes are held verbatim and re-emitted on save, so a disabled extension's configuration survives.
  The same holds for a section that is present but *undecodable*: it reads as defaults but is re-emitted unchanged, and the one write that would replace it is announced through `SettingsStore.willReplaceUndecodableSection` so the file is copied to `settings.json.corrupt-<timestamp>` first.

### Where a settings section lives

A section lives with **its owner**:

| Readers | Home | Examples |
| --- | --- | --- |
| Exactly one feature package | that package | `TerminalSettings` → `CETerminal`, `LanguageServerSettings` → `CELSP`, `SourceControlSettings`/`AccountsSettings` → `CESourceControl` |
| More than one module, or only the app | `CodeEditSettings` | `TextEditing`, `Theme`, `General`, `Navigation`, `Developer`, `Search`, `Keybindings` |

**Never `CodeEditCore` or `CodeEditUI`.** A `Codable` config bag has no natural boundary and accretes.
That is precisely how Core became `AppPreferences` the first time, and Core's purity rationale is that the placement question stays answerable.
`CodeEditUI` is excluded mechanically: it may not depend on a local target, so it cannot see settings types at all.

**Migration trigger:** when a section's readers collapse to a single feature, it moves with that feature.
That is how the four package-owned sections got where they are.

App-only sections (`SearchSettings`, `KeybindingsSettings`) stay in `CodeEditSettings` rather than moving app-side: `SettingsFormatTests` guards the on-disk format for every section in one place using `Bundle.module` fixtures, and splitting two sections into the app target would split that guard across two bundle mechanisms to satisfy a boundary nothing enforces.

Two field-level misplacements are **recorded but not fixed**, because both keys live in users' `settings.json` and moving a field is a data migration rather than a refactor: `GeneralSettings.findNavigatorDetail` is read by `CESearch` (a feature-specific field in a shared section), and `SearchSettings.ignoreGlobPatterns` is wired to its settings page and persisted but never read by `CESearch`: the control works and has no effect, which is worse than dead code because nothing looks unused.

## Creating a new feature target

1. Create the folder `CodeEditModules/Sources/CE<Name>/` and add a target and product for it in `CodeEditModules/Package.swift`:

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

2. Link the product to the app: CodeEdit target → *General* → *Frameworks, Libraries, and Embedded Content* → add `CE<Name>`.
3. Remember the target builds with **Swift 6 strict concurrency**, types crossing actor boundaries need `Sendable`, and UI-bound classes are usually `@MainActor`.
   (`CEEditor` is the sole exception, see [Rules](#rules).)
4. Known quirk: targets that depend on `CodeEditSymbols` build via Xcode/xcodebuild only; standalone `swift build` fails on its `Bundle.module` resolution.
5. Declare **every** module you import in the manifest.
   The workspace's shared build directory makes undeclared imports of sibling targets compile by accident, CI will catch it (see below).

## Enforcement

Two tools enforce the three [Rules](#rules) above; both run on every PR:

- **SwiftLint** (`swiftlint --strict`, config in `.swiftlint.yml`), includes custom rules that reject UI imports in CodeEditCore and model/feature imports in CodeEditUI.
  These fire inside Xcode while you type.
- **The package audit** (`.github/scripts/audit_package_imports.py`), verifies every `import` in every target is declared in that target's manifest dependencies, and that the three [Rules](#rules) plus the language-mode assertion hold.
  It exists because Xcode workspace builds share one build directory, so an undeclared import of a sibling target compiles fine locally.
  For the 7 targets that transitively need `CodeEditSymbols` there is no standalone `swift build` to fall back on either (see the quirk above), so for most of the graph this audit is the only thing standing between a leaky import and `main`.

Run both locally from the repo root:

```bash
swiftlint lint --strict --quiet
python3 .github/scripts/audit_package_imports.py
```

`--strict` matters: without it SwiftLint reports violations as warnings and exits 0, so a local run looks clean and CI fails on the same tree.

### Known weakness in the CodeEditUI charter (2026-08-05)

Both checks constrain **local** targets only.
`ui_package_purity` lists sibling module names in a regex, and the audit script intersects the target's declared dependencies with the package's library targets.
So `CodeEditUI` is barred from importing `CodeEditCore`, a zero-dependency, pure-types package, while nothing stops it taking an arbitrary *external* dependency, up to and including a tree-sitter grammar bundle.
The rule as written is narrower than its own stated intent ("presentation atoms must not know about models or features") in one direction and far wider in the other.

This surfaced while deduplicating `FileIcon`, which is presentation keyed by a file's identity.
It was designed to take a `URL` rather than a domain type, so it needs neither `CodeEditCore` nor the loophole, and its three custom colorsets moved into the package as resources, making `CodeEditUI` self-contained and letting its tests assert colours without an app host.
Treat the asymmetry as a known weakness, not a licence: adding an external dependency to `CodeEditUI` to sidestep the local-package rule would satisfy the letter of the charter and defeat its purpose.

## Glossary

Several words are overloaded in this codebase.
These are the intended meanings; prefer the qualified term whenever the bare one could be read two ways.

| Term | Means |
| --- | --- |
| **Editor** (`Editor`) | One tab group inside a workspace window, a split pane with its own tab bar and selection. |
| **Editor instance** (`EditorInstance`) | One open file within an editor, holding that file's editing state. |
| **`EditorManager`** | The per-workspace owner of the editor layout (splits, the active editor). |
| **CEEditor** | The package containing the editor feature. |
| **CodeEditSourceEditor** | The external text-editing widget (a separate repository), not part of this codebase. |
| **Search** | *Project* search: find/replace across files, the index, query modes, the Find navigator. Lives in `CESearch`, which owns its whole model. |
| **Fuzzy matching** | Ranking candidates by match quality for typeahead (Open Quickly, theme and language-server pickers). A generic capability in CodeEditCore `Domain/FuzzyMatching/`. It does no searching; nothing here is named `*Search*`. |
| **Workspace** (`Workspace`) | The session aggregate for one open project: the project-scoped services and their lifetime. It owns lifecycle, *not* mutation routing, features mutate the sub-models they are handed. |
| **Workspace window** (`WorkspaceWindow/`) | The window and its chrome around a workspace: navigator, inspector, utility area, status bar. Window-UI state lives on `CodeEditWindowController`, not on `Workspace`. |
| **Document** (`CodeFileDocument`) | An open, editable file backed by NSDocument. Distinct from `CEWorkspaceFile` (a node in the file tree) and from the file on disk. |
| **Service** | A *target* holding an I/O adapter with no UI: `ShellClient`, `CEWorkspaceFileManager`. Do not use it loosely for "a long-lived object owning domain state", because most of those (`SourceControlManager`, `TaskManager`, `LSPService`) live in feature targets. |
| **Doer** | A role-noun class performing one operation that spans services (`WorkspaceOpener`, `FileMover`, `RepositoryCloner`), following the `NSFileCoordinator` naming idiom. Formerly called UseCases. |
