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
                .frame(width: 70, height: 70)
            Text("Acknowledgements")
                .font(.largeTitle)
                .fontWeight(.bold)
            ScrollView {
                ForEach(model.acknowledgements, id: \.name) { acknowledgement in
                    HStack {
                        Text(acknowledgement.name)
                            .font(.title3)
                            .fontWeight(.semibold)

                        Spacer()

                        Button {
                            openURL(acknowledgement.repositoryURL)
                        } label: {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(Color(nsColor: .tertiaryLabelColor))
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(width: 200)
                    .padding(.vertical, 2)
                }
            }
        }
        .frame(width: 350, height: 420)
        .background(.regularMaterial)
    }

    func showWindow(width: CGFloat, height: CGFloat) {
        AcknowledgementsViewWindowController(view: self, size: NSSize(width: width, height: height)).showWindow(nil)
    }
}
