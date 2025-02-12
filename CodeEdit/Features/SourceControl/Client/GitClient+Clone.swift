//
//  GitClient+Clone.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import Foundation
import Combine

extension GitClient {
    struct CloneProgress {
        let progress: Double
        let state: GitCloneProgressState
    }

    enum GitCloneProgressState {
        case initialState
        case counting
        case compressing
        case receiving
        case resolving

        var label: String {
            switch self {
            case .initialState: "Cloning"
            case .counting: "Counting"
            case .compressing: "Compressing"
            case .receiving: "Receiving"
            case .resolving: "Resolving"
            }
        }
    }

    /// Clone repository
    /// - Parameters:
    ///   - remoteUrl: URL of remote repository
    ///   - localPath: Local path to clone
    /// - Returns: Stream of progress
    func cloneRepository(
        remoteUrl: URL,
        localPath: URL
    ) -> AsyncThrowingMapSequence<LiveCommandStream, CloneProgress> {
        let command = "clone \(remoteUrl.absoluteString) \(localPath.relativePath.escapedDirectory()) --progress"

        return self.runLive(command)
            .map { line in
                // Inspired by VS Code https://github.com/microsoft/vscode/blob/main/extensions/git/src/git.ts
                // Parsing git clone output (for patterns look at cloneMatchTypes) and calculating total progress
                // Each step has own base progress and multiplier
                // Total progress is baseProgress + (progress from output * multiplier)
                // For example current outout is Counting objects: 10%, baseProgress is 0, multiplier is 0.1
                // So total progress is 0 + (10 * 0.1) = 1%
                for cloneMatchType in self.cloneMatchTypes {
                    if let progress = self.matchAndCalculateProgress(
                        line,
                        cloneMatchType.pattern,
                        baseProgress: cloneMatchType.baseProgress,
                        multiplier: cloneMatchType.multiplier
                    ) {
                        return .init(progress: progress, state: cloneMatchType.state)
                    }
                }

                return .init(progress: 0, state: .initialState)
            }
    }

    fileprivate struct CloneMatchType {
        let pattern: String
        let baseProgress: Double
        let multiplier: Double
        let state: GitCloneProgressState
    }

    fileprivate var cloneMatchTypes: [CloneMatchType] {
        [
            .init(pattern: "Counting objects:\\s*(\\d+)%", baseProgress: 0, multiplier: 0.1, state: .counting),
            .init(pattern: "Compressing objects:\\s*(\\d+)%", baseProgress: 10, multiplier: 0.1, state: .compressing),
            .init(pattern: "Receiving objects:\\s*(\\d+)%", baseProgress: 20, multiplier: 0.4, state: .receiving),
            .init(pattern: "Resolving deltas:\\s*(\\d+)%", baseProgress: 60, multiplier: 0.4, state: .resolving),
        ]
    }

    /// Match pattern in output line and calculate progress
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
