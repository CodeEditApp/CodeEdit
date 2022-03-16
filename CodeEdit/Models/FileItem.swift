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
            return fileIcon
        case .some(let children):
            return children.isEmpty ? "folder" : "folder.fill"
        }
    }

	var fileIcon: String {
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
		default:
			return "doc"
		}
	}

	private var fileType: String {
		if let comp = url.lastPathComponent.components(separatedBy: ".").last {
			return comp
		}
		return ""
	}
}
