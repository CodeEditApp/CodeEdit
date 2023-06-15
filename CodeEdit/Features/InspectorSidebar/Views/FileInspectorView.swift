//
//  FileInspectorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI

struct FileInspectorView: View {

    @ObservedObject
    private var inspectorModel: FileInspectorModel

    /// Initialize with GitClient
    /// - Parameter gitClient: a GitClient
    init(workspaceURL: URL, fileURL: String) {
        self.inspectorModel = .init(workspaceURL: workspaceURL, fileURL: fileURL)
    }

    var body: some View {
        Form {
            Section("Identity and Type") {
                fileName
                fileType
            }
            Section {
                location
            }
            Section("Text Settings") {
                textEncoding
                lineEndings
            }
            Section {
                indentUsing
                tabWidths
                wrapLines
            }
        }
    }

    private var fileName: some View {
        TextField("Name", text: $inspectorModel.fileName)
    }

    private var fileType: some View {
        Picker("Type", selection: $inspectorModel.fileTypeSelection) {
            Group {
                Section(header: Text("Sourcecode Objective-C")) {
                    ForEach(inspectorModel.languageTypeObjCList) {
                        Text($0.name)
                    }
                }
                Section(header: Text("Sourcecode C")) {
                    ForEach(inspectorModel.sourcecodeCList) {
                        Text($0.name)
                    }
                }
                Section(header: Text("Sourcecode C++")) {
                    ForEach(inspectorModel.sourcecodeCPlusList) {
                        Text($0.name)
                    }
                }
                Section(header: Text("Sourcecode Swift")) {
                    ForEach(inspectorModel.sourcecodeSwiftList) {
                        Text($0.name)
                    }
                }
                Section(header: Text("Sourcecode Assembly")) {
                    ForEach(inspectorModel.sourcecodeAssemblyList) {
                        Text($0.name)
                    }
                }
            }
            Group {
                Section(header: Text("Sourcecode Objective-C")) {
                    ForEach(inspectorModel.sourcecodeScriptList) {
                        Text($0.name)
                    }
                }
                Section(header: Text("Property List / XML")) {
                    ForEach(inspectorModel.propertyList) {
                        Text($0.name)
                    }
                }
                Section(header: Text("Shell Script")) {
                    ForEach(inspectorModel.shellList) {
                        Text($0.name)
                    }
                }
                Section(header: Text("Mach-O")) {
                    ForEach(inspectorModel.machOList) {
                        Text($0.name)
                    }
                }
                Section(header: Text("Text")) {
                    ForEach(inspectorModel.textList) {
                        Text($0.name)
                    }
                }
            }
            Group {
                Section(header: Text("Audio")) {
                    ForEach(inspectorModel.audioList) {
                        Text($0.name)
                    }
                }
                Section(header: Text("Image")) {
                    ForEach(inspectorModel.imageList) {
                        Text($0.name)
                    }
                }
                Section(header: Text("Video")) {
                    ForEach(inspectorModel.videoList) {
                        Text($0.name)
                    }
                }
                Section(header: Text("Archive")) {
                    ForEach(inspectorModel.archiveList) {
                        Text($0.name)
                    }
                }
                Section(header: Text("Other")) {
                    ForEach(inspectorModel.otherList) {
                        Text($0.name)
                    }
                }
            }
        }
    }

    private var location: some View {
        Group {
            LabeledContent("Location") {
                Button("Choose...") {
                    // open open dialog
                }
            }
            ExternalLink(showInFinder: true, destination: URL(fileURLWithPath: inspectorModel.fileURL)) {
                Text(inspectorModel.fileURL)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var textEncoding: some View {
        Picker("Text Encoding", selection: $inspectorModel.textEncodingSelection) {
            ForEach(inspectorModel.textEncodingList) {
                Text($0.name)
            }
        }
    }

    private var lineEndings: some View {
        Picker("Line Endings", selection: $inspectorModel.lineEndingsSelection) {
            ForEach(inspectorModel.lineEndingsList) {
                Text($0.name)
            }
        }
    }

    private var indentUsing: some View {
        Picker("Indent Using", selection: $inspectorModel.indentUsingSelection) {
            ForEach(inspectorModel.indentUsingList) {
                Text($0.name)
            }
        }
    }

    private var tabWidths: some View {
        LabeledContent("Widths") {
            HStack(spacing: 5) {
                VStack(alignment: .center, spacing: 0) {
                    Stepper(
                        "",
                        value: Binding<Double>(
                            get: { Double(inspectorModel.tabWidth) },
                            set: { inspectorModel.tabWidth = Int($0) }
                        ),
                        in: 1...8,
                        step: 1,
                        format: .number
                    )
                    .labelsHidden()
                    Text("Tab")
                        .foregroundColor(.primary)
                        .font(.footnote)
                }
                VStack(alignment: .center, spacing: 0) {
                    Stepper(
                        "",
                        value: Binding<Double>(
                            get: { Double(inspectorModel.indentWidth) },
                            set: { inspectorModel.indentWidth = Int($0) }
                        ),
                        in: 1...8,
                        step: 1,
                        format: .number
                    )
                    .labelsHidden()
                    Text("Indent")
                        .foregroundColor(.primary)
                        .font(.footnote)
                }
            }
        }
    }

    private var wrapLines: some View {
        Toggle(isOn: $inspectorModel.wrapLines) {
            Text("Wrap lines")
        }
    }
}
