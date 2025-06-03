//
//  CEActivity.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.06.24.
//

import Foundation

/// Represents an activity, that is displayed in the activity viewer
struct CEActivity: Equatable {
    var id: String
    var title: String
    var message: String?
    var percentage: Double?
    var isLoading: Bool = false
}
