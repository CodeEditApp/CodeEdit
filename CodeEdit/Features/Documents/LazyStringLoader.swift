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
                guard let data = try fileHandle?.read(upToCount: chunkSize) else {
                    return nil
                }
                return String(decoding: data, as: UTF8.self)
            } catch {
                return nil
            }
        }
        return nil
    }
}
