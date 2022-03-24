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
                    TextField("Name", text: $fileName).frame(maxWidth: 150)
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
                HStack() {
                    Text("Location")
                        .foregroundColor(.primary)
                        .fontWeight(.regular)
                        .font(.system(size: 10))
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
                    }.frame(maxWidth: 150, maxHeight: 12)
                }
                HStack() {
                    Text("Full Path")
                        .foregroundColor(.primary)
                        .fontWeight(.regular)
                        .font(.system(size: 10))
                    Text("/Users/nanashili/CodeEdit/CodeEdit/InspectorSidebar/FileInspectorView.swift")
                        .foregroundColor(.primary)
                        .fontWeight(.regular)
                        .font(.system(size: 10))
                        .lineLimit(4)
                        .frame(maxWidth: 150, alignment: .leading)
                }

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
