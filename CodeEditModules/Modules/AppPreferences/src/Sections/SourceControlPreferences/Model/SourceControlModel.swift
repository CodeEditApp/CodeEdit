//
//  SourceControlModel.swift
//  
//
//  Created by Nanashi Li on 2022/04/13.
//

import Foundation

public class SourceControlModel: ObservableObject {

    public static let shared: SourceControlModel = .init()

    /// The selected tab in the main section.
    /// - **0**: General
    /// - **1**: Git
    @Published
    var selectedTab: Int = 0

}
