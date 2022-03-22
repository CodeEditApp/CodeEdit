//
//  SideBarItem.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//  Context Menu by Nanashi Li on 20.03.22.
//

import SwiftUI
import WorkspaceClient
import CodeFile

struct NavigatorSidebarItem: View {
    @AppStorage(FileIconStyle.storageKey) var iconStyle: FileIconStyle = .default
    
    var item: WorkspaceClient.FileItem
    @ObservedObject var workspace: WorkspaceDocument
    var windowController: NSWindowController
    @State var isExpanded: Bool = false
    
    let fileManger = FileManager.default
    
    // maximum number of views in a container is exceeded (in SwiftUI). The max = 10
    var body: some View {
        if item.children == nil {
            sidebarFileItem(item)
                .id(item.id)
                .contextMenu{
                    Button("Show in Finder", action: {
                        showInFinder()
                    })
                    
                    Group{
                        Divider()
                        
                        Button("Open in Tab", action: {
                            print("Open in Tab")
                        })
                        
                        Button("Open in New Window", action: {
                            print("Open in New Window")
                        })
                        
                        Divider()
                    }
                    
                    Button("Show File Inspector", action: {
                        print("Show File Inspector")
                    })
                    
                    Group{
                        Divider()
                        
                        Button("New File", action: {
                            addFile(fileName: "randomFile.txt")
                        })
                        
                        Button("Add files to folder", action: {
                            print("Add files to folder")
                        })
                        
                        Divider()
                    }
                    
                    Button("Delete", action: {
                        deleteItem()
                    })
                    
                    Group{
                        Divider()
                        
                        Button("New Group", action: {
                            addFolder(folderName: "Test Folder")
                        })
                        
                        Button("New Group without Folder", action: {
                            print("New Group without Folder")
                        })
                        
                        Button("New Group from Selection", action: {
                            print("New Group from Selection")
                        })
                        
                        Divider()
                    }
                    
                    Menu("Source Control"){
                        Button("Commit Selected File", action: {
                            print("Commit Selected File")
                        })
                        
                        Divider()
                        
                        Button("Discard Changes in Selected File", action: {
                            print("Discard Changes in Selected File")
                        })
                        
                        Divider()
                        
                        Button("Add", action: {
                            print("Add")
                        })
                        
                        Button("Mark as Resolved", action: {
                            print("Mark as Resolved")
                        })
                    }
                }
        } else {
            sidebarFolderItem(item)
                .id(item.id)
                .contextMenu{
                    Button("Show in Finder", action: {
                        showInFinder()
                    })
                    
                    Group{
                        Divider()
                        
                        Button("Open in Tab", action: {
                            print("Open in Tab")
                        })
                        
                        Button("Open in New Window", action: {
                            print("Open in New Window")
                        })
                        
                        Divider()
                    }
                    
                    Button("Show File Inspector", action: {
                        print("Show File Inspector")
                    })
                    
                    Group{
                        Divider()
                        
                        Button("New File", action: {
                            addFile(fileName: "randomFile.txt")
                        })
                        
                        Button("Add files to folder", action: {
                            print("Add files to folder")
                        })
                        
                        Divider()
                    }
                    
                    Button("Delete", action: {
                        deleteItem()
                    })
                    
                    Group{
                        Divider()
                        
                        Button("New Group", action: {
                            addFolder(folderName: "Test Folder")
                        })
                        
                        Button("New Group without Folder", action: {
                            print("New Group without Folder")
                        })
                        
                        Button("New Group from Selection", action: {
                            print("New Group from Selection")
                        })
                        
                        Divider()
                    }
                    
                    Menu("Source Control"){
                        Button("Commit Selected File", action: {
                            print("Commit Selected File")
                        })
                        
                        Divider()
                        
                        Button("Discard Changes in Selected File", action: {
                            print("Discard Changes in Selected File")
                        })
                        
                        Divider()
                        
                        Button("Add", action: {
                            print("Add")
                        })
                        
                        Button("Mark as Resolved", action: {
                            print("Mark as Resolved")
                        })
                    }
                }
        }
    }
    
    func sidebarFileItem(_ item: WorkspaceClient.FileItem) -> some View {
        NavigationLink {
            WorkspaceCodeFileView(windowController: windowController,
                                  workspace: workspace)
            .onAppear { workspace.openFile(item: item) }
        } label: {
            Label(item.url.lastPathComponent, systemImage: item.systemImage)
                .accentColor(iconStyle == .color ? item.iconColor : .secondary)
                .font(.callout)
        }
    }
    
    func sidebarFolderItem(_ item: WorkspaceClient.FileItem) -> some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            if isExpanded { // Only load when expanded -> Improves performance massively
                ForEach(item.children!.sortItems(foldersOnTop: workspace.sortFoldersOnTop)) { child in
                    NavigatorSidebarItem(item: child,
                                         workspace: workspace,
                                         windowController: windowController)
                }
            }
        } label: {
            Label(item.url.lastPathComponent, systemImage: item.systemImage)
                .accentColor(.secondary)
                .font(.callout)
        }
    }
    
    func showInFinder(){
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: item.url.path)
    }
    
    func addFolder(folderName: String){
        let folderUrl = item.url.appendingPathComponent(folderName)
        
        do {
            try fileManger.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: [:])
        } catch {
            print(error)
        }
    }
    
    func addFile(fileName: String){
        do {
            let fileUrl = item.url.appendingPathComponent(fileName)
            
            fileManger.createFile(atPath: fileUrl.path, contents: nil, attributes: [FileAttributeKey.creationDate: Date()])
        } catch {
            print(error)
        }
    }
    
    func deleteItem(){
        if fileManger.fileExists(atPath: item.url.path){
            do {
                try fileManger.removeItem(at: item.url)
            } catch {
                print(error)
            }
        }
    }
}
