//
//  FileTabRow.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 14/03/2022.
//

import SwiftUI

struct FileTabRow: View {
    let fileItem: FileItem
    
    var body: some View {
        Label(fileItem.url.lastPathComponent, systemImage: fileItem.systemImage)
            .font(.headline.weight(.regular))
            .padding(.horizontal, 28.0)
            .padding(.vertical, 9.0)
    }
}

struct FileTabRow_Previews: PreviewProvider {
    static var previews: some View {
        FileTabRow(fileItem: FileItem(url: URL(string: "Code.swift")!))
    }
}
