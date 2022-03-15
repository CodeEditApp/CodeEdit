//
//  FileTabRow.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 14/03/2022.
//

import SwiftUI

struct FileTabRow: View {
    let fileItem: FileItem
    let closeAction: () -> Void
    
    var body: some View {
        ZStack {
            Label(fileItem.url.lastPathComponent, systemImage: fileItem.systemImage)
                .font(.callout)
                .padding(.horizontal, 28.0)
                .padding(.top, 2.0)
                .lineLimit(1)
            
            HStack {
                Spacer()
                
                Button(action: closeAction) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .padding(.trailing, 7.0)
                .padding(.top, 2.0)
            }
        }
    }
}

struct FileTabRow_Previews: PreviewProvider {
    static var previews: some View {
        FileTabRow(fileItem: FileItem(url: URL(string: "Code.swift")!), closeAction: {})
            .frame(width: 160.0)
    }
}
