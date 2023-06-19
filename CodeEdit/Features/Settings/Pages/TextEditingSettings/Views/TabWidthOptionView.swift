//
//  TabWidthOptionView.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/18/23.
//

import SwiftUI

struct TabWidthOptionView: View {
    @AppSettings(\.textEditing) private var textEditing

    var body: some View {
        HStack(alignment: .top) {
            Stepper(
                "Tab Width",
                value: Binding<Double>(
                    get: { Double(textEditing.defaultTabWidth) },
                    set: { textEditing.defaultTabWidth = Int($0) }
                ),
                in: 1...8,
                step: 1,
                format: .number
            )
            Text("spaces")
                .foregroundColor(.secondary)
        }
        .help("The visual width of tabs.")
    }
}

struct TabWidthOptionView_Previews: PreviewProvider {
    static var previews: some View {
        TabWidthOptionView()
    }
}
