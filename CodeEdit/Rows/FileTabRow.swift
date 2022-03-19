//
//  FileTabRow.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 14/03/2022.
//

import SwiftUI
import WorkspaceClient

struct FileTabRow: View {
    @State var isHoveringClose: Bool = false
    
    var fileItem: WorkspaceClient.FileItem
    var isSelected: Bool
    var isHovering: Bool

    var closeAction: () -> Void
    
    var body: some View {
        let showingCloseButton = isHovering

        HStack(alignment: .center, spacing: 5) {
            ZStack {
                if isSelected {
                    // Create a hidden button, if the tab is selected
                    // and hide the button in the ZStack.
                    Button(action: closeAction) {
                        Text("").hidden()
                    }
                    .frame(width: 0, height: 0)
                    .padding(0)
                    .opacity(0)
                    .keyboardShortcut("w", modifiers: [.command])
                }
                
                Button(action: closeAction, label: {
                    Rectangle()
                        .fill(isHoveringClose
                              ? Color(nsColor: .secondaryLabelColor).opacity(0.28)
                              : Color(.clear))
                    .frame(width: 16, height: 16)
                    .cornerRadius(2)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 9.5, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    )
                })
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(Text("Close"))
                .opacity(showingCloseButton ? 1 : 0)
                .onHover { hover in
                    isHoveringClose = hover
                }

            }
            Image(systemName: fileItem.systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12)
            Text(fileItem.url.lastPathComponent)
                .font(.system(size: 11.0))
                .lineLimit(1)
        }
        .padding(.leading, 4)
        .padding(.trailing, 28)
        
    }
}

struct FileTabRow_Previews: PreviewProvider {
    static var previews: some View {
        FileTabRow(
            fileItem: WorkspaceClient.FileItem(
                url: URL(string: "Code.swift")!
            ),
            isSelected: false,
            isHovering: false,
            closeAction: {}
        )
        .frame(width: 160.0, height: 28.0)
    }
}
