//
//  URL+LanguageServer.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/8/24.
//

import Foundation

extension URL {
    var absolutePath: String {
        absoluteURL.path(percentEncoded: false)
    }
}
