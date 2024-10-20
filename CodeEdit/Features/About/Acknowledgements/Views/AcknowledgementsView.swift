//
//  AcknowledgementsView.swift
//  CodeEditModules/Acknowledgements
//
//  Created by Shivesh M M on 4/4/22.
//

import SwiftUI

struct AcknowledgementsView: View {
    @StateObject var model = AcknowledgementsViewModel()
    @Binding var aboutMode: AboutMode
    var namespace: Namespace.ID

    var body: some View {
        AboutDetailView(title: "Acknowledgements", aboutMode: $aboutMode, namespace: namespace) {
            LazyVStack(spacing: 0) {
                ForEach(
                    model.indexedAcknowledgements,
                    id: \.acknowledgement.name
                ) { (index, acknowledgement) in
                    if index != 0 {
                        Divider()
                            .frame(height: 0.5)
                            .opacity(0.5)
                    }
                    AcknowledgementRowView(acknowledgement: acknowledgement)
                }
            }
        }
    }
}
