# CodeEdit Architecture Decisions

Questions that were asked, investigated, and settled, with the measurements that settled them.

This file exists so [ARCHITECTURE.md](../ARCHITECTURE.md) can stay short.
That guide states the rules; this one records why, and what was rejected.
Read it when you are about to reopen a decision, so you can see whether the reasoning still holds or the ground has moved.

Each entry names what was measured, because a rule documented with only its conclusion is one argument away from deletion.

## Targets that stay separate

**`ShellClient` is one file, and stays its own target** (asked and settled 2026-08-16).
Size is the wrong measure: `ShellClientProtocol` in Core is used by **19 files** across `CESourceControl` and `CELSP` (`GitClient`, `SourceControlManager`, `RegistryManager`, all five package managers), and **none of them imports the implementation**.
Only the app target does, six files, composing it at the root.
The abstraction is load-bearing, not ceremonial.

What the separate target buys, stated precisely: reaching for the implementation from a feature needs a **manifest edit**, visible in review, rather than an import line inside a file.
It is reviewability, not prevention: import honesty checks that imports are *declared*, so a feature that declared the dependency would pass the audit.
Folding it into the app target is a coherent alternative (the app is the only consumer, and composing platform adapters is a composition-root job); it would cost the manifest-level visibility and nothing else demonstrable.
**`CEWorkspaceFileManager` stays its own target, and must not merge into Core** (asked and settled 2026-08-20).
The inversion is already in place: Core declares `WorkspaceFileProviding` and `WorkspaceFileObserver`, and `CEWorkspaceFileManager.swift:263` is `extension CEWorkspaceFileManager: WorkspaceFileProviding {}`.
Four `CEEditor` files depend on the *protocol* (`EditorRestorer`, `EditorJumpBarMenu`, `EditorLayout+StateRestoration`, the environment key) and **no package imports the implementation**.
Its 22 consumers are app-side, plus 6 test files.
Same shape as `ShellClient` below: contract in Core, adapter in its own target, app composes.
See the I/O norm above for why the merge is worse than it looks.
**`CodeEditDocument` and `CELSP` both stay their own targets** (asked and settled 2026-08-20).
Neither is a leftover, and the two conclusions depend on each other.

`CEEditor` and `CELSP` reference each other **zero times, in either direction**.
They are siblings.
What keeps them apart is `LanguageServicesProvider`, declared in `CodeEditDocument`, implemented by `CELSP`'s `AppLanguageServicesProvider`, and consumed by `CEEditor` through an environment key.
It even ships a `NoOpLanguageServicesProvider`, so the editor works with no language service at all.
So `CodeEditDocument` is not "the document type plus some bridging": **it is the contract that keeps two features independent.** `CodeFileDocument` imports AppKit, SwiftUI and the editor frameworks, so it cannot live in Core; two features need it, so it cannot live in either.
Its own target is forced, not chosen.

`CELSP` is not part of the editor either.
Its consumers are the settings UI (installing servers), the utility area (reading logs) and app lifecycle (nothing in `CEEditor` imports it), and **28 of its 78 files are `Registry/`**: package managers, install steps and source parsers for Cargo, NPM, Pip, Go and GitHub.
That is downloading and installing language servers, not editing text.
Folding it into `CEEditor` would make a ~130-file target mixing the two.

The abstraction is already sound where it counts: `LanguageServer`, `LSPContentCoordinator`, `SemanticTokenHighlightProvider` and `LanguageServerDocumentObjects` are all generic over `LanguageServerDocument`, a protocol requiring only `content`, `languageServerURI` and `getLanguage()`.
Only `LSPService` itself pins the generic to `CodeFileDocument`.
Decoupling that would mean making the service generic and forcing `LSPServiceProtocol` to gain an associated type, breaking its use as an existential for DI, all to delete a five-file target.
A bad trade.
## Keeping I/O out of Core

**What the norm actually prevents** (asked 2026-08-20): merging `CEWorkspaceFileManager` into Core.
That target holds 50 `FileManager` calls and a complete FSEvents implementation, `FSEventStreamCreate` with a C callback, its own dispatch queue, and start/stop/invalidate/release.
Without this norm the merge looks reasonable, because that target depends on nothing but Core and folding it in removes a target.
With the norm it is obviously wrong: it would put a live filesystem event stream inside the dependency sink all twelve targets rest on, and end Core's filesystem-free tests the same day.
State the norm with this example, not on principle alone.
## The panel contribution seam

The first extension seam built, kept here in full because it is the worked example the later seams follow.
The reusable pattern is summarised in the guide; the specifics below live with the code as doc comments.

### Detail

The navigator, inspector and utility area no longer switch on closed enums (`NavigatorTab`, `InspectorTab`, `UtilityAreaTab`).
Each panel is a list of `WorkspacePanelContribution` values, so a tab is a value, not a case, assembled by one function per panel in `CodeEdit/WorkspaceWindow/WorkspacePanel/PanelContributions.swift`: first-party entries named directly, conditional ones (`InternalDevelopmentInspectorContribution`) as a plain `if`, then extension-provided ones appended through a single adapter call.
The panel that renders the list cannot tell a first-party tab from an extension's.
That indistinguishability is the point; it is what lets a new contribution source arrive without the panel code changing.

`WorkspacePanelContribution` lives in `CodeEditUI` (`CodeEditModules/Sources/CodeEditUI/WorkspacePanelContribution.swift`), not `CodeEditCore`: a contribution vends a `content: AnyView`, and Core's charter (rule 1, above) forbids UI imports outright.
`CodeEditUI`'s own charter (rule 2) is satisfied too: the protocol needs SwiftUI and nothing else.

A contribution vends two views.
`content` is the tab itself.
`bottomView` is an optional bar pinned below it.
The navigator's filter field and sort controls are the existing examples.
It defaults to `nil` so a tab with no such bar says nothing about it.
It is a *requirement* rather than something the panel is handed deliberately: it arrived from upstream as a `switch` over the retired tab enum, where every new tab had to remember to add its case, and a package could not contribute one at all because the switch lived app-side.
Vended by the contribution, a tab cannot forget, and where the bar is placed stays the panel's business: pre-Tahoe it insets the tab's own content, and from macOS 26 it spans the panel below the tab bar.

**A panel's tab list changes at runtime**, so a stored selection can outlive the tab it names: the inspector rebuilds its list when a setting changes, and any panel's list changes when an extension is enabled or disabled.
`Collection.reconcilingSelection(_:)` (alongside the protocol) keeps a selection that still resolves and otherwise falls back to the first tab; `WorkspacePanelView` applies it on appear and on every change to the list.
Without it the panel reads "No Selection" until the user clicks something, because the stored id is stale rather than absent and nothing recovers on its own.
The rule lives in the package rather than the view so it holds for every panel and can be tested without one.

A contribution's owner follows the same placement rule as everything else in [Where does my code go?](#where-does-my-code-go): a feature that owns a tab vends its own contribution from its package, reading whatever it needs (including settings, through the seam) directly rather than having the app assemble it.
`CESearch`'s `FindNavigatorContribution` (`CodeEditModules/Sources/CESearch/FindNavigatorContribution.swift`) replaced an app-side `FindNavigatorTab` wrapper that existed only to shuttle settings values down.
Once the feature could read its own settings, the wrapper had no reason to exist.
The tab's id is now owned by the same package (`FindNavigatorContribution.tabID`); the app's `PanelTabID.search` references it rather than duplicating the literal, so there is exactly one source of truth even though the app still needs a compile-checked constant to select the tab by.

`ProjectNavigatorContribution` (`CodeEdit/WorkspaceWindow/NavigatorArea/NavigatorContributions.swift`) stays app-side, not because it is a tab (see the [chrome exemption correction](#where-does-my-code-go)) but because the project navigator has no owning package to move to.
The same holds for the file inspector, the internal-development inspector, and the debug and output utility tabs.
`TerminalUtilityContribution` is the one that should move, to `CETerminal`; it has not because it is coupled to app-side utility-area chrome.

`CESourceControl` is the second feature package to own a panel tab, after `CESearch`.
`SourceControlNavigatorContribution` and `GitHistoryInspectorContribution` (`CodeEditModules/Sources/CESourceControl/SourceControlNavigator/` and `.../HistoryInspector/`) vend `SourceControlNavigatorView` and `HistoryInspectorView` from the package; the app-side `WorkspaceWindow/NavigatorArea/SourceControlNavigator/` and `WorkspaceWindow/InspectorArea/HistoryInspector/` groups no longer exist.
The relocation is the shape a future one follows: whatever the view needs that the package cannot see becomes a **required** initialiser parameter on the contribution (`WorkspaceNavigator` for the navigator tab, `ActiveEditorState` for the inspector tab) rather than an environment key moved down with it; both are non-optional so a missing injection at the call site (`PanelContributions.swift`) is a compile error, not a silently no-op tab.
Each contribution still owns its own `tabID` constant, and the app's `PanelTabID.sourceControl` / `.gitHistory` reference it rather than duplicating the literal, same as `PanelTabID.search`.
A third relocation onto this shape is expected.

Extensions are the third contribution source.
`ExtensionPanelContribution` (`CodeEdit/WorkspaceWindow/WorkspacePanel/ExtensionPanelContribution.swift`) is the **only** app file, outside the pre-existing extension-management UI under `AuxiliaryWindows/Extensions/`, that may name `AppExtensionIdentity` or `ResolvedSidebar`.
Confining ExtensionKit's vocabulary to this one adapter is what let the app-side panel-contribution list above be written without an ExtensionKit import in sight, and is what would let a second, non-ExtensionKit contribution source arrive later without touching the panels.

## What the Core charter has produced

The friction this produces is usually the rule working.
Four worked examples already in this codebase: `FileIcon` is keyed on `URL` rather than a domain type, so it needs neither `CodeEditCore` nor a charter exception (see rule 2 below); `WorkspacePanelContribution` was shaped to need only SwiftUI, so it lives in `CodeEditUI` (`CodeEditModules/Sources/CodeEditUI/WorkspacePanelContribution.swift`); fuzzy matching's concurrency helper was rewritten over `withTaskGroup` rather than admit `CollectionConcurrencyKit` (below); and `ActiveTheme`, the active light/dark theme, observed by the editor and terminal, lives *in* Core, because `ObservableObject` comes from Combine rather than SwiftUI.
That last one is worth remembering: the charter forbids `SwiftUI`/`AppKit`/`Cocoa` specifically, so observation is available in Core and an "it needs to be observable, therefore it needs SwiftUI" argument is simply false.

The counter-example people will cite: `TextEditingSettings` and `TerminalSettings.Font` carry `NSFont.Weight`, which forces them out of Core.
That is the rule flagging a presentation type inside a settings model, not the rule obstructing a reasonable design.
Storing the weight as a `Double` and converting at the presentation boundary would make both structs Core-eligible with no rule change.
## Singletons that remain

Recorded 2026-08-16.

Eight singletons remain.
None is load-bearing; each is listed with the scope it actually has.

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

The first seven are process-scoped services that simply have not moved to `AppDependencies`; doing so is mechanical and changes no behaviour.

`TerminalCache` is different, and is the one worth fixing rather than relocating.
It is a process-global `[UUID: CELocalShellTerminalView]` holding views that belong to a workspace window.
Eviction is per-terminal only, and nothing clears it when a workspace or window closes, so two open projects share one bag of live terminal views.
It works because UUIDs do not collide, but the lifetime is wrong, and a wrong lifetime surfaces as a leak rather than as a compile error.

## Document isolation is bridged, not solved

`CodeFileDocument` moved into `CodeEditDocument` during the package extraction, which put it under Swift 6 strict concurrency for the first time.
That surfaced six pre-existing isolation errors, all in code that is byte-identical on `main` and compiles silently there.

`NSDocument` is main-actor isolated, but declares `read(from:ofType:)` and `presentedItemDidChange()` nonisolated, because AppKit may call them off the main thread.
Both touch main-actor document state.
Three things now hold that together, and none of them is a static guarantee:

1. `canConcurrentlyReadDocuments(ofType:)` is overridden to return `false`, pinning AppKit's default so its own reads stay on the main thread. Returning `true` would make that half unsound with no compile error.
2. All four sites that touch main-actor state from a nonisolated override branch on `Thread.isMainThread` and use `MainActor.assumeIsolated` on the main-thread side: `read(from:ofType:)`, `presentedItemDidChange()`, `notifyLSPDidOpen()`/`notifyLSPDidClose(_:)`, and `registerContentChangeUndo`. The pin is not load-bearing on its own, because it says nothing about an in-process caller constructing a document off the main actor, which has happened here before and trapped a bare `assumeIsolated`.
3. Two of the four block rather than hop. `read(from:ofType:)` must, because `NSDocument` requires the document loaded by the time it returns; `presentedItemDidChange()` must, or repeated change notifications pile up. Both therefore carry a `DispatchQueue.main.sync`, whose safety rests on no caller blocking the main thread while triggering an off-main read. Nothing enforces that.

This is accepted as a bridge so the extraction can land, not as the end state.
The real problem is that the type mixes main-actor UI state (`content` is an `NSTextStorage` that SwiftUI observes) with an I/O lifecycle driven from arbitrary threads.
Separating those, so decoding produces a `Sendable` value that a single main-actor step installs, removes all three props at once.
That is a redesign of the document's state ownership and is deliberately deferred.

The general lesson is worth stating separately, because it applies to every future extraction: **moving a file into `CodeEditModules` is also a Swift 6 migration of that file.**
The app target is `SWIFT_VERSION = 5.0` with no `SWIFT_STRICT_CONCURRENCY` setting, so it defaults to `minimal`; the package is `swift-tools-version: 6.0`, so every target defaults to Swift 6 language mode.
Code that compiled without complaint for years can arrive in a package with a dozen errors, none of them regressions.

## The app is not sandboxed

`ENABLE_APP_SANDBOX = NO` on all five app and app-hosted-test build configurations, and
`CodeEdit.entitlements` carries no `com.apple.security.app-sandbox` key.
This is deliberate and is the project's long-standing configuration, not a workaround left in place.

The App Sandbox blocks `Process` from spawning subprocesses, and CodeEdit's core features are built on exactly that.
`ShellClient` spawns `/bin/zsh`; `CETerminal` (`Shell`, `CELocalShellTerminalView`) runs the user's shell; `RepositoryCloner` and the rest of source control shell out to `git`, which itself shims through `xcrun`.
Sandboxed, all of these fail with `xcrun: error: cannot be used within an App Sandbox.`

The history is worth recording because it has already been changed once by accident.
Community PR #2147 (commit `78c3be9c`, 2025-12-12) enabled the sandbox as part of an unrelated deprecations and memory-leak fix, which broke git, LSP, the terminal, and package installs.
Commit `a2fff0c9` reverted to the pre-#2147 configuration and restored the `com.apple.security.cs.allow-jit` and `com.apple.security.cs.disable-library-validation` exceptions it had removed.
Anyone tempted to enable the sandbox should read this section first: it is not a build-setting toggle.

Two consequences follow.
Mac App Store distribution is out of scope, since the store requires sandboxing, and getting there would mean rearchitecting every subprocess path rather than flipping a flag.
And the security-scoped bookmark handling added for recents (`WorkspaceFactory`, `Workspace.tearDown`) is a no-op while unsandboxed, because `startAccessingSecurityScopedResource()` returns `false`; it is kept so the code stays correct if this decision is ever revisited.

