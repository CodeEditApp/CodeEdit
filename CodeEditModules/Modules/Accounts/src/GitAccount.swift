//
//  GitAccount.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public struct GitAccount {
    public let configuration: TokenConfiguration

    public init(_ config: TokenConfiguration = TokenConfiguration()) {
        configuration = config
    }
}
