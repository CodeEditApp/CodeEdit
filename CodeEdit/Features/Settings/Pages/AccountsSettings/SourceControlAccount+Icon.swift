//
//  SourceControlAccount+Icon.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import SwiftUI
import CodeEditSettings

extension SourceControlAccount.Provider {
    /// The provider's icon from the app asset catalog. Lives app-side because
    /// `ImageResource` symbols are generated in the app target, not the package.
    var iconResource: ImageResource {
        switch self {
        case .bitbucketCloud, .bitbucketServer:
            return .bitBucketIcon
        case .github, .githubEnterprise:
            return .gitHubIcon
        case .gitlab, .gitlabSelfHosted:
            return .gitLabIcon
        }
    }
}
