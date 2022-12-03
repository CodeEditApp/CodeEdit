//
//  BitbucketOAuthConfiguration.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

struct BitbucketOAuthConfiguration: RouterConfiguration {
    var apiEndpoint: String?
    var accessToken: String?
    let token: String
    let secret: String
    let scopes: [String]
    let webEndpoint: String
    let errorDomain = "com.codeedit.models.accounts.bitbucket"

    init(_ url: String = bitbucketBaseURL, webURL: String = bitbucketWebURL,
         token: String, secret: String, scopes: [String]
    ) {
        apiEndpoint = url
        webEndpoint = webURL
        self.token = token
        self.secret = secret
        self.scopes = []
    }

    func authenticate() -> URL? {
        OAuthRouter.authorize(self).URLRequest?.url
    }

    fileprivate func basicAuthenticationString() -> String {
        let clientIDSecretString = [token, secret].joined(separator: ":")
        let clientIDSecretData = clientIDSecretString.data(using: String.Encoding.utf8)
        let base64 = clientIDSecretData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        return "Basic \(base64 ?? "")"
    }

    func basicAuthConfig() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": basicAuthenticationString()]
        return config
    }

    func authorize(_ session: GitURLSession,
                   code: String,
                   completion: @escaping (_ config: BitbucketTokenConfiguration) -> Void
    ) {
        let request = OAuthRouter.accessToken(self, code).URLRequest

        if let request = request {
            let task = session.dataTask(with: request) { data, response, _ in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        return
                    } else {
                        if let config = self.configFromData(data) {
                            completion(config)
                        }
                    }
                }
            }
            task.resume()
        }
    }

    private func configFromData(_ data: Data?) -> BitbucketTokenConfiguration? {
        guard let data = data else { return nil }
        do {
            guard let json = try JSONSerialization.jsonObject(with: data,
                                                              options: .allowFragments) as? [String: AnyObject] else {
                return nil
            }
            let config = BitbucketTokenConfiguration(json: json)
            return config
        } catch {
            return nil
        }
    }

    func handleOpenURL(_ session: GitURLSession = URLSession.shared,
                       url: URL,
                       completion: @escaping (_ config: BitbucketTokenConfiguration) -> Void
    ) {
        let params = url.bitbucketURLParameters()

        if let code = params["code"] {
            authorize(session, code: code) { config in
                completion(config)
            }
        }
    }

    func accessTokenFromResponse(_ response: String) -> String? {
        let accessTokenParam = response.components(separatedBy: "&").first
        if let accessTokenParam = accessTokenParam {
            return accessTokenParam.components(separatedBy: "=").last
        }
        return nil
    }
}
