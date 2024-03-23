//
//  DocumentService.swift
//  CodeEditV2
//
//  Created by Abe Malla on 3/21/24.
//

import Foundation

protocol DocumentProvider {
    static func newDocument()
    static func openDocument()
    static func openDocument(completion: @escaping (Bool, Error?) -> Void)
}
