//
//  NSURL+URLParameters.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

extension URL {
    func URLParameters() -> [String: String] {
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
