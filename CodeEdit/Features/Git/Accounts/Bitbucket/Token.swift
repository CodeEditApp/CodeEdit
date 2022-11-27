//
//  Token.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)
extension BitbucketAccount {

    func refreshToken(
        _ session: GitURLSession,
        oauthConfig: BitbucketOAuthConfiguration,
        refreshToken: String,
        completion: @escaping (_ response: Result<BitbucketTokenConfiguration, Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
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
                                domain: "com.codeedit.models.accounts.bitbucket",
                                code: response.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: errorDescription])
                            completion(Result.failure(error))
                        } else {
                            let tokenConfig = BitbucketTokenConfiguration(json: responseJSON)
                            completion(Result.success(tokenConfig))
                        }
                    }
                }
            }
            task?.resume()
        }
        return task
    }
}
