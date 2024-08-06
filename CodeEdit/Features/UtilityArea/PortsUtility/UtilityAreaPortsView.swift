//
//  UtilityAreaOutputView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI
import LogStream

struct UtilityAreaPortsView: View {
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    var body: some View {
        UtilityAreaTabView(model: utilityAreaViewModel.tabViewModel) { _ in
            List {
                // TODO: Add Ports List
            }
            .paneToolbar {
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                }
                .help("Add Port")
                .accessibilityHint("Opens a new port")
                .accessibilityLabel("Add port")
                Spacer()
            }
        }
    }
}
