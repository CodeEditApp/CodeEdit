//
//  HelpButton.swift
//  
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

public struct HelpButton: View {
    var action : () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action, label: {
            ZStack {
                Circle()
                    .strokeBorder(Color(NSColor.separatorColor), lineWidth: 0.5)
                    .background(Circle().foregroundColor(Color(NSColor.controlColor)))
                    .shadow(color: Color(NSColor.separatorColor).opacity(0.3), radius: 0.5)
                    .shadow(color: Color(NSColor.shadowColor).opacity(0.3), radius: 1, y: 0.5)
                    .frame(width: 20, height: 20)
                Image(systemName: "questionmark")
                    .font(.system(size: 12.5, weight: .medium))
            }
        })
        .buttonStyle(PlainButtonStyle())
    }
}
