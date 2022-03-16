//
//  File.swift
//  
//
//  Created by Marco Carnevali on 16/03/22.
//
@testable import WorkspaceClient
import Foundation
import XCTest

final class WorkspaceClientUnitTests: XCTestCase {
    
    let typeOfExtensions = ["json", "txt", "swift", "js", "py", "md"]
    
    func testListFile() throws {
        let directory = try FileManager.default.url(for: .developerApplicationDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("CodeEdit", isDirectory: true)
            .appendingPathComponent("WorkspaceClientTests", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        let randomCount = Int.random(in: 1 ... 2)
        let files = generateRandomFiles(amount: randomCount)
        try files.forEach {
            let fakeData = "fake string".data(using: .utf8)
            let fileUrl = directory
                .appendingPathComponent($0)
            try fakeData!.write(to: fileUrl)
        }
        let client: WorkspaceClient = try .default(
            fileManager: .default,
            folderURL: directory,
            ignoredFilesAndFolders: []
        )
        print("file: ",files.count, " 2: ", client.getFiles().count)
        XCTAssertEqual(files, client.getFiles().map(\.url.lastPathComponent))
        try FileManager.default.removeItem(at: directory)
    }
    
    func generateRandomFiles(amount: Int) -> [String] {
        [String](repeating: "", count: amount)
            .map { _ in
                let fileName = randomString(length: Int.random(in: 1 ... 100))
                let fileExtension = typeOfExtensions[Int.random(in: 0 ..< typeOfExtensions.count)]
                return "\(fileName).\(fileExtension)"
            }
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
