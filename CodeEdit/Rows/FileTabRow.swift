//
//  FileTabRow.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 14/03/2022.
//

import SwiftUI
import WorkspaceClient

struct FileTabRow: View {
    @State var mouseHovering = false
    
    var fileItem: WorkspaceClient.FileItem
    var isSelected: Bool
    var closeAction: () -> Void
    
    var body: some View {
        let showingCloseButton = mouseHovering || isSelected
        
        HStack {
            Button(action: closeAction) {
                Image(systemName: showingCloseButton ? "xmark.square.fill" : fileItem.systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
            }
            .buttonStyle(.plain)
            
            Text(fileItem.url.lastPathComponent)
                .font(.system(size: 11.0))
                .lineLimit(1)
                .padding(.leading, 3)
        }
        .padding(.horizontal)
        .onHover { hover in
            mouseHovering = hover
            DispatchQueue.main.async {
                if hover {
                    NSCursor.arrow.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}

struct FileTabRow_Previews: PreviewProvider {
    static var previews: some View {
        FileTabRow(fileItem: WorkspaceClient.FileItem(url: URL(string: "Code.swift")!), isSelected: false, closeAction: {})
            .frame(width: 160.0, height: 28.0)
    }
}
