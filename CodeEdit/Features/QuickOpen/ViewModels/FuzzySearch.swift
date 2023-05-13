//
//  FuzzySearch.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 04.05.23.
//

import Foundation

struct FuzzySearch {
    /// Searches an array of view models for occurrences of a fuzzy search query.
    ///
    /// This function takes a fuzzy search `query` and an array of `ViewModel` objects, and returns a new array that contains only
    /// those view models that match the query. The function uses the `score` function to calculate a score for each view model's
    /// `name` and `description` properties, and includes only those view models whose scores are greater than 0.0.
    /// The resulting array is then sorted by name score and description score, in descending order.
    ///
    /// - Parameters:
    ///   - query: A `String` value representing the fuzzy search query.
    ///   - array: An array of `ViewModel` objects to search within.
    /// - Returns: An array of `ViewModel` objects that match the fuzzy search query, sorted by name score and description score.
    static func search(query: String, in urls: [URL]) -> [URL] {
        let filteredResult = urls.filter { url -> Bool in
            let nameScore = score(query: query, url: url)
            return nameScore > 0.0
        }
        
        let sortedResult = filteredResult.sorted { url1, url2 -> Bool in
            let nameScore1 = score(query: query, url: url1)
            let nameScore2 = score(query: query, url: url2)
            if nameScore1 > nameScore2 {
                return true
            } else if nameScore1 < nameScore2 {
                return false
            } else {
                return false
            }
        }
        
        return sortedResult
    }

    /// Calculates the score of the fuzzy search query against a text string.
    ///
    /// This function takes a fuzzy search `query` and a `text` string, and calculates a score based on how well the `query`
    /// matches the `text`. The function is case-insensitive and calculates the score by iterating through each token in the
    /// `query`, finding all occurrences of the token in the `text`, and calculating a proximity score for each occurrence.
    /// The final score is the average of all token scores weighted by their proximity scores.
    ///
    /// - Parameters:
    ///   - query: A `String` value representing the fuzzy search query.
    ///   - url: A `URL` value representing the filePath to search within.
    /// - Returns: A `Double` value representing the calculated score.
    private static func score(query: String, url: URL) -> Double {
        let query = query.lowercased()
        let text = url.lastPathComponent.lowercased()
        let queryTokens = query.split(separator: " ")
        var score: Double = 0.0

        for token in queryTokens {
            let ranges = text.ranges(of: token)
            if !ranges.isEmpty {
                let tokenScore = Double(token.count) / Double(text.count)
                let proximityScore = proximityScoreForRanges(ranges)
                let levenshteinScore = Double(levenshteinDistance(from: String(token), to: text)) / Double(token.count)
                score += (tokenScore * proximityScore) * (1 - levenshteinScore)
            }
        }
        
        if let date = getLastModifiedDate(for: url.path) {
            return (score / Double(queryTokens.count)) * Double(calculateDateScore(for: date))
        } else {
            return (score / Double(queryTokens.count))
        }
    }
    
    /// Calculates the proximity score based on an array of ranges.
    ///
    /// This function takes an array of `Range<String.Index>` objects and calculates a proximity score.
    /// The higher the score, the closer the ranges are to each other in the original string.
    ///
    /// - Parameter ranges: An array of `Range<String.Index>` objects representing the positions of matched substrings.
    /// - Returns: A `Double` value representing the proximity score.
    private static func proximityScoreForRanges(_ ranges: [Range<String.Index>]) -> Double {
        let sortedRanges = ranges.sorted(by: { $0.lowerBound < $1.lowerBound })
        var score: Double = 1.0
        
        for index in 1..<sortedRanges.count {
            let previousRange = sortedRanges[index - 1]
            let currentRange = sortedRanges[index]
            let distance = currentRange.lowerBound.encodedOffset - previousRange.upperBound.encodedOffset
            let proximity = 1.0 / Double(distance)
            score += proximity
        }
        return score / Double(sortedRanges.count)
    }
    
    /// Retrieve the last modification date for a given file path.
    ///
    /// This function attempts to retrieve the last modification date of a file located at the specified file path.
    /// If the file path is valid and the modification date can be retrieved,
    /// the function returns a `Date` object representing the modification date.
    /// If an error occurs or the file path is invalid, the function returns `nil`.
    ///
    /// - Parameter filePath: The file path for which to retrieve the last modification date.
    /// - Returns: The last modification date as a `Date?` (optional) value, or `nil` if an error occurs or the file path is invalid.
    private static func getLastModifiedDate(for filePath: String) -> Date? {
        let fileManger = FileManager.default
        do {
            let attributes = try fileManger.attributesOfItem(atPath: filePath)
            let modificationDate = attributes[.modificationDate] as? Date
            return modificationDate
        } catch {
            return nil
        }
    }
    
    /// Calculate the date score for a given file's modification date.
    ///
    /// This function calculates the date score based on the time difference between the current date and the file's modification date,
    /// using an exponential decay function with a half-life of 3600 seconds (1 hour).
    /// The score will be higher for more recently modified files.
    ///
    /// - Parameter modificationDate: The file's modification date.
    /// - Returns: The date score as a `Double` value.
    private static func calculateDateScore(for modificationDate: Date) -> Double {
        let now = Date()
        let timeDiff = now.timeIntervalSince(modificationDate)
        let halfLife: Double = 3600 // decay half-life in seconds
        let decayFactor = log(2) / halfLife
        let score = exp(-decayFactor * timeDiff)
        return score
    }
    
    /// Levenshtein distance algorithm
    ///
    private static func levenshteinDistance(from sourceString: String, to targetString: String) -> Int {
        let source = Array(sourceString)
        let target = Array(sourceString)
        
        let sourceCount = source.count
        let targetCount = target.count
        
        guard sourceCount > 0 else {
            return targetCount
        }
        
        guard targetCount > 0 else {
            return sourceCount
        }
        
        var distanceMatrix = Array(repeating: Array(repeating: 0, count: targetCount + 1), count: sourceCount + 1)
        
        for rowIndex in 0...sourceCount {
            distanceMatrix[rowIndex][0] = rowIndex
        }
        
        for columnIndex in 0...targetCount {
            distanceMatrix[0][columnIndex] = columnIndex
        }
        
        for rowIndex in 1...sourceCount {
            for columnIndex in 1...targetCount {
                let cost = source[rowIndex - 1] == target[columnIndex - 1] ? 0 : 1
                
                let deletionCost = distanceMatrix[rowIndex - 1][columnIndex] + 1
                let insertionCost = distanceMatrix[rowIndex][columnIndex - 1] + 1
                let substitutionCost = distanceMatrix[rowIndex - 1][columnIndex - 1] + cost
                
                distanceMatrix[rowIndex][columnIndex] = min(deletionCost, insertionCost, substitutionCost)
            }
        }
        
        return distanceMatrix[sourceCount][targetCount]
    }
}


/// Adds a new function to the `String` type that searches for all occurrences of a given substring within the original string.
///
/// This function is case-insensitive and returns an array of `Range<String.Index>` objects representing
/// the positions of all occurrences of the `searchString` within the original string.
/// The function starts searching from the beginning of the string and continues until the end is reached.
///
/// - Parameter searchString: A `String` value to search for within the original string.
/// - Returns: An array of `Range<String.Index>` objects representing the positions of all occurrences of `searchString`.
extension String {
    func ranges(of searchString: String) -> [Range<String.Index>] {
        var result: [Range<String.Index>] = []
        var searchStartIndex = startIndex
        while let range = self[searchStartIndex..<endIndex].range(of: searchString, options: .caseInsensitive) {
            result.append(range)
            searchStartIndex = range.upperBound
        }
        return result
    }
}
