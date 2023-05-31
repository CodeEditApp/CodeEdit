//
//  Commands+ForEach.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI

// A custom ForEach struct is created instead of using the SwiftUI.ForEach one,
// as we can't create a new initializer due to a swift limitation.
// Instead, this CommandsForEach struct is used, which functions equally.

/// A structure that builds commandmenus on demand from an underlying collection of data.
/// Maximum 10 items are supported.
struct CommandsForEach<Data: RandomAccessCollection, Content: Commands>: Commands where Data.Index == Int {

    var data: Data

    var content: (Data.Element) -> Content

    init(_ data: Data, @CommandsBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

    var body: some Commands {
        switch data.count {
        case 0:
            EmptyCommands()
        case 1:
            CommandsBuilder.buildBlock(content(data[0]))
        case 2:
            CommandsBuilder.buildBlock(content(data[0]), content(data[1]))
        case 3:
            CommandsBuilder.buildBlock(content(data[0]), content(data[1]), content(data[2]))
        case 4:
            CommandsBuilder.buildBlock(content(data[0]), content(data[1]), content(data[2]), content(data[3]))
        case 5:
            CommandsBuilder.buildBlock(
                content(data[0]),
                content(data[1]),
                content(data[2]),
                content(data[3]),
                content(data[4])
            )
        case 6:
            CommandsBuilder.buildBlock(
                content(data[0]),
                content(data[1]),
                content(data[2]),
                content(data[3]),
                content(data[4]),
                content(data[5])
            )
        case 7:
            CommandsBuilder.buildBlock(
                content(data[0]),
                content(data[1]),
                content(data[2]),
                content(data[3]),
                content(data[4]),
                content(data[5]),
                content(data[6])
            )
        case 8:
            CommandsBuilder.buildBlock(
                content(data[0]),
                content(data[1]),
                content(data[2]),
                content(data[3]),
                content(data[4]),
                content(data[5]),
                content(data[6]),
                content(data[7])
            )
        case 9:
            CommandsBuilder.buildBlock(
                content(data[0]),
                content(data[1]),
                content(data[2]),
                content(data[3]),
                content(data[4]),
                content(data[5]),
                content(data[6]),
                content(data[7]),
                content(data[8])
            )
        default:
            CommandsBuilder.buildBlock(
                content(data[0]),
                content(data[1]),
                content(data[2]),
                content(data[3]),
                content(data[4]),
                content(data[5]),
                content(data[6]),
                content(data[7]),
                content(data[8]),
                content(data[9])
            )
        }
    }
}
