//
//  SettingsViewObject.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/23.
//

import SwiftUI

class SettingsViewObject: ObservableObject {
    static let shared = SettingsViewObject()

    @Published var isKeyWindow = false
    @Published var isFirst = false
}
