//
//  ExtensionUtilityAreaOutputSource.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/18/25.
//

import OSLog
import LogStream

extension LogMessage: @retroactive Identifiable, UtilityAreaOutputMessage {
    public var id: String {
        "\(date.timeIntervalSince1970)" + process + (subsystem ?? "") + (category ?? "")
    }

    var level: UtilityAreaLogLevel {
        switch type {
        case .fault, .error:
                .error
        case .info, .default:
                .info
        case .debug:
                .debug
        default:
                .info
        }
    }
}

struct ExtensionUtilityAreaOutputSource: UtilityAreaOutputSource {
    var id: String {
        "extension_output" + extensionInfo.id
    }

    let extensionInfo: ExtensionInfo

    func cachedMessages() -> [LogMessage] {
        []
    }

    func streamMessages() -> AsyncStream<LogMessage> {
        LogStream.logs(for: extensionInfo.pid, flags: [.info, .historical, .processOnly])
    }
}
