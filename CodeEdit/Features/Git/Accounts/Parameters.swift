//
//  Parameters.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum GitSortDirection: String {
    case asc
    case desc
}

enum GitSortType: String {
    case created
    case updated
    case popularity
    case longRunning = "long-running"
}
