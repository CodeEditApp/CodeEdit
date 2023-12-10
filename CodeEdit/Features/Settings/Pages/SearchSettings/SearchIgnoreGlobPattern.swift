//
//  SearchIgnoreGlobPattern.swift
//  CodeEdit
//
//  Created by Esteban on 12/10/23.
//

import SwiftUI

struct SearchIgnoreGlobPattern: View {
    @Binding var globPattern: String

    var body: some View {
        Text(globPattern)
    }
}
