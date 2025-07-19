//
//  UtilityAreaOutputSource.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/18/25.
//

import OSLog
import LogStream

protocol UtilityAreaOutputMessage: Identifiable {
    var message: String { get }
    var date: Date { get }
    var subsystem: String? { get }
    var category: String? { get }
    var level: UtilityAreaLogLevel { get }
}

protocol UtilityAreaOutputSource: Identifiable {
    associatedtype Message: UtilityAreaOutputMessage
    func cachedMessages() -> [Message]
    func streamMessages() -> AsyncStream<Message>
}
