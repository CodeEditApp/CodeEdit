//
//  Response.swift
//  CodeEditModules/ExtensionStore
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation

// TODO: DOCS (Pavel Kasila)
// swiftlint:disable missing_docs
public struct Response<T> {
    public let value: T
    public let response: URLResponse
}
