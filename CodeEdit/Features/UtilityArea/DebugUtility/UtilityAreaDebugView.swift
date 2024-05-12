//
//  UtilityAreaDebugView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI

struct UtilityAreaDebugView: View {
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    @State var tabSelection = 0

    var body: some View {
        UtilityAreaTabView(model: utilityAreaViewModel.tabViewModel) { _ in
            Text("Nothing to debug")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .paneToolbar {
                    EmptyView()
                }
        } leadingSidebar: { _ in
            List(selection: $tabSelection) {
                EmptyView()
            }
            .listStyle(.automatic)
            .accentColor(.secondary)
            .paneToolbar {
//                Button {
//                    // add
//                } label: {
//                    Image(systemName: "plus")
//                }
//                Button {
//                    // remove
//                } label: {
//                    Image(systemName: "minus")
//                }
            }
        }
    }
}
