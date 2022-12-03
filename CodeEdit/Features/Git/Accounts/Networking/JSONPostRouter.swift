//
//  JSONPostRouter.swift
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
protocol JSONPostRouter: Router {

    func postJSON<T>(
        _ session: GitURLSession,
        expectedResultType: T.Type,
        completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol?

    func post<T: Codable>(
        _ session: GitURLSession,
        decoder: JSONDecoder,
        expectedResultType: T.Type,
        completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol?

    #if !canImport(FoundationNetworking)
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func postJSON<T>(_ session: GitURLSession, expectedResultType: T.Type) async throws -> T?

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func post<T: Codable>(
        _ session: GitURLSession,
        decoder: JSONDecoder,
        expectedResultType: T.Type) async throws -> T
    #endif
}

extension JSONPostRouter {
    func postJSON<T>(
        _ session: GitURLSession = URLSession.shared,
        expectedResultType _: T.Type,
        completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol? {

        guard let request = request() else {
            return nil
        }

        let data: Data

        do {
            data = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        } catch {
            completion(nil, error)
            return nil
        }

        let task = session.uploadTask(with: request, fromData: data) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if !response.wasSuccessful {
                    var userInfo = [String: Any]()
                    if let data = data, let json = try? JSONSerialization.jsonObject(
                        with: data,
                        options: .mutableContainers) as? [String: Any] {

                        userInfo[errorKey] = json as Any?

                    } else if let data = data, let string = String(
                        data: data,
                        encoding: String.Encoding.utf8) {

                        userInfo[errorKey] = string as Any?
                    }

                    let error = NSError(
                        domain: self.configuration?.errorDomain ?? "",
                        code: response.statusCode,
                        userInfo: userInfo)

                    completion(nil, error)
                    return
                }
            }

            if let error = error {
                completion(nil, error)
            } else {
                if let data = data {
                    do {
                        let JSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? T
                        completion(JSON, nil)
                    } catch {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }

    #if !canImport(FoundationNetworking)
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func postJSON<T>(
        _ session: GitURLSession = URLSession.shared,
        expectedResultType _: T.Type) async throws -> T? {

        guard let request = request() else {
            throw NSError(domain: configuration?.errorDomain ?? "", code: -876, userInfo: nil)
        }

        let data = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        let responseTuple = try await session.upload(for: request, from: data, delegate: nil)
        if let response = responseTuple.1 as? HTTPURLResponse {
            if !response.wasSuccessful {
                var userInfo = [String: Any]()
                if let json = try? JSONSerialization.jsonObject(
                    with: responseTuple.0,
                    options: .mutableContainers) as? [String: Any] {

                    userInfo[errorKey] = json as Any?

                } else if let string = String(data: responseTuple.0, encoding: String.Encoding.utf8) {
                    userInfo[errorKey] = string as Any?
                }
                throw NSError(domain: configuration?.errorDomain ?? "", code: response.statusCode, userInfo: userInfo)
            }
        }

        return try JSONSerialization.jsonObject(with: responseTuple.0, options: .mutableContainers) as? T
    }
    #endif

    func post<T: Codable>(
        _ session: GitURLSession = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder(),
        expectedResultType _: T.Type,
        completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol? {

        guard let request = request() else {
            return nil
        }

        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        } catch {
            completion(nil, error)
            return nil
        }

        let task = session.uploadTask(with: request, fromData: data) { data, response, error in
            if let response = response as? HTTPURLResponse, !response.wasSuccessful {
                var userInfo = [String: Any]()
                if let data = data, let json = try? JSONSerialization.jsonObject(
                    with: data,
                    options: .mutableContainers) as? [String: Any] {

                    userInfo[errorKey] = json as Any?

                } else if let data = data, let string = String(data: data, encoding: String.Encoding.utf8) {
                    userInfo[errorKey] = string as Any?
                }
                let error = NSError(
                    domain: self.configuration?.errorDomain ?? "",
                    code: response.statusCode,
                    userInfo: userInfo)

                completion(nil, error)

                return
            }

            if let error = error {
                completion(nil, error)
            } else {
                if let data = data {
                    do {
                        let decoded = try decoder.decode(T.self, from: data)
                        completion(decoded, nil)
                    } catch {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }

    #if !canImport(FoundationNetworking)
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func post<T: Codable>(
        _ session: GitURLSession,
        decoder: JSONDecoder = JSONDecoder(),
        expectedResultType _: T.Type) async throws -> T {

        guard let request = request() else {
            throw NSError(domain: configuration?.errorDomain ?? "", code: -876, userInfo: nil)
        }

        let data = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        let responseTuple = try await session.upload(for: request, from: data, delegate: nil)
        if let response = responseTuple.1 as? HTTPURLResponse, response.wasSuccessful == false {
            var userInfo = [String: Any]()
            if let json = try? JSONSerialization.jsonObject(
                with: responseTuple.0,
                options: .mutableContainers) as? [String: Any] {

                userInfo[errorKey] = json as Any?
            } else if let string = String(data: responseTuple.0, encoding: String.Encoding.utf8) {
                userInfo[errorKey] = string as Any?
            }
            throw NSError(domain: configuration?.errorDomain ?? "", code: response.statusCode, userInfo: userInfo)
        }

        return try decoder.decode(T.self, from: responseTuple.0)
    }
    #endif
}
