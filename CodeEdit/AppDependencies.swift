//
//  AppDependencies.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 10/07/2026.
//

import CodeEditCore
import CodeEditDocument
import Notifications
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

    private(set) lazy var commandManager: CommandManaging = CommandManager()

    private(set) lazy var keybindingManager: KeybindingManaging = KeybindingManager()

    private(set) lazy var notificationManager: NotificationManaging = NotificationManager(eventBus: eventBus)

    private(set) lazy var lspService: LSPService = {
        let service = LSPService(notificationManager: notificationManager)
        // Property-injected (not init-injected): the window manager's construction consumes
        // `lspService`, so init injection in both directions would recurse. Resolved at call
        // time, long after both objects exist.
        service.workspaceFinder = { [weak self] url in
            self?.workspaceWindowManager.workspace(containing: url)
        }
        return service
    }()

    private(set) lazy var registryManager = RegistryManager(
        eventBus: eventBus,
        notificationManager: notificationManager,
        shellClient: shellClient
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

    private(set) lazy var codeFileDocumentDelegate: CodeFileDocumentDelegate =
        AppCodeFileDocumentDelegate(
            lspService: lspService,
            windowManager: workspaceWindowManager,
            languageServices: languageServicesProvider
        )
}
