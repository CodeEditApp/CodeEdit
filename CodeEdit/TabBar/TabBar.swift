//
//  TabBar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct TabBar: View {

	@Binding var openFileItems: [WorkspaceClient.FileItem]
	@Binding var selectedId: UUID?

	var tabBarHeight = 28.0

    var body: some View {
		VStack(spacing: 0.0) {
			Divider()
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(alignment: .center, spacing: 0.0) {
					Divider()
						.foregroundColor(.primary.opacity(0.25))
					ForEach(openFileItems, id: \.id) { item in
						TabBarItem(item: item,
								   selectedId: $selectedId,
								   openFileItems: $openFileItems,
								   tabBarHeight: tabBarHeight)
					}
					Spacer()
				}
			}
			Divider()
				.foregroundColor(.black)
				.frame(height: 1.0)
		}
		.frame(maxHeight: tabBarHeight)
		.background {
			BlurView(material: .titlebar, blendingMode: .withinWindow)
		}
    }

	
}
