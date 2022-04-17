//
//  FileInspectorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI

struct FileInspectorView: View {
    @State var fileName: String = "Index.swift"

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
                    Menu {
                        Button("Swift Source") {}
                    } label: {
                        Text("Language Type")
                            .font(.system(size: 11))
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

struct FileInspectorView_Previews: PreviewProvider {
    static var previews: some View {
        FileInspectorView().preferredColorScheme(.dark)
    }
}
