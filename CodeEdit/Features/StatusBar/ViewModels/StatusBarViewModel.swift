//
//  StatusBarViewModel.swift
//  CodeEdit
//
//  Created by Paul Ebose on 2024/5/12.
//

import SwiftUI

final class StatusBarViewModel: ObservableObject {

    /// Indicates whether the breakpoint is enabled or not.
    @Published var isBreakpointEnabled = true

    /// The font style of items shown in the status bar.
    private(set) var statusBarFont = Font.system(size: 11, weight: .medium)

}
