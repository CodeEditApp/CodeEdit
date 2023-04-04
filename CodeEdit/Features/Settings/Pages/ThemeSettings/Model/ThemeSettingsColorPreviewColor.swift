//
//  ThemeSettingsColorPreviewColor.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 04/04/23.
//

import Foundation
import SwiftUI

struct ThemeSettingsColorPreviewColor: View {
    private var color: Color

    init(_ color: Color) {
        self.color = color
    }

    var body: some View {
        color
        .frame(width: 5, height: 5)
        .cornerRadius(5)
        .overlay {
            ZStack {
                Circle()
                    .stroke(Color(.black).opacity(0.2), lineWidth: 0.5)
                    .frame(width: 5, height: 5)
                Circle()
                    .strokeBorder(Color(.white).opacity(0.2), lineWidth: 0.5)
                    .frame(width: 5, height: 5)
            }
        }
    }
}
