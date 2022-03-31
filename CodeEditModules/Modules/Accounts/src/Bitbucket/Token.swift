//
//  Token.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public extension GitAccount {

    public func refreshToken(
        _ session: GitURLSession,
        oauthConfig: OAuthConfiguration,
        refreshToken: String,
        completion: @escaping (
            _ response: Response<TokenConfiguration>) -> Void) -> URLSessionDataTaskProtocol? {

        let request = TokenRouter.refreshToken(oauthConfig, refreshToken).URLRequest

        var task: URLSessionDataTaskProtocol?

        if let request = request {
            task = session.dataTask(with: request) { data, response, _ in

                guard let response = response as? HTTPURLResponse else { return }

                guard let data = data else { return }
                do {
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let responseJSON = responseJSON as? [String: AnyObject] {
                        if response.statusCode != 200 {
                            let errorDescription = responseJSON["error_description"] as? String ?? ""
                            let error = NSError(
                                domain: errorDomain,
                                code: response.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: errorDescription])
                            completion(Response.failure(error))
                        } else {
                            let tokenConfig = TokenConfiguration(json: responseJSON)
                            completion(Response.success(tokenConfig))
                        }
                    }
                }
            }
            task?.resume()
        }
        return task
    }
}
