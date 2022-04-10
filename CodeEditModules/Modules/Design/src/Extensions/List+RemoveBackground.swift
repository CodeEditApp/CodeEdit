//
//  List+RemoveBackground.swift
//  
//
//  Created by Marco Carnevali on 05/04/22.
//

import Introspect
import SwiftUI

public extension List {
    /// List on macOS uses an opaque background with no option for
    /// removing/changing it. listRowBackground() doesn't work either.
    /// This workaround works because List is backed by NSTableView.
    func removeBackground() -> some View {
        return introspectTableView { tableView in
            tableView.backgroundColor = .clear
            tableView.enclosingScrollView!.drawsBackground = false
        }
    }
}
