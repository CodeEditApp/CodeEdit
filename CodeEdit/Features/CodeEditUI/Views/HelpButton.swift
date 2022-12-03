//
//  HelpButton.swift
//  CodeEditModules/CodeEditUI
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

/// A Button representing a system Help button displaying a question mark symbol.
struct HelpButton: View {

    private var action: () -> Void

    /// Initializes the ``HelpButton`` with an action closure
    /// - Parameter action: A closure that gets called once the button is pressed.
    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
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

struct HelpButton_Previews: PreviewProvider {
    static var previews: some View {
        HelpButton {}
            .padding()
    }
}
