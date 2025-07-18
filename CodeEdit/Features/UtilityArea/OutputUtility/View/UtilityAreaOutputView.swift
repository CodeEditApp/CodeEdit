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

        var title: String {
            switch self {
            case .extensions(let source):
                "Extension - \(source.extensionInfo.name)"
            case .languageServer(let source):
                "Language Server - \(source.id)"
            case .devOutput:
                "Internal Development Output"
            }
        }

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

    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    @State private var filterText: String = ""
    @State private var selectedSource: Sources?

    var body: some View {
        UtilityAreaTabView(model: utilityAreaViewModel.tabViewModel) { _ in
            Group {
                if let selectedSource {
                    switch selectedSource {
                    case .extensions(let source):
                        UtilityAreaOutputLogList(source: source, filterText: $filterText) {
                            UtilityAreaOutputSourcePicker(selectedSource: $selectedSource)
                        }
                    case .languageServer(let source):
                        UtilityAreaOutputLogList(source: source, filterText: $filterText) {
                            UtilityAreaOutputSourcePicker(selectedSource: $selectedSource)
                        }
                    case .devOutput:
                        UtilityAreaOutputLogList(
                            source: InternalDevelopmentOutputSource.shared,
                            filterText: $filterText
                        ) {
                            UtilityAreaOutputSourcePicker(selectedSource: $selectedSource)
                        }
                    }
                } else {
                    Text("No output")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .frame(maxHeight: .infinity)
                        .paneToolbar {
                            UtilityAreaOutputSourcePicker(selectedSource: $selectedSource)
                            Spacer()
                            UtilityAreaFilterTextField(title: "Filter", text: $filterText)
                                .frame(maxWidth: 175)
                            Button { } label: {
                                Image(systemName: "trash")
                            }
                            .disabled(true)
                        }
                }
            }
        }
    }
}
