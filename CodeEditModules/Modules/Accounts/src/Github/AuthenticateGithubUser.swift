//
//  AuthenticateGithubUser.swift
//  
//
//  Created by Nanashi Li on 2022/04/08.
//

import Foundation

public func authenticateGithubAccount(_ gitProvider: String, githubToken: String) {
    switch gitProvider {
    case "github":
        let config = GithubTokenConfiguration(githubToken)
        GithubAccount(config).me() { response in
          switch response {
          case .success(let user):
            print(user.login as Any)
          case .failure(let error):
            print(error)
          }
        }
    case "githubEnterprise":
        let config = GithubTokenConfiguration(githubToken,
                                              url: "https://github.example.com/api/v3/")
        GithubAccount(config).me() { response in
          switch response {
          case .success(let user):
            print(user.login as Any)
          case .failure(let error):
            print(error)
          }
        }
    default:
        "Failed to authenticate with Github!"
    }
}
