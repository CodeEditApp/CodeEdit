//
//  UtilityAreaOutputView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI
import LogStream

struct UtilityAreaOutputView: View {
    enum Sources: Hashable {
        case extensions(ExtensionUtilityAreaOutputSource)
        case languageServer(LanguageServerLogContainer)
        case devOutput

        public static func == (_ lhs: Sources, _ rhs: Sources) -> Bool {
            switch (lhs, rhs) {
            case let (.extensions(lhs), .extensions(rhs)):
                return lhs.id == rhs.id
            case let (.languageServer(lhs), .languageServer(rhs)):
                return lhs.id == rhs.id
            case (.devOutput, .devOutput):
                return true
            default:
                return false
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
            case .extensions(let source):
                hasher.combine(0)
                hasher.combine(source.id)
            case .languageServer(let source):
                hasher.combine(1)
                hasher.combine(source.id)
            case .devOutput:
                hasher.combine(2)
            }
        }
    }

    @AppSettings(\.developerSettings.showInternalDevelopmentInspector)
    var showInternalDevelopmentInspector

    @EnvironmentObject private var workspace: WorkspaceDocument
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel
    @ObservedObject var extensionManager = ExtensionManager.shared
    @Service var lspService: LSPService

    @State private var filterText: String = ""
    @State private var selectedSource: Sources?

    var languageServerClients: [LSPService.LanguageServerType] {
        lspService.languageClients.compactMap { (key: LSPService.ClientKey, value: LSPService.LanguageServerType) in
            if key.workspacePath == workspace.fileURL?.absolutePath {
                return value
            }
            return nil
        }
    }

    var body: some View {
        UtilityAreaTabView(model: utilityAreaViewModel.tabViewModel) { _ in
            Group {
                if let selectedSource {
                    switch selectedSource {
                    case .extensions(let source):
                        OutputView(source: source, filterText: $filterText)
                    case .languageServer(let source):
                        OutputView(source: source, filterText: $filterText)
                    case .devOutput:
                        OutputView(source: InternalDevelopmentOutputSource.shared, filterText: $filterText)
                    }
                } else {
                    Text("No output")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .frame(maxHeight: .infinity)
                }
            }
            .paneToolbar {
                Picker("Output Source", selection: $selectedSource) {
                    if selectedSource == nil {
                        Text("No Selection")
                            .tag(nil as Sources?)
                    }

                    if extensionManager.extensions.isEmpty {
                        Text("No Extensions")
                    }
                    ForEach(extensionManager.extensions) { extensionInfo in
                        Text(extensionInfo.name)
                            .tag(Sources.extensions(.init(extensionInfo: extensionInfo)))
                    }
                    Divider()

                    if languageServerClients.isEmpty {
                        Text("No Language Servers")
                    }
                    ForEach(languageServerClients, id: \.languageId) { server in
                        Text(server.languageId.rawValue)
                            .tag(Sources.languageServer(server.logContainer))
                    }

                    if showInternalDevelopmentInspector {
                        Divider()
                        Text("Development Output")
                            .tag(Sources.devOutput)
                    }
                }
                .buttonStyle(.borderless)
                .labelsHidden()
                .controlSize(.small)
                Spacer()
                UtilityAreaFilterTextField(title: "Filter", text: $filterText)
                    .frame(maxWidth: 175)
//                Button {
//                    output = []
//                } label: {
//                    Image(systemName: "trash")
//                }
            }
        }
    }

    struct OutputView<Source: UtilityAreaOutputSource>: View {
        let source: Source

        @State var output: [Source.Message] = []
        @Binding var filterText: String

        var filteredOutput: [Source.Message] {
            if filterText.isEmpty {
                return output
            }
            return output.filter { item in
                return filterText == "" ? true : item.message.contains(filterText)
            }
        }

        var body: some View {
            List(filteredOutput.reversed()) { item in
                VStack(spacing: 2) {
                    HStack(spacing: 0) {
                        Text(item.message)
                            .fontDesign(.monospaced)
                            .font(.system(size: 12, weight: .regular).monospaced())
                        Spacer(minLength: 0)
                    }
                    HStack(spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: item.level.iconName)
                                .foregroundColor(.white)
                                .font(.system(size: 7, weight: .semibold))
                                .frame(width: 12, height: 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(item.level.color)
                                        .aspectRatio(1.0, contentMode: .fit)
                                )
                            Text(item.date.logFormatted())
                                .fontWeight(.medium)
                        }
                        if let subsystem = item.subsystem {
                            HStack(spacing: 2) {
                                Image(systemName: "gearshape.2")
                                    .font(.system(size: 8, weight: .regular))
                                Text(subsystem)
                            }
                        }
                        if let category = item.category {
                            HStack(spacing: 2) {
                                Image(systemName: "square.grid.3x3")
                                    .font(.system(size: 8, weight: .regular))
                                Text(category)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(.secondary)
                    .font(.system(size: 9, weight: .semibold).monospaced())
                }
                .rotationEffect(.radians(.pi))
                .scaleEffect(x: -1, y: 1, anchor: .center)
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                .listRowBackground(item.level.backgroundColor)
            }
            .listStyle(.plain)
            .listRowInsets(EdgeInsets())
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
            .task(id: source.id) {
                output = source.cachedMessages()
                for await item in source.streamMessages() {
                    output.append(item)
                }
            }
        }
    }
}
