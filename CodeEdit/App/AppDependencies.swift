//
//  AppDependencies.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 10/07/2026.
//

import CELSP
import CodeEditCore
import CodeEditDocument
import CodeEditSettings
import CENotifications
import ShellClient

/// The app-scope composition root. Owns every process-lifetime service and is the only
/// place where interfaces are bound to implementations.
///
/// Ownership: `AppDelegate` creates the single instance; `CodeEditApp` reads it through the
/// delegate adaptor. Only composition roots (`AppDelegate`, `CodeEditApp`,
/// `WorkspaceWindowManager` and its use cases, `WorkspaceFactory`, the window controllers)
/// may hold this whole object — everything else declares the specific dependencies it needs,
/// via initializer parameters (objects) or environment keys (views, see `appServices(_:)`).
///
/// Properties are `lazy` to preserve on-first-use construction timing (`RegistryManager`
/// performs I/O when created) and to let `workspaceWindowManager`-adjacent adapters
/// reference sibling properties without initialization-order cycles.
@MainActor
final class AppDependencies {
    private(set) lazy var eventBus = EventBus()

    private(set) lazy var shellClient: ShellClientProtocol = ShellClient()

    /// The app's settings: the one store, owned here rather than reached through a singleton.
    ///
    /// Concrete (not `SettingsAccessing`) because the injectors also need its `revision` publisher
    /// to observe. Consumers that only read or write settings take ``settingsAccessor`` instead.
    private(set) lazy var settingsStore = AppSettingsStore()

    /// Feature-side settings access, read and write. The same object as ``settingsStore``, narrowed
    /// to the seam's protocol so nothing outside the composition root names the concrete type.
    private(set) lazy var settingsAccessor: SettingsAccessing = settingsStore

    private(set) lazy var commandManager: CommandManaging = CommandManager()

    private(set) lazy var keybindingManager: KeybindingManaging = KeybindingManager()

    private(set) lazy var notificationManager: NotificationManaging = NotificationManager(eventBus: eventBus)

    /// The single Sparkle updater controller. One instance app-wide: the "Check for
    /// Updates" menu action and the Settings auto-update toggles must observe the same
    /// `SPUUpdater`, or their state drifts apart.
    private(set) lazy var softwareUpdater = SoftwareUpdater()

    private(set) lazy var lspService: LSPService = {
        let service = LSPService(settingsReader: settingsAccessor)
        // Property-injected (not init-injected): the window manager's construction consumes
        // `lspService`, so init injection in both directions would recurse. Resolved at call
        // time, long after both objects exist.
        service.workspaceFinder = { [weak self] url in
            self?.workspaceWindowManager.workspace(containing: url)?.fileURL
        }
        return service
    }()

    private(set) lazy var errorNotifier: ErrorNotifying = AppErrorNotifier(notificationManager: notificationManager)

    private(set) lazy var registryManager = RegistryManager(
        eventBus: eventBus,
        errorNotifier: errorNotifier,
        shellClient: shellClient,
        settingsAccessor: settingsAccessor,
        // Handed its install location rather than reading it from a singleton. A later slice gives
        // `RegistryManager` a proper home for this path; until then the composition root supplies it.
        installPath: settingsStore.baseURL.appending(path: "Language Servers")
    )

    private(set) lazy var workspaceWindowManager = WorkspaceWindowManager(dependencies: self)

    // MARK: - Command-interface adapters (stateless routers over the window manager)

    private(set) lazy var workspaceFileOpener: WorkspaceFileOpener =
        AppWorkspaceFileOpener(windowManager: workspaceWindowManager)

    private(set) lazy var workspaceNavigator: WorkspaceNavigator =
        AppWorkspaceNavigator(windowManager: workspaceWindowManager)

    private(set) lazy var fileRelocator: FileRelocator =
        AppFileRelocator(windowManager: workspaceWindowManager)

    private(set) lazy var languageServicesProvider: LanguageServicesProvider =
        AppLanguageServicesProvider(lspService: lspService)

    // MARK: - Wiring that must not wait for a delegate callback

    init() {
        installSettingsStore()
    }

    /// Hands the settings store to the three pre-existing singletons that cannot take it through
    /// their own `init`, before anything can read them.
    ///
    /// Deliberately here and not in an `AppDelegate` callback. It first lived in
    /// `applicationDidFinishLaunching`, which `application(_:open urls:)` can beat: launching by
    /// double-clicking a folder in Finder, or via a `codeedit://` URL at cold start, opens a
    /// workspace window before that callback runs. `ThemeModel` would then still hold
    /// `DefaultSettingsReader` — a debug trap, and in release a crash, because
    /// `CodeEditWindowController` force-unwraps `ThemeModel.shared.themes.first!` on an array that
    /// never loaded. The singleton these replaced was immune to that ordering; this is.
    ///
    /// `AppDelegate` holds `dependencies` as a non-lazy stored property, so this runs while the
    /// delegate itself is being initialized — before *any* delegate callback, not merely before the
    /// one that happened to be a problem. Moving it to `applicationWillFinishLaunching` would fix
    /// today's ordering and leave the next earlier callback free to reintroduce it.
    ///
    /// The cost is that `settingsStore` and `ThemeModel` are built eagerly rather than on first use,
    /// which front-loads reading `settings.json` and the theme files. Both are read by the first
    /// window anyway, so this moves the work earlier rather than adding it.
    private func installSettingsStore() {
        ThemeModel.shared.configure(settings: settingsAccessor)
        FeedbackModel.shared.settingsAccessor = settingsAccessor
        SearchSettingsModel.shared.configure(settings: settingsAccessor)
    }

    // MARK: - Command-interface adapters, continued

    private(set) lazy var codeFileDocumentDelegate: CodeFileDocumentDelegate =
        AppCodeFileDocumentDelegate(
            lspService: lspService,
            windowManager: workspaceWindowManager,
            languageServices: languageServicesProvider,
            settingsStore: settingsStore
        )
}
