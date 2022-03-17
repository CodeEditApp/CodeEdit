//
//  FileItem.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 16/03/22.
//

import Foundation

public extension WorkspaceClient {
    struct FileItem: Hashable, Identifiable {
        public var id: UUID = UUID()
        public var url: URL
        public var children: [FileItem]? = nil
        public var systemImage: String {
            switch children {
            case nil:
                return fileIcon
            case .some(let children):
                return children.isEmpty ? "folder" : "folder.fill"
            }
        }
		public var fileName: String {
			url.lastPathComponent
		}
        
        public var fileIcon: String {
            switch fileType {
            case "json", "js":
                return "curlybraces"
            case "css":
                return "number"
            case "jsx":
                return "atom"
            case "swift":
                return "swift"
            case "env":
                return "gearshape.fill"
            case "gitignore":
                return "arrow.triangle.branch"
            case "png", "jpg", "jpeg", "ico":
                return "photo"
            case "svg":
                return "square.fill.on.circle.fill"
            case "entitlements":
                return "checkmark.seal"
            case "md", "txt", "rtf", "plist":
                return "doc.plaintext"
            case "html", "py", "sh":
                return "chevron.left.forwardslash.chevron.right"
            case "LICENSE":
                return "key.fill"
            case "java":
                return "cup.and.saucer"
            default:
                return "doc"
            }
        }
        
        private var fileType: String {
            url.lastPathComponent.components(separatedBy: ".").last ?? ""
        }
        
        public init(
            url: URL,
            children: [FileItem]? = nil
        ) {
            self.url = url
            self.children = children
        }
    }
}
