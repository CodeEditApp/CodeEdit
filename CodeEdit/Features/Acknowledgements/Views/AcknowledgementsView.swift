//
//  AcknowledgementsView.swift
//  CodeEditModules/Acknowledgements
//
//  Created by Shivesh M M on 4/4/22.
//

import SwiftUI

struct AcknowledgementsView: View {
    @ObservedObject
    private var model = AcknowledgementsViewModel()

    var body: some View {
        VStack(spacing: 0) {
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
