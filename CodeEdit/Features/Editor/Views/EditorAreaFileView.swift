//
//  EditorAreaFileView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 20.03.22.
//

import AppKit
import AVKit
import CodeEditSourceEditor
import SwiftUI
import WebKit
import UniformTypeIdentifiers
import Combine
import Foundation
import Darwin

// MARK: - Display Modes
enum EditorDisplayMode: String, CaseIterable, Identifiable {
    case code = "Code"
    case split = "Split"
    case preview = "Preview"
    var id: String { rawValue }
}

// MARK: - Preview Source
enum PreviewSource {
    case localHTML
    case serverPreview
}

// MARK: - HTML Rendering Backend Abstraction
struct HTMLRenderer {
    var render: ((String) -> String)?
    var renderAsync: ((String) async -> String)?
    var loggingEnabled: Bool = false

    func renderHTML(from source: String) async -> String {
        if loggingEnabled { print("[Preview] Rendering start. Source length: \(source.count)") }
        let output: String
        if let renderAsync {
            output = await renderAsync(source)
        } else if let render {
            output = render(source)
        } else {
            output = source
        }
        if loggingEnabled { print("[Preview] Rendering done. HTML length: \(output.count)") }
        return output
    }
}

// MARK: - WebKit Crash-Aware Delegate
final class PreviewNavDelegate: NSObject, WKNavigationDelegate {
    var onCrash: (() -> Void)?

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("[WebView] WebContent process terminated")
        onCrash?()
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("[WebView] didFailProvisionalNavigation: \(error.localizedDescription)")
        onCrash?()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("[WebView] didFail navigation: \(error.localizedDescription)")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("[WebView] didFinish navigation. URL: \(webView.url?.absoluteString ?? "nil")")
    }
}

// MARK: - WebView (Coordinator reuse, safe refresh)
struct WebView: NSViewRepresentable {
    let html: String
    let baseURL: URL?
    let onCrash: () -> Void
    let allowJavaScript: Bool

    class Coordinator {
        let webView: WKWebView
        let navDelegate = PreviewNavDelegate()
        var lastHTML: String = ""
        var lastLoadAt: Date = .distantPast

        init(onCrash: @escaping () -> Void, allowJavaScript: Bool) {
            let config = WKWebViewConfiguration()
            config.preferences.javaScriptEnabled = allowJavaScript
            config.websiteDataStore = .default()
            config.suppressesIncrementalRendering = true

            let wv = WKWebView(frame: .zero, configuration: config)
            wv.setValue(false, forKey: "drawsBackground")
            navDelegate.onCrash = onCrash
            wv.navigationDelegate = navDelegate
            self.webView = wv
        }

        func safeLoad(html: String, baseURL: URL?) {
            let now = Date()
            if now.timeIntervalSince(lastLoadAt) < 1.0, lastHTML == html { return }
            lastLoadAt = now
            lastHTML = html
            webView.stopLoading()
            webView.loadHTMLString(html, baseURL: baseURL)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(onCrash: onCrash, allowJavaScript: allowJavaScript) }
    func makeNSView(context: Context) -> WKWebView { context.coordinator.webView }
    func updateNSView(_ webView: WKWebView, context: Context) { context.coordinator.safeLoad(html: html, baseURL: baseURL) }
}

// MARK: - Markdown Renderer
struct MarkdownView: NSViewRepresentable {
    let source: String

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        let textView = NSTextView()
        textView.isEditable = false
        textView.backgroundColor = .white
        textView.textContainerInset = NSSize(width: 8, height: 8)
        scroll.documentView = textView
        return scroll
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        let attributed = renderMarkdown(source)
        textView.textStorage?.setAttributedString(attributed)
    }

    private func renderMarkdown(_ source: String) -> NSAttributedString {
        if source.isEmpty { return NSAttributedString(string: "") }
        if #available(macOS 12.0, *) {
            if let attributed = try? NSAttributedString(markdown: source) {
                return attributed
            }
        }
        return NSAttributedString(string: source)
    }
}

// MARK: - Server Preview Client
struct ServerPreviewClient {
    let baseURL = URL(string: "http://localhost:3000")!
    let path = "/preview"
    let timeout: TimeInterval = 8

    func postHTML(_ html: String, filename: String?) async throws -> String {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path = path
        guard let url = components.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = timeout
        let payload: [String: Any] = [
            "html": html,
            "filename": filename ?? "untitled.html",
            "timestamp": Date().timeIntervalSince1970
        ]
        let data = try JSONSerialization.data(withJSONObject: payload, options: [])
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: configuration)
        let (respData, resp) = try await session.upload(for: request, from: data)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        if !(200...299).contains(http.statusCode) {
            let bodyString = String(data: respData, encoding: .utf8) ?? ""
            throw NSError(domain: "ServerPreview", code: http.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "Server preview failed (\(http.statusCode)).",
                "body": bodyString
            ])
        }
        return String(data: respData, encoding: .utf8) ?? ""
    }
}

extension Notification.Name {
    static let CodeFileDocumentContentDidChange = Notification.Name("CodeFileDocumentContentDidChange")
}

// MARK: - Bottom Controls Overlay
struct PreviewBottomBar: View {
    let refresh: () -> Void
    let reloadIgnoreCache: () -> Void
    @Binding var enableJS: Bool
    @Binding var previewSource: PreviewSource
    let serverErrorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button("Refresh") { refresh() }
                        .keyboardShortcut("r", modifiers: [])
                    Button("Reload (ignore cache)") { reloadIgnoreCache() }
                    Toggle("Enable JS", isOn: $enableJS)
                    Picker("Preview Source", selection: $previewSource) {
                        Text("Local").tag(PreviewSource.localHTML)
                        Text("Server").tag(PreviewSource.serverPreview)
                    }
                    .pickerStyle(.segmented)
                    Menu("More") {
                        Button("Refresh") { refresh() }
                        Button("Reload (ignore cache)") { reloadIgnoreCache() }
                        Toggle("Enable JS", isOn: $enableJS)
                        Picker("Preview Source", selection: $previewSource) {
                            Text("Local").tag(PreviewSource.localHTML)
                            Text("Server").tag(PreviewSource.serverPreview)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .background(Color(NSColor.windowBackgroundColor))
            if let serverErrorMessage, previewSource == .serverPreview {
                Text("Server error: \(serverErrorMessage)")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 6)
            }
        }
    }
}

// MARK: - Directory Watcher (helper)
final class DirectoryWatcher {
    private var fd: CInt = -1
    private var source: DispatchSourceFileSystemObject?
    private let queue = DispatchQueue(label: "codeedit.filewatch.queue")
    private var lastEventAt: Date = .distantPast
    private let debounceInterval: TimeInterval = 0.25

    func startWatching(url: URL, onChange: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        stop()

        let dirURL = url.deletingLastPathComponent()
        fd = open(dirURL.path, O_EVTONLY)
        guard fd >= 0 else {
            onError(NSError(domain: "DirectoryWatcher", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to open directory: \(dirURL.path)"
            ]))
            return
        }

        let mask: DispatchSource.FileSystemEvent = [.write, .rename, .delete, .attrib, .extend]
        let src = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: mask, queue: queue)
        source = src

        src.setEventHandler { [weak self] in
            guard let self else { return }
            let now = Date()
            if now.timeIntervalSince(self.lastEventAt) < self.debounceInterval { return }
            self.lastEventAt = now
            onChange() // caller hops to main if needed
        }

        src.setCancelHandler { [weak self] in
            guard let self else { return }
            if self.fd >= 0 { close(self.fd) }
            self.fd = -1
            self.source = nil
        }

        src.resume()
        print("[FS Watch] Started for directory: \(dirURL.path)")
    }

    func stop() {
        source?.cancel()
        source = nil
        if fd >= 0 { close(fd) }
        fd = -1
    }

    deinit { stop() }
}

// MARK: - Main View
struct EditorAreaFileView: View {
    @EnvironmentObject private var editorManager: EditorManager
    @EnvironmentObject private var editor: Editor
    @EnvironmentObject private var statusBarViewModel: StatusBarViewModel
    @Environment(\.edgeInsets) private var edgeInsets

    var editorInstance: EditorInstance
    var codeFile: CodeFileDocument

    var htmlRenderer: HTMLRenderer = .init(
        render: { source in
            let trimmed = source.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let looksHTML = trimmed.hasPrefix("<!doctype") || trimmed.hasPrefix("<html")
            if looksHTML { return source }
            let escaped = source
                .replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
            return """
            <!doctype html>
            <html>
              <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <style>
                  html, body { margin: 0; padding: 0; background: #ffffff; color: #111; font: -apple-system-body; }
                  pre { white-space: pre-wrap; word-wrap: break-word; margin: 0; padding: 16px; }
                  h1, h2, h3, p { margin-top: 0; }
                </style>
              </head>
              <body><pre>\(escaped)</pre></body>
            </html>
            """
        },
        loggingEnabled: true
    )
    var enablePreviewLogging: Bool = true

    @State private var renderedHTMLState: String = ""
    @State private var contentString: String = ""
    @State private var displayMode: EditorDisplayMode = .split
    @State private var cancellables = Set<AnyCancellable>()
    @State private var renderWorkItem: DispatchWorkItem?

    @State private var webViewAllowJS: Bool = false
    @State private var previewSource: PreviewSource = .localHTML

    private let serverClient = ServerPreviewClient()
    @State private var serverErrorMessage: String?

    @State private var webViewRefreshToken = UUID()

    // FS watcher state
    @State private var watcher = DirectoryWatcher()
    @State private var lastKnownFileMTime: Date?

    // Fixed size constants
    private let FIXED_PREVIEW_HEIGHT: CGFloat = 320
    private let FIXED_PREVIEW_WIDTH: CGFloat = 420

    private func bindContent() {
        NotificationCenter.default.publisher(
            for: .CodeFileDocumentContentDidChange,
            object: codeFile
        )
        .compactMap { _ in codeFile.content?.string }
        .removeDuplicates()
        .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
        .sink { newText in
            updatePreview(with: newText)
        }
        .store(in: &cancellables)
    }

    private func scheduleRender(for source: String) {
        renderWorkItem?.cancel()
        let work = DispatchWorkItem {
            Task { @MainActor in
                if enablePreviewLogging { print("[Preview] Source changed. Rendering…") }
                switch previewSource {
                case .localHTML:
                    let html = await htmlRenderer.renderHTML(from: source)
                    serverErrorMessage = nil
                    if renderedHTMLState != html {
                        renderedHTMLState = html
                        webViewRefreshToken = UUID()
                        print("[Preview] Local HTML set. length: \(html.count)")
                    } else {
                        print("[Preview] No state change (same HTML)")
                    }
                case .serverPreview:
                    let localHTML = await htmlRenderer.renderHTML(from: source)
                    if renderedHTMLState != localHTML {
                        renderedHTMLState = localHTML
                        print("[Preview] Fallback local HTML set. length: \(localHTML.count)")
                    }
                    await loadServerPreview(with: source)
                }
            }
        }
        renderWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
    }

    @MainActor
    private func loadServerPreview(with source: String) async {
        serverErrorMessage = nil
        do {
            let filename = codeFile.fileURL?.lastPathComponent
            let serverHTML = try await serverClient.postHTML(source, filename: filename)
            if renderedHTMLState != serverHTML {
                renderedHTMLState = serverHTML
                print("[Preview] Server HTML set. length: \(serverHTML.count)")
            } else {
                print("[Preview] Server returned identical HTML; no state change.")
            }
        } catch {
            let message: String
            if let urlError = error as? URLError {
                switch urlError.code {
                case .cannotFindHost: message = "Cannot find server at localhost:3000."
                case .timedOut: message = "Server preview timed out."
                case .notConnectedToInternet: message = "No network connection."
                default: message = "Network error: \(urlError.localizedDescription)"
                }
            } else {
                message = error.localizedDescription
            }
            serverErrorMessage = message
            print("[Preview] Server preview error: \(message)")
        }
    }

    private func updatePreview(with newText: String) {
        if contentString != newText {
            contentString = newText
            scheduleRender(for: newText)
        }
    }

    private func refreshPreview() {
        print("[Preview] Manual refresh triggered")
        scheduleRender(for: contentString)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            webViewRefreshToken = UUID()
        }
    }

    // MARK: - FS Watch helpers 
    private func startFileWatchIfNeeded() {
        guard let fileURL = codeFile.fileURL else { return }

        // Record current mtime to filter unrelated directory events
        lastKnownFileMTime = (try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate

        watcher.startWatching(url: fileURL) { [fileURL] in
            // Compute new mtime off the main thread
            let mtime = (try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate

            // Hop to main to mutate state and refresh UI
            DispatchQueue.main.async {
                if self.lastKnownFileMTime == mtime { return }
                self.lastKnownFileMTime = mtime

                if let newText = self.codeFile.content?.string {
                    self.updatePreview(with: newText)
                } else {
                    do {
                        let data = try Data(contentsOf: fileURL)
                        let newText = String(data: data, encoding: .utf8) ?? ""
                        self.updatePreview(with: newText)
                    } catch {
                        print("[FS Watch] Failed reading file: \(error.localizedDescription)")
                    }
                }

                self.webViewRefreshToken = UUID()
            }
        } onError: { err in
            DispatchQueue.main.async {
                print("[FS Watch] Error: \(err.localizedDescription)")
            }
        }
    }

    private func stopFileWatch() {
        watcher.stop()
    }

    // MARK: - Layout
    @ViewBuilder var editorAreaFileView: some View {
        let pathExt = codeFile.fileURL?.pathExtension.lowercased() ?? ""
        let isHTML = (codeFile.utType?.conforms(to: .html) ?? false) || (["html", "htm"].contains(pathExt))
        let isMarkdown = (codeFile.utType?.identifier == "net.daringfireball.markdown") || (pathExt == "md" || pathExt == "markdown")

        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Picker("Display Mode", selection: $displayMode) {
                    ForEach(EditorDisplayMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                Spacer(minLength: 8)
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)

            Divider()

            if isHTML {
                switch displayMode {
                case .code:
                    CodeFileView(editorInstance: editorInstance, codeFile: codeFile)

                case .preview:
                    VStack(spacing: 0) {
                        ZStack {
                            WebView(
                                html: renderedHTMLState.isEmpty
                                    ? "<!doctype html><html><body style='background:#fff'><h1>Preview Ready</h1></body></html>"
                                    : renderedHTMLState,
                                baseURL: codeFile.fileURL?.deletingLastPathComponent(),
                                onCrash: { /* WebKit always on; show message if needed */ },
                                allowJavaScript: webViewAllowJS
                            )
                            .id(webViewRefreshToken)
                            .frame(maxWidth: .infinity, minHeight: FIXED_PREVIEW_HEIGHT, maxHeight: FIXED_PREVIEW_HEIGHT)
                            .background(Color.white)

                            VStack(spacing: 0) {
                                Spacer()
                                PreviewBottomBar(
                                    refresh: { refreshPreview() },
                                    reloadIgnoreCache: { webViewRefreshToken = UUID() },
                                    enableJS: $webViewAllowJS,
                                    previewSource: $previewSource,
                                    serverErrorMessage: serverErrorMessage
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .split:
                    HStack(spacing: 0) {
                        CodeFileView(editorInstance: editorInstance, codeFile: codeFile)

                        VStack(spacing: 0) {
                            ZStack {
                                WebView(
                                    html: renderedHTMLState.isEmpty
                                        ? "<!doctype html><html><body style='background:#fff'><h1>Preview Ready</h1></body></html>"
                                        : renderedHTMLState,
                                    baseURL: codeFile.fileURL?.deletingLastPathComponent(),
                                    onCrash: { /* WebKit always on */ },
                                    allowJavaScript: webViewAllowJS
                                )
                                .id(webViewRefreshToken)
                                .frame(maxWidth: .infinity, minHeight: FIXED_PREVIEW_HEIGHT, maxHeight: FIXED_PREVIEW_HEIGHT)
                                .background(Color.white)

                                VStack(spacing: 0) {
                                    Spacer()
                                    PreviewBottomBar(
                                        refresh: { refreshPreview() },
                                        reloadIgnoreCache: { webViewRefreshToken = UUID() },
                                        enableJS: $webViewAllowJS,
                                        previewSource: $previewSource,
                                        serverErrorMessage: serverErrorMessage
                                    )
                                }
                            }
                        }
                        .frame(width: FIXED_PREVIEW_WIDTH)
                        .frame(maxHeight: .infinity)
                        .background(Color.white)
                    }
                }
            } else if isMarkdown {
                switch displayMode {
                case .code:
                    CodeFileView(editorInstance: editorInstance, codeFile: codeFile)

                case .preview:
                    VStack(spacing: 0) {
                        ZStack {
                            MarkdownView(source: contentString)
                                .frame(maxWidth: .infinity, minHeight: FIXED_PREVIEW_HEIGHT, maxHeight: FIXED_PREVIEW_HEIGHT)
                                .background(Color.white)

                            VStack(spacing: 0) {
                                Spacer()
                                PreviewBottomBar(
                                    refresh: { refreshPreview() },
                                    reloadIgnoreCache: { webViewRefreshToken = UUID() },
                                    enableJS: $webViewAllowJS,
                                    previewSource: $previewSource,
                                    serverErrorMessage: serverErrorMessage
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .split:
                    HStack(spacing: 0) {
                        CodeFileView(editorInstance: editorInstance, codeFile: codeFile)
                        VStack(spacing: 0) {
                            ZStack {
                                MarkdownView(source: contentString)
                                    .frame(maxWidth: .infinity, minHeight: FIXED_PREVIEW_HEIGHT, maxHeight: FIXED_PREVIEW_HEIGHT)
                                    .background(Color.white)
                                VStack(spacing: 0) {
                                    Spacer()
                                    PreviewBottomBar(
                                        refresh: { refreshPreview() },
                                        reloadIgnoreCache: { webViewRefreshToken = UUID() },
                                        enableJS: $webViewAllowJS,
                                        previewSource: $previewSource,
                                        serverErrorMessage: serverErrorMessage
                                    )
                                }
                            }
                        }
                        .frame(minWidth: FIXED_PREVIEW_WIDTH,
                               idealWidth: FIXED_PREVIEW_WIDTH,
                               maxWidth: FIXED_PREVIEW_WIDTH,
                               maxHeight: .infinity, alignment: .center)
                        .background(Color.white)
                    }
                }
            } else if let utType = codeFile.utType, utType.conforms(to: .text) {
                CodeFileView(editorInstance: editorInstance, codeFile: codeFile)

            } else {
                NonTextFileView(fileDocument: codeFile)
                    .padding(.top, edgeInsets.top - 1.74)
                    .padding(.bottom, StatusBarView.height + 1.26)
                    .modifier(UpdateStatusBarInfo(with: codeFile.fileURL))
                    .onDisappear {
                        statusBarViewModel.dimensions = nil
                        statusBarViewModel.fileSize = nil
                    }
            }
        }
        .onAppear {
            bindContent()
            let sourceString = codeFile.content?.string ?? ""
            contentString = sourceString
            Task { @MainActor in
                let html = await htmlRenderer.renderHTML(from: sourceString)
                serverErrorMessage = nil
                if renderedHTMLState != html {
                    renderedHTMLState = html
                    print("[Preview] Initial set. html length: \(html.count)")
                }
                if previewSource == .serverPreview {
                    await loadServerPreview(with: sourceString)
                }
            }
            startFileWatchIfNeeded()
        }
        .onChange(of: codeFile.fileURL) { _ in
            stopFileWatch()
            startFileWatchIfNeeded()
        }
        .onDisappear {
            stopFileWatch()
        }
    }

    var body: some View {
        editorAreaFileView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onHover { hover in
                DispatchQueue.main.async {
                    if hover { NSCursor.iBeam.push() } else { NSCursor.pop() }
                }
            }
    }
}
