//
//  ChangedFileItemView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

 struct ChangedFileItemView: View {

     @State
     var changedFile: ChangedFile

     @Binding
     var selection: ChangedFile.ID?

     @State
     var workspaceURL: URL

     var body: some View {
         HStack {
             Image(systemName: changedFile.systemImage)
                 .frame(width: 11, height: 11)
                 .foregroundColor(selection == changedFile.id ? .white : changedFile.iconColor)

             Text(changedFile.fileName)
                 .font(.system(size: 11))
                 .foregroundColor(selection == changedFile.id ? .white : .secondary)

             Text(changedFile.changeTypeValue)
                 .font(.system(size: 11))
                 .foregroundColor(selection == changedFile.id ? .white : .secondary)
                 .frame(maxWidth: .infinity, alignment: .trailing)
         }
         .contextMenu {
             Group {
                 Button("View in Finder") {
                     changedFile.showInFinder(workspaceURL: workspaceURL)
                 }
                 Button("Reveal in Project Navigator") {}
                     .disabled(true) // TODO: Implementation Needed
                 Divider()
             }
             Group {
                 Button("Open in New Tab") {}
                     .disabled(true) // TODO: Implementation Needed
                 Button("Open in New Window") {}
                     .disabled(true) // TODO: Implementation Needed
                 Button("Open with External Editor") {}
                     .disabled(true) // TODO: Implementation Needed
             }
             Group {
                 Divider()
                 Button("Commit \(changedFile.fileName)...") {}
                     .disabled(true) // TODO: Implementation Needed
                 Divider()
                 Button("Discard Changes in \(changedFile.fileName)...") {}
                     .disabled(true) // TODO: Implementation Needed
                 Divider()
             }
             Group {
                 Button("Add \(changedFile.fileName)") {}
                     .disabled(true) // TODO: Implementation Needed
                 Button("Mark \(changedFile.fileName) as Resolved") {}
                     .disabled(true) // TODO: Implementation Needed
             }
         }
         .padding(.leading, 15)
     }
 }
