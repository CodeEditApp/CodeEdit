//
//  InternalDevelopmentInspectorView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/19/24.
//

import SwiftUI

struct InternalDevelopmentInspectorView: View {
    var body: some View {
        Form {
            InternalDevelopmentNotificationsView()
            InternalDevelopmentOutputView()
        }
    }
}
