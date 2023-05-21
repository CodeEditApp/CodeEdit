//
//  QuickHelpInspectorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI

struct QuickHelpInspectorView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Quick Help")
                .foregroundColor(.secondary)
                .fontWeight(.bold)
                .font(.system(size: 13))
            VStack {
                Text("No Quick Help")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .padding(.top, 10)
                    .padding(.bottom, 10)

                Button("Search Documentation") {
                    // Open documentation
                }
                .controlSize(.small)
            }
            .frame(maxWidth: .infinity)
            Divider().padding(.top, 15)
        }
        .frame(maxWidth: .infinity).padding(5)
    }
}
