//
//  CETask.swift
//  CodeEdit
//
//  Created by Axel Martinez on 2/2/24.
//

import Foundation

/// Represents a CodeEdit task that can be executed.
protocol CETask: Hashable {
    var name: String { get }

    func execute(_ activeTaskRun: CETaskRun) async throws
}
