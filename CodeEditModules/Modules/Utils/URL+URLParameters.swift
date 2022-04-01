//
//  URL+URLParameters.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

extension URL {
    var URLParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return [:] }
        var params = [String: String]()
        components.queryItems?.forEach { queryItem in
            params[queryItem.name] = queryItem.value
        }
        return params
    }
}
