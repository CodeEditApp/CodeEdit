//
//  UtilityAreaPortsView.swift
//  CodeEdit
//
//  Created by Gavin Gichini on 1/4/25.
//

import SwiftUI
import LogStream

struct UtilityAreaPortsView: View {
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    @ObservedObject var extensionManager = ExtensionManager.shared

    var body: some View {
        UtilityAreaTabView(model: utilityAreaViewModel.tabViewModel) { _ in
            
        }
    }
}
