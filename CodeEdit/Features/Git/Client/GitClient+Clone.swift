//
//  GitClient+Clone.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import Foundation
import Combine

extension GitClient {
    /// Clone repository
    /// - Parameters:
    ///   - remoteUrl: URL of remote repository
    ///   - localPath: Local path to clone
    /// - Returns: Stream of progress
    func cloneRepository(
        remoteUrl: URL,
        localPath: URL
    ) -> AsyncThrowingMapSequence<LiveCommandStream, Double> {
        let command = "clone \(remoteUrl.absoluteString) \(localPath.relativePath.escapedWhiteSpaces()) --progress"

        return self.runLive(command)
            .map { line in
                // Parsing inspired by VS Code https://github.com/microsoft/vscode/blob/main/extensions/git/src/git.ts
                for cloneMatchType in self.cloneMatchTypes {
                    if let progress = self.matchAndCalculateProgress(
                        line,
                        cloneMatchType.pattern,
                        baseProgress: cloneMatchType.baseProgress,
                        multiplier: cloneMatchType.multiplier
                    ) {
                        return progress
                    }
                }

                return 0
            }
    }

    fileprivate struct CloneMatchType {
        let pattern: String
        let baseProgress: Double
        let multiplier: Double
    }

    fileprivate var cloneMatchTypes: [CloneMatchType] {
        [
            .init(pattern: "Counting objects:\\s*(\\d+)%", baseProgress: 0, multiplier: 0.1),
            .init(pattern: "Compressing objects:\\s*(\\d+)%", baseProgress: 10, multiplier: 0.1),
            .init(pattern: "Receiving objects:\\s*(\\d+)%", baseProgress: 20, multiplier: 0.4),
            .init(pattern: "Resolving deltas:\\s*(\\d+)%", baseProgress: 60, multiplier: 0.4),
        ]
    }

    fileprivate func matchAndCalculateProgress(
        _ line: String,
        _ pattern: String,
        baseProgress: Double,
        multiplier: Double
    ) -> Double? {
        let match = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            .firstMatch(in: line, range: NSRange(line.startIndex..., in: line))

        if let match,
           let range = Range(match.range(at: 1), in: line),
           let progress = Int(line[range]) {
            return baseProgress + Double(progress) * multiplier
        }
        return nil
    }
}
