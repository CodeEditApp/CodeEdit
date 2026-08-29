//
//  SwiftUIPreviewRunner.swift
//  CodeEdit
//
//  Created by Aryan Rogye on 5/4/26.
//

import AppKit
import Darwin
import Foundation

@MainActor
final class SwiftUIPreviewRunner: ObservableObject {
    @Published var previewView: NSView?
    @Published var logs: [String] = []
    @Published var isCompiling = false

    private var loadedLibraryHandles: [UnsafeMutableRawPointer] = []
    private var compileTask: Task<Void, Never>?

    func compile(source: String, fileURL: URL?) {
        compileTask?.cancel()
        compileTask = Task { await compilePreview(source: source, fileURL: fileURL) }
    }

    func clear() {
        compileTask?.cancel()
        previewView = nil
        logs.removeAll()
        isCompiling = false
    }

    private func compilePreview(source: String, fileURL: URL?) async {
        guard let previewSource = SwiftUIPreviewParser.firstPreview(in: source) else {
            clear()
            return
        }

        isCompiling = true
        previewView = nil
        logs = []
        defer { isCompiling = false }

        logs.append("Found #Preview in \(fileURL?.lastPathComponent ?? "current file")")

        let packageURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("CodeEditPreview-\(UUID().uuidString)")

        do {
            try writePreviewPackage(previewSource, to: packageURL)
        } catch {
            logs.append("Failed to write preview package: \(error.localizedDescription)")
            return
        }

        logs.append("Preview package path: \(packageURL.path)")

        guard await buildPreviewPackage(at: packageURL) else {
            return
        }

        let dylibURL = packageURL
            .appendingPathComponent(".build")
            .appendingPathComponent("debug")
            .appendingPathComponent("libCodeEditPreview.dylib")

        loadPreview(from: dylibURL)
    }

    private func writePreviewPackage(_ previewSource: SwiftUIPreviewSource, to packageURL: URL) throws {
        let sourcesURL = packageURL
            .appendingPathComponent("Sources")
            .appendingPathComponent("CodeEditPreview")

        try FileManager.default.createDirectory(
            at: sourcesURL,
            withIntermediateDirectories: true
        )

        try packageFile.write(
            to: packageURL.appendingPathComponent("Package.swift"),
            atomically: true,
            encoding: .utf8
        )

        try previewSource.sourceWithoutPreviews.write(
            to: sourcesURL.appendingPathComponent("PreviewSource.swift"),
            atomically: true,
            encoding: .utf8
        )

        try previewFactory(previewBody: previewSource.previewBody).write(
            to: sourcesURL.appendingPathComponent("PreviewFactory.swift"),
            atomically: true,
            encoding: .utf8
        )
    }

    private func buildPreviewPackage(at packageURL: URL) async -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = ["build", "--package-path", packageURL.path]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        let outputStream = AsyncStream<String> { continuation in
            pipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                guard !data.isEmpty else {
                    continuation.finish()
                    return
                }
                if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                    continuation.yield(output)
                }
            }

            process.terminationHandler = { _ in
                pipe.fileHandleForReading.readabilityHandler = nil
                continuation.finish()
            }
        }

        do {
            try process.run()
        } catch {
            logs.append("Failed to start swift build: \(error.localizedDescription)")
            return false
        }

        for await output in outputStream {
            guard !Task.isCancelled else {
                process.terminate()
                return false
            }
            logs.append(output)
        }

        guard process.terminationStatus == 0 else {
            logs.append("swift build failed with exit code \(process.terminationStatus)")
            return false
        }

        logs.append("swift build succeeded")
        return true
    }

    private func loadPreview(from dylibURL: URL) {
        guard FileManager.default.fileExists(atPath: dylibURL.path) else {
            logs.append("Built dylib not found at: \(dylibURL.path)")
            return
        }

        guard let handle = dlopen(dylibURL.path, RTLD_NOW | RTLD_LOCAL) else {
            logs.append("dlopen failed: \(String(cString: dlerror()))")
            return
        }

        guard let symbol = dlsym(handle, "makeCodeEditPreviewView") else {
            logs.append("Could not find makeCodeEditPreviewView symbol")
            return
        }

        typealias MakePreviewView = @convention(c) () -> UnsafeMutableRawPointer
        let makePreviewView = unsafeBitCast(symbol, to: MakePreviewView.self)
        let pointer = makePreviewView()

        previewView = Unmanaged<NSView>.fromOpaque(pointer).takeRetainedValue()
        loadedLibraryHandles.append(handle)
        logs.append("Loaded preview dylib")
    }

    private var packageFile: String {
        """
        // swift-tools-version: 5.9
        import PackageDescription

        let package = Package(
            name: "CodeEditPreview",
            platforms: [
                .macOS(.v14)
            ],
            products: [
                .library(
                    name: "CodeEditPreview",
                    type: .dynamic,
                    targets: ["CodeEditPreview"]
                )
            ],
            targets: [
                .target(name: "CodeEditPreview")
            ]
        )
        """
    }

    private func previewFactory(previewBody: String) -> String {
        """
        import AppKit
        import SwiftUI

        private enum __CodeEditPreviewFactory {
            @ViewBuilder
            static func makePreview() -> some View {
        \(previewBody.indentingPreviewBody())
            }
        }

        @_cdecl("makeCodeEditPreviewView")
        public func makeCodeEditPreviewView() -> UnsafeMutableRawPointer {
            let view = NSHostingView(rootView: __CodeEditPreviewFactory.makePreview())
            return Unmanaged.passRetained(view).toOpaque()
        }
        """
    }
}

private extension String {
    func indentingPreviewBody() -> String {
        split(separator: "\n", omittingEmptySubsequences: false)
            .map { "        \($0)" }
            .joined(separator: "\n")
    }
}
