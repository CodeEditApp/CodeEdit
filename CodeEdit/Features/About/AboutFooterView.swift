//
//  AboutFooterView.swift
//  CodeEdit
//
//  Created by Giorgi Tchelidze on 08.06.25.
//

import SwiftUI
import AboutWindow

struct AboutFooterView: View {
    var body: some View {
        FooterView(
            primaryView: {
                Link(destination: URL(string: "https://github.com/CodeEditApp/CodeEdit/blob/main/LICENSE.md")!) {
                    Text("MIT License")
                        .underline()
                }
            },
            secondaryView: {
                Text(Bundle.copyrightString ?? "")
            }
        )
    }
}
