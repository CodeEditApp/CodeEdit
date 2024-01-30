//
//  LazyStringLoader.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.11.23.
//

import Foundation

class LazyStringLoader {
    let fileURL: URL
    var fileHandle: FileHandle?
    let chunkSize: Int
    let queue = DispatchQueue(label: "com.CodeEdit.LazyLoader")

    init(fileURL: URL, chunkSize: Int = 1024) {
        self.fileURL = fileURL
        self.chunkSize = chunkSize
    }

    func getNextChunk() -> String? {
        if fileHandle == nil {
            do {
                fileHandle = try FileHandle(forReadingFrom: fileURL)
            } catch {

            }

            var data = Data()
            let semaphore = DispatchSemaphore(value: 0)

            do {
                data = try fileHandle?.read(upToCount: chunkSize) ?? Data()
            } catch {

            }

            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
