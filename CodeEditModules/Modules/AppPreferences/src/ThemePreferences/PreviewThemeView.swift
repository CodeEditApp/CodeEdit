//
//  PreviewThemeView.swift
//  
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

struct PreviewThemeView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundColor(Color(NSColor.controlBackgroundColor))
            VStack(alignment: .leading, spacing: 0) {
                Text("Implementation needed")
            }
            .padding(20)
        }
    }
}

struct PreviewThemeView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewThemeView()
    }
}
