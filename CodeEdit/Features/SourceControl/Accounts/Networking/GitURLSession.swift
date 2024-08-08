//
//  Session.swift
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
protocol GitURLSession {

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void
    ) -> GitURLSessionDataTaskProtocol

    func uploadTask(
        with request: URLRequest,
        fromData bodyData: Data?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> GitURLSessionDataTaskProtocol

#if !canImport(FoundationNetworking)
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse)

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func upload(
        for request: URLRequest,
        from bodyData: Data,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse)
#endif
}

protocol GitURLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: GitURLSessionDataTaskProtocol {}

extension URLSession: GitURLSession {

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void
    ) -> GitURLSessionDataTaskProtocol {
        (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask)
    }

    func uploadTask(
        with request: URLRequest,
        fromData bodyData: Data?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> GitURLSessionDataTaskProtocol {
        uploadTask(with: request, from: bodyData, completionHandler: completionHandler)
    }
}
