//
//  Response.swift
//  CodeEditModules/ExtensionStore
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation

public struct Response<T> {
    public let value: T
    public let response: URLResponse
}
