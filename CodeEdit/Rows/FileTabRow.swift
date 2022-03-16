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
        
        ZStack(alignment: .center) {
            HStack {
                Button(action: closeAction) {
                    Image(systemName: showingCloseButton ? "xmark.square.fill" : fileItem.systemImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: showingCloseButton ? 12.0 : 16.0)
                }
                .offset(x: showingCloseButton ? 10.0 : 8.0)
                .buttonStyle(.plain)
                
                Spacer()
            }
            
            Text(fileItem.url.lastPathComponent)
                .font(.system(size: 11.0))
                .padding(.horizontal, 64.0)
                .lineLimit(1)
        }
        .onHover { hover in
            mouseHovering = hover
        }
    }
}

struct FileTabRow_Previews: PreviewProvider {
    static var previews: some View {
        FileTabRow(fileItem: WorkspaceClient.FileItem(url: URL(string: "Code.swift")!), isSelected: false, closeAction: {})
            .frame(width: 160.0, height: 28.0)
    }
}
