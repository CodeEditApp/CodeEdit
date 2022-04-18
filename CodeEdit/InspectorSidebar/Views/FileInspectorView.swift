//
//  FileInspectorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI

struct FileInspectorView: View {
    @State var fileName: String = "Index.swift"
    @State var fileTypeSelection: LanguageType.ID = "none"

    @ObservedObject
    private var inspectorModel: InspectorModel = .shared

    var body: some View {
        VStack(alignment: .leading) {

            Text("Identity and Type")
                .foregroundColor(.secondary)
                .fontWeight(.bold)
                .font(.system(size: 13))

            VStack(alignment: .trailing) {
                HStack {
                    Text("Name")
                        .foregroundColor(.primary)
                        .fontWeight(.regular)
                        .font(.system(size: 10))
                    TextField("Name", text: $fileName)
                        .frame(maxWidth: 150)
                }
                HStack() {
                    Text("Type")
                        .foregroundColor(.primary)
                        .fontWeight(.regular)
                        .font(.system(size: 10))
                    Picker("", selection: $fileTypeSelection) {
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
                    }.frame(maxWidth: 150, maxHeight: 12)
                }
                Divider()
            }

            VStack(alignment: .trailing) {
                HStack(alignment: .top) {
                    Text("Location")
                        .foregroundColor(.primary)
                        .fontWeight(.regular)
                        .font(.system(size: 10))

                    VStack {
                        Menu {
                            Button("Absolute Path") {}
                            Button("Relative to Group") {}
                            Button("Relative to Project") {}
                            Button("Relative to Developer Directory") {}
                            Button("Relative to Build Projects") {}
                            Button("Relative to SDK") { }
                        } label: {
                            Text("Location Type")
                                .font(.system(size: 11))
                        }
                        HStack {
                            Text("Index.swift")
                                .font(.system(size: 11))

                            Spacer()

                            Image(systemName: "folder.fill")
                                .foregroundColor(.secondary)
                        }
                    }.frame(maxWidth: 150)
                }
                HStack(alignment: .top) {
                    Text("Full Path")
                        .foregroundColor(.primary)
                        .fontWeight(.regular)
                        .font(.system(size: 10))

                    HStack(alignment: .bottom) {
                        Text("/Users/nanashili/CodeEdit/CodeEdit/InspectorSidebar/FileInspectorView.swift")
                            .foregroundColor(.primary)
                            .fontWeight(.regular)
                            .font(.system(size: 10))
                            .lineLimit(4)

                        Image(systemName: "arrow.forward.circle.fill")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.secondary)
                    }.frame(maxWidth: 150, alignment: .leading)
                }.padding(.top, -5)

                Divider()
            }

            Text("Text Settings")
                .foregroundColor(.secondary)
                .fontWeight(.bold)

            VStack(alignment: .trailing) {
                HStack() {
                    Text("Text Encoding")
                        .foregroundColor(.primary)
                        .fontWeight(.regular)
                        .font(.system(size: 10))
                    Menu {
                        Button("Unicode (UTF-8)") {}
                    } label: {
                        Text("No Explicit Encoding")
                            .font(.system(size: 11))
                    }.frame(maxWidth: 150, maxHeight: 12)
                }
                HStack() {
                    Text("Line Endings")
                        .foregroundColor(.primary)
                        .fontWeight(.regular)
                        .font(.system(size: 10))
                    Menu {
                        Button("Unicode (UTF-8)") {}
                    } label: {
                        Text("No Explicit Line Endings")
                            .font(.system(size: 11))
                    }.disabled(true).frame(maxWidth: 150, maxHeight: 12).padding(.top, 3)
                }
                Divider()
                HStack() {
                    Text("Indent Using")
                        .foregroundColor(.primary)
                        .fontWeight(.regular)
                        .font(.system(size: 10))
                    Menu("Spaces", content: {
                    }).frame(maxWidth: 150)
                }
            }
        }.frame(maxWidth: 250).padding(5)
    }
}
