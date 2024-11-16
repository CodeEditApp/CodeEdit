import SwiftUI

struct InspectorAreaView: View {
    @EnvironmentObject private var workspace: WorkspaceDocument

    @ObservedObject private var extensionManager = ExtensionManager.shared
    @ObservedObject public var viewModel: InspectorAreaViewModel

    @EnvironmentObject private var editorManager: EditorManager

    @AppSettings(\.sourceControl.general.sourceControlIsEnabled)
    private var sourceControlIsEnabled: Bool

    @AppSettings(\.general.inspectorTabBarPosition)
    var sidebarPosition: SettingsData.SidebarTabBarPosition

    @State private var selection: InspectorTab? = .file

    init(viewModel: InspectorAreaViewModel) {
        self.viewModel = viewModel
        updateTabItems()
    }

    func getExtension(_ id: String) -> ExtensionInfo? {
        return extensionManager.extensions.first(
            where: { $0.endpoint.bundleIdentifier == id }
        )
    }

    var body: some View {
        VStack {
            if let selection {
                selection
            } else {
                NoSelectionInspectorView()
            }
        }
        .safeAreaInset(edge: .trailing, spacing: 0) {
            if sidebarPosition == .side {
                HStack(spacing: 0) {
                    Divider()
                    AreaTabBar(items: $viewModel.tabItems, selection: $selection, position: sidebarPosition)
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if sidebarPosition == .top {
                VStack(spacing: 0) {
                    Divider()
                    AreaTabBar(items: $viewModel.tabItems, selection: $selection, position: sidebarPosition)
                    Divider()
                }
            } else {
                Divider()
            }
        }
        .formStyle(.grouped)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("inspector")
        .onChange(of: sourceControlIsEnabled) { _ in
            updateTabItems()
        }
    }

    private func updateTabItems() {
        viewModel.tabItems = [.file] +
            (sourceControlIsEnabled ? [.gitHistory] : []) +
            extensionManager
                .extensions
                .flatMap { ext in
                    ext.availableFeatures.compactMap {
                        if case .sidebarItem(let data) = $0, data.kind == .inspector {
                            return InspectorTab.uiExtension(endpoint: ext.endpoint, data: data)
                        }
                        return nil
                    }
                }
        if let selectedTab = selection,
            !viewModel.tabItems.isEmpty &&
            !viewModel.tabItems.contains(selectedTab) {
            selection = viewModel.tabItems[0]
        }
    }
}
