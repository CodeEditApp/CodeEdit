//
//  CEActivity.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/20/25.
//

struct CEActivity: Equatable {
    var id: String
    var title: String
    var message: String?
    var percentage: Double?
    var isLoading: Bool = false
}
