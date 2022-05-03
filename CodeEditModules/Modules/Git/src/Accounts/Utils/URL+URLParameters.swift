//
//  URL+URLParameters.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//
import Foundation

extension URL {

    var URLParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return [:] }
        var params = [String: String]()
        components.queryItems?.forEach { queryItem in
            params[queryItem.name] = queryItem.value
        }
        return params
    }

    func bitbucketURLParameters() -> [String: String] {
            let stringParams = absoluteString.components(separatedBy: "?").last
            let params = stringParams?.components(separatedBy: "&")
            var returnParams: [String: String] = [:]
            if let params = params {
                for param in params {
                    let keyValue = param.components(separatedBy: "=")
                    if let key = keyValue.first, let value = keyValue.last {
                        returnParams[key] = value
                    }
                }
            }
            return returnParams
        }
}
