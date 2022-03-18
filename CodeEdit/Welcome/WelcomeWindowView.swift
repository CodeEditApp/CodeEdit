//
//  WelcomeWindowView.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI

struct WelcomeWindowView: View {
    var body: some View {
        HStack(spacing: 0) {
            WelcomeView {
                print("dismiss")
            }
            RecentProjectsView()
        }
    }
}

struct WelcomeWindowView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeWindowView()
    }
}
