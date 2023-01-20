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

    @State private var displayDivider = false

    var body: some View {
        VStack(spacing: 0) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 48, height: 48)
            Text("Acknowledgements")
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical, 8)
            Divider()
                .opacity(displayDivider ? 1 : 0)
            OffsettableScrollView(showsIndicator: false) { offset in
                displayDivider = offset.y < 0
            } content: {
                LazyVStack(spacing: 0) {
                    ForEach(
                        Array(zip(model.acknowledgements.indices, model.acknowledgements)),
                        id: \.1.name
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
            .padding(.horizontal, 16)
        }
        .frame(width: 280, height: 400)
        .background(EffectView(.popover, blendingMode: .behindWindow).ignoresSafeArea())
    }

    func showWindow(width: CGFloat, height: CGFloat) {
        AcknowledgementsViewWindowController(view: self, size: NSSize(width: width, height: height)).showWindow(nil)
    }
}
