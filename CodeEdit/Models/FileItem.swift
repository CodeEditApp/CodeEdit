//
//  FileItem.swift
//  CodeEdit
//
//  Created by Rehatbir Singh on 12/03/2022.
//

import Foundation

struct FileItem: Hashable, Identifiable {
    var id: UUID = UUID()
    var url: URL
    var children: [FileItem]? = nil
    var systemImage: String {
        switch children {
        case nil:
            return fileImage
        case .some(let children):
            return children.isEmpty ? "folder" : "folder.fill"
        }
    }

	var fileImage: String {
		switch fileType {
		case "json":
			return "curlybraces"
		case "css":
			return "number"
		case "js":
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
		default:
			return "doc.plaintext"
		}
	}

	private var fileType: String {
		if let comp = url.lastPathComponent.components(separatedBy: ".").last {
			return comp
		}
		return ""
	}
}
