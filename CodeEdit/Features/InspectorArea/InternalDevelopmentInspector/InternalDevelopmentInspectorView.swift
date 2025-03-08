//
//  InternalDevelopmentInspectorView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/19/25.
//

import SwiftUI

struct InternalDevelopmentInspectorView: View {
    @EnvironmentObject var activityManager: ActivityManager

    var body: some View {
        Form {
            InternalDevelopmentActivitiesView()
            InternalDevelopmentNotificationsView()
        }
    }
}
