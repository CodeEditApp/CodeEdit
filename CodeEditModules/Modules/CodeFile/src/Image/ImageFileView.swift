//
//  ImageFileView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/04/16.
//

import SwiftUI

struct ImageFileView: View {
    var body: some View {
        Image("")
            .resizable()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func loadImageFromDiskWith(fileName: String) -> NSImage? {

        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = NSImage(contentsOfFile: imageUrl.path)
            return image

        }
        return nil
    }
}

struct ImageFileView_Previews: PreviewProvider {
    static var previews: some View {
        ImageFileView()
    }
}
