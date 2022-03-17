//
//  BreadcrumbsView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct BreadcrumbsView: View {

	@ObservedObject var workspace: WorkspaceDocument

	@State private var projectName: String = ""
	@State private var folders: [String] = []
	@State private var fileName: String = ""
	@State private var fileImage: String = "doc"

    var body: some View {
		ZStack(alignment: .leading) {
			Rectangle()
				.foregroundStyle(Material.regularMaterial)
			HStack {
				breadcrumbLabel(projectName, systemImage: "square.dashed.inset.filled")
				spacer
				ForEach(folders, id:\.self) { folder in
					breadcrumbLabel(folder, systemImage: "folder.fill")
					spacer
				}
				breadcrumbLabel(fileName, systemImage: "swift")
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

	private func breadcrumbLabel(_ title: String, systemImage: String) -> some View {
		HStack {
			Image(systemName: systemImage)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 12)
				.foregroundStyle(.secondary)
			Text(title)
				.foregroundStyle(.primary)
				.font(.system(size: 11))
		}
	}

	private var spacer: some View {
		Image(systemName: "chevron.compact.right")
			.foregroundStyle(.secondary)
			.imageScale(.large)
	}

	private func fileInfo() {
		guard let file = try? workspace.workspaceClient?.getFileItem(workspace.selectedId!) else { return }
		guard let projName = workspace.workspaceClient?.folderURL()?.lastPathComponent else { return }
		var components = file.url.pathComponents.split(separator: projName).last!
		components.removeLast()

		self.projectName = projName
		self.folders = Array(components)
		self.fileName = file.fileName
		self.fileImage = file.systemImage
	}
}

struct BreadcrumbsView_Previews: PreviewProvider {
    static var previews: some View {
		BreadcrumbsView(workspace: .init())
			.previewLayout(.fixed(width: 500, height: 29))
			.preferredColorScheme(.dark)
    }
}
