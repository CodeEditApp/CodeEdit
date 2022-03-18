//
//  BreadcrumbsView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct BreadcrumbsView: View {

	@ObservedObject var workspace: WorkspaceDocument
	let file: WorkspaceClient.FileItem

	@State private var projectName: String = ""
	@State private var folders: [String] = []
	@State private var fileName: String = ""
	@State private var fileImage: String = "doc"

	init(_ file: WorkspaceClient.FileItem, workspace: WorkspaceDocument) {
		self.file = file
		self.workspace = workspace
	}

	var body: some View {
		ZStack(alignment: .leading) {
			Rectangle()
				.foregroundStyle(Color(nsColor: .controlBackgroundColor))
			HStack {
				BreadcrumbsComponent(projectName, systemImage: "square.dashed.inset.filled", color: .accentColor)
				chevron
				ForEach(folders, id:\.self) { folder in
					BreadcrumbsComponent(folder, systemImage: "folder.fill")
					chevron
				}
				BreadcrumbsComponent(fileName, systemImage: fileImage, color: file.iconColor)
			}
			.padding(.leading, 12)
		}
		.frame(height: 29)
		.overlay(alignment: .bottom) {
			Divider()
		}
		.onAppear {
			fileInfo()
		}
	}

	private var chevron: some View {
		Image(systemName: "chevron.compact.right")
			.foregroundStyle(.secondary)
			.imageScale(.large)
	}

	private func fileInfo() {
		
		guard let projName = workspace.folderURL?.lastPathComponent,
			  var components = file.url.pathComponents.split(separator: projName).last else { return }
		components.removeLast()

		self.projectName = projName
		self.folders = Array(components)
		self.fileName = file.fileName
		self.fileImage = file.systemImage
	}

}

struct BreadcrumbsView_Previews: PreviewProvider {
	static var previews: some View {
		BreadcrumbsView(.init(url: .init(fileURLWithPath: "", isDirectory: false)), workspace: .init())
			.previewLayout(.fixed(width: 500, height: 29))
			.preferredColorScheme(.dark)

		BreadcrumbsView(.init(url: .init(fileURLWithPath: "", isDirectory: false)), workspace: .init())
			.previewLayout(.fixed(width: 500, height: 29))
			.preferredColorScheme(.light)
	}
}
