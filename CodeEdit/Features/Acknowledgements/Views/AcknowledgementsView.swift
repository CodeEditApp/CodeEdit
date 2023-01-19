//
//  AcknowledgementsView.swift
//  CodeEditModules/Acknowledgements
//
//  Created by Shivesh M M on 4/4/22.
//

import SwiftUI

struct AcknowledgementsView: View {

    @Environment(\.openURL) private var openURL

    @ObservedObject
    private var model = AcknowledgementsViewModel()

    var body: some View {
        VStack {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 48, height: 48)
            Text("Acknowledgements")
                .font(.title)
                .fontWeight(.bold)
            ScrollView {
                ForEach(
                    Array(zip(model.acknowledgements.indices, model.acknowledgements)),
                    id: \.1.name
                ) { (index, acknowledgement) in
                    if index != 0 {
                        Divider()
                            .frame(height: 0.5)
                            .opacity(0.5)
                    }
                    HStack {
                        Text(acknowledgement.name)
                            .font(.body)

                        Spacer()

                        Button {
                            openURL(acknowledgement.repositoryURL)
                        } label: {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(Color(nsColor: .tertiaryLabelColor))
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
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
