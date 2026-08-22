//
//  SearchSettingsIgnoreGlobPatternItemView.swift
//  CodeEdit
//
//  Created by Esteban on 12/10/23.
//

import SwiftUI

struct SearchSettingsIgnoreGlobPatternItemView: View {
    @Binding var globPattern: String

    var body: some View {
        Text(globPattern)
    }
}
