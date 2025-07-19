//
//  OperatingSystemVersion+String.swift
//  CodeEdit
//
//  Created by Khan Winter on 5/27/25.
//

import Foundation

extension OperatingSystemVersion {
    var semverString: String {
        "\(majorVersion).\(minorVersion).\(patchVersion)"
    }
}
