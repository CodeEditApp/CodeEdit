//
//  ChangedFile.swift
//  
//
//  Created by Nanashi Li on 2022/05/20.
//

import Foundation
import SwiftUI

struct GitChangedFile {
    /// Change type is to tell us whether the type is a new file, modified or deleted
    let changeType: GitType?

    /// Link of the file
    let fileLink: URL
}
