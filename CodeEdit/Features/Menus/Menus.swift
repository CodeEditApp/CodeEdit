//
//  Menus.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI

struct Menus: Commands {

    var body: some Commands {
        AppMenu()
        FileMenu()
        ViewMenu()
        FindMenu()
        NavigateMenu()
        SourceControlMenu()
        WindowMenu()
        HelpMenu()
    }
}
