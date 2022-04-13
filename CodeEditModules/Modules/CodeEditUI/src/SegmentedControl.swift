//
//  SegmentedControl.swift
//  
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

/// A view that creates a segmented control from an array of text labels.
public struct SegmentedControl: View {

    /// A view that creates a segmented control from an array of text labels.
    /// - Parameters:
    ///   - selection: The index of the current selected item.
    ///   - options: the options to display as an array of strings.
    public init(_ selection: Binding<Int>, options: [String]) {
        self._preselectedIndex = selection
        self.options = options
    }

    @Binding var preselectedIndex: Int
    var options: [String]
    let color = Color.accentColor
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                Text(options[index])
                    .font(.subheadline)
                    .foregroundColor(preselectedIndex == index ? .white : .primary)
                    .frame(height: 16)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background {
                        Rectangle()
                            .fill(color)
                            .cornerRadius(5)
                            .padding(2)
                            .opacity(preselectedIndex == index ? 1 : 0.01)
                    }
                    .onTapGesture {
                        preselectedIndex = index
                    }
            }
        }
        .frame(height: 20)
    }
}
