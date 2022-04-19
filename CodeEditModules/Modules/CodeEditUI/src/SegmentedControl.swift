//
//  SegmentedControl.swift
//  
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

/// A view that creates a segmented control from an array of text labels.
///
/// ## Usage
/// ```swift
/// @State var selected: Int = 0
/// var items: [String] = ["Tab 1", "Tab 2"]
///
/// SegementedControl($selected, options: items)
/// ```
public struct SegmentedControl: View {

    @Environment(\.colorScheme)
    private var colorScheme

    /// A view that creates a segmented control from an array of text labels.
    /// - Parameters:
    ///   - selection: The index of the current selected item.
    ///   - options: the options to display as an array of strings.
    ///   - color: The color of the selected item. Defaults to `NSColor.selectedControlColor`
    public init(
        _ selection: Binding<Int>,
        options: [String],
        color: Color = Color(nsColor: .selectedControlColor)
    ) {
        self._preselectedIndex = selection
        self.options = options
        self.color = color
    }

    @Binding
    private var preselectedIndex: Int

    private var options: [String]

    private let color: Color

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                Text(options[index])
                    .font(.subheadline)
                    .foregroundColor(preselectedIndex == index
                                     ? colorScheme == .dark ? .white : .accentColor
                                     : .primary)
                    .frame(height: 16)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background {
                        Rectangle()
                            .fill(color)
                            .cornerRadius(5)
                            .padding(2)
                            .opacity(preselectedIndex == index ? 0.75 : 0.01)
                    }
                    .onTapGesture {
                        preselectedIndex = index
                    }
            }
        }
        .frame(height: 20)
    }
}
