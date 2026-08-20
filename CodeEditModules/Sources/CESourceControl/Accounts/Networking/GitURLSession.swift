//
//  GitURLSession.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//
// This file should be strictly just be used for Accounts since it's not
// built for any other networking except those of git accounts

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// TODO: DOCS (Nanashi Li)
/// Abstraction over `URLSession` for git account API requests, allowing the session to be mocked in tests.
public protocol GitURLSession {

    /// Creates a data task that fetches the given request and calls the handler with the response.
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void
    ) -> GitURLSessionDataTaskProtocol

    /// Creates a task that uploads the given body data for the request and calls the handler with the response.
    func uploadTask(
        with request: URLRequest,
        fromData bodyData: Data?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> GitURLSessionDataTaskProtocol

#if !canImport(FoundationNetworking)
    /// Fetches the given request asynchronously, returning the response body and metadata.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse)

    /// Uploads the given body data for the request asynchronously, returning the response body and metadata.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func upload(
        for request: URLRequest,
        from bodyData: Data,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse)
#endif
}

/// Abstraction over `URLSessionDataTask` so tasks returned by a ``GitURLSession`` can be mocked in tests.
public protocol GitURLSessionDataTaskProtocol {
    /// Starts (or resumes) the network task.
    func resume()
}

extension URLSessionDataTask: GitURLSessionDataTaskProtocol {}

extension URLSession: GitURLSession {

    public func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void
    ) -> GitURLSessionDataTaskProtocol {
        (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask)
    }

    public func uploadTask(
        with request: URLRequest,
        fromData bodyData: Data?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> GitURLSessionDataTaskProtocol {
        uploadTask(with: request, from: bodyData, completionHandler: completionHandler)
    }
}
