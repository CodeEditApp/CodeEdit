//
//  CEWorkspaceSettings+TasksConfigurationProviding.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 13/07/2026.
//

import Combine
import CodeEditCore

extension CEWorkspaceSettings: TasksConfigurationProviding {
    var tasks: [CETask] { settings.tasks }

    var tasksPublisher: AnyPublisher<[CETask], Never> {
        $settings.map(\.tasks).eraseToAnyPublisher()
    }
}
