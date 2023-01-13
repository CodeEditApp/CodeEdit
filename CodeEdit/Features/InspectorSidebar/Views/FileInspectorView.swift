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
        VStack(alignment: .leading, spacing: 5) {
            InspectorSection("Identity and Type") {
                InspectorField("Name") {
                    TextField("", text: $inspectorModel.fileName)
                }
                InspectorField("Type") {
                    fileType
                }
                Divider()
                InspectorField("Location") {
                    location
                    HStack {
                        Text(inspectorModel.fileName)
                            .font(.system(size: 11))
                        Spacer()
                        Image(systemName: "folder.fill")
                            .resizable()
                            .foregroundColor(.secondary)
                            .frame(width: 12, height: 10)
                    }
                }
                InspectorField("Full Path") {
                    HStack(alignment: .bottom) {
                        Text(inspectorModel.fileURL)
                            .foregroundColor(.primary)
                            .fontWeight(.regular)
                            .font(.system(size: 11))
                            .lineLimit(4)
                        Image(systemName: "arrow.forward.circle.fill")
                            .resizable()
                            .foregroundColor(.secondary)
                            .frame(width: 10, height: 10)
                    }
                    .padding(.top, 2)
                }
            }
            InspectorSection("Text Settings") {
                InspectorField("Text Encoding") {
                    textEncoding
                }
                InspectorField("Line Endings") {
                    lineEndings
                }
                Divider()
                InspectorField("Indent Using") {
                    indentUsing
                }
                InspectorField("Widths") {
                    tabWidths
                }
            }
        }
        .controlSize(.small)
        .frame(maxWidth: 250)
        .padding(.horizontal, 8)
        .padding(.vertical, 1)
    }

    private var fileType: some View {
        Picker("", selection: $inspectorModel.fileTypeSelection) {
            Group {
                Section(header: Text("Sourcecode Objective-C")) {
                    ForEach(inspectorModel.languageTypeObjCList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Sourcecode C")) {
                    ForEach(inspectorModel.sourcecodeCList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Sourcecode C++")) {
                    ForEach(inspectorModel.sourcecodeCPlusList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Sourcecode Swift")) {
                    ForEach(inspectorModel.sourcecodeSwiftList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Sourcecode Assembly")) {
                    ForEach(inspectorModel.sourcecodeAssemblyList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
            }
            Group {
                Section(header: Text("Sourcecode Objective-C")) {
                    ForEach(inspectorModel.sourcecodeScriptList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Property List / XML")) {
                    ForEach(inspectorModel.propertyList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Shell Script")) {
                    ForEach(inspectorModel.shellList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Mach-O")) {
                    ForEach(inspectorModel.machOList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Text")) {
                    ForEach(inspectorModel.textList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
            }
            Group {
                Section(header: Text("Audio")) {
                    ForEach(inspectorModel.audioList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Image")) {
                    ForEach(inspectorModel.imageList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Video")) {
                    ForEach(inspectorModel.videoList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Archive")) {
                    ForEach(inspectorModel.archiveList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Other")) {
                    ForEach(inspectorModel.otherList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
            }
        }
        .labelsHidden()
    }

    private var location: some View {
        Picker("", selection: $inspectorModel.locationSelection) {
            ForEach(inspectorModel.locationList) {
                Text($0.name)
                    .font(.system(size: 11))
            }
        }
        .labelsHidden()
    }

    private var textEncoding: some View {
        Picker("", selection: $inspectorModel.textEncodingSelection) {
            ForEach(inspectorModel.textEncodingList) {
                Text($0.name)
                    .font(.system(size: 11))
            }
        }
        .labelsHidden()
    }

    private var lineEndings: some View {
        Picker("", selection: $inspectorModel.lineEndingsSelection) {
            ForEach(inspectorModel.lineEndingsList) {
                Text($0.name)
                    .font(.system(size: 11))
            }
        }
        .labelsHidden()
    }

    private var indentUsing: some View {
        Picker("", selection: $inspectorModel.indentUsingSelection) {
            ForEach(inspectorModel.indentUsingList) {
                Text($0.name)
                    .font(.system(size: 11))
            }
        }
        .labelsHidden()
    }

    private var tabWidths: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(alignment: .top, spacing: 2) {
                    VStack(alignment: .center, spacing: 0) {
                        TextField("", value: $inspectorModel.tabWidth, formatter: NumberFormatter())
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.trailing)
                        Text("Tab")
                            .foregroundColor(.primary)
                            .fontWeight(.regular)
                            .font(.system(size: 10))
                    }
                    Stepper(value: $inspectorModel.tabWidth, in: 1...8) {
                        EmptyView()
                    }
                    .padding(.top, 1)
                }
                HStack(alignment: .top, spacing: 2) {
                    VStack(alignment: .center, spacing: 0) {
                        TextField("", value: $inspectorModel.indentWidth, formatter: NumberFormatter())
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.trailing)
                        Text("Indent")
                            .foregroundColor(.primary)
                            .fontWeight(.regular)
                            .font(.system(size: 10))
                    }
                    Stepper(value: $inspectorModel.indentWidth, in: 1...8) {
                        EmptyView()
                    }
                    .padding(.top, 1)
                }
            }
            Toggle(isOn: $inspectorModel.wrapLines) {
                Text("Wrap lines")
            }.toggleStyle(CheckboxToggleStyle())
                .padding(.vertical, 5)
        }
    }
}
