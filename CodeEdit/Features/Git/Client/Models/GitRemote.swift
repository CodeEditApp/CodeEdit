//
//  GitRemote.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/17/23.
//

import Foundation

struct GitRemote: Hashable {
    let name: String
    let pushLocation: String
    let fetchLocation: String
}
