//
//  Session.swift
//
//
//  Created by Nanashi Li on 2022/03/31.
//
// This file should be strictly just be used for Accounts since it's not
// built for any other networking except those of git accounts

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol GitURLSession {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTaskProtocol

    func uploadTask(
        with request: URLRequest,
        fromData bodyData: Data?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol

    #if !canImport(FoundationNetworking)
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)

    func upload(
        for request: URLRequest,
        from bodyData: Data,
        delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
    #endif
}

public protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

extension GitURLSession: URLSession {

    public func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTaskProtocol {
        return (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask)
    }

    public func uploadTask(
        with request: URLRequest,
        fromData bodyData: Data?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return uploadTask(with: request, from: bodyData, completionHandler: completionHandler)
    }
}
