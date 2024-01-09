//
//  TerminalEmulator.swift
//  CodeEdit
//
//  Created by Christophe Bronner on 2023-12-23.
//

import SwiftUI
import UniformTypeIdentifiers
import Combine
import SwiftTerm

final class TerminalEmulator: ObservableObject, Identifiable {

    /// The current directory of this terminal
    @Published var url: URL

    /// The terminal's activity as reported by the shell
    @Published var activity: String?

    /// The terminal's custom title, set by the user
    @Published var customTitle: String?

    @Published private var groupWorkaround = NoPropertyWrappersWithWeakWorkaround()

    public var groupPublisher: AnyPublisher<TerminalGroup?, Never> {
        $groupWorkaround.map(\.group).eraseToAnyPublisher()
    }

    /// The terminal's current group, if any
    public var group: TerminalGroup? {
        get { groupWorkaround.group }
        set { groupWorkaround.group = newValue }
    }

    private struct NoPropertyWrappersWithWeakWorkaround {
        weak var group: TerminalGroup?
    }

    /// The terminal's shell
    let shell: String

    /// The backing view
    let nsview: LocalProcessTerminalView

    init(at url: URL, shell: String? = nil) {
        self.url = url
        self.shell = shell ?? TerminalEmulator.detectSystemShell()

        nsview = LocalProcessTerminalView(frame: .zero)
        nsview.processDelegate = self
        setupStyle()
        setupSession()

        TerminalEmulator.cache[cacheIdentifier] = CacheEntry(terminal: self)
    }

    var title: String {
        customTitle ?? activity ?? "terminal"
    }

    func move(to newGroup: TerminalGroup) {
        if let group, let index = group.children.firstIndex(of: self) {
            group.children.remove(at: index)
        }
        newGroup.children.append(self)
        group = newGroup
    }

    // MARK: - Cache

    private static var cache: [UUID: CacheEntry] = [:]
    private let cacheIdentifier = UUID()

    deinit {
        TerminalEmulator.cache.removeValue(forKey: cacheIdentifier)
    }

    private struct CacheEntry {
        unowned let terminal: TerminalEmulator
    }

    static func resolve(_ identifier: UUID) -> TerminalEmulator? {
        cache[identifier]?.terminal
    }

    // MARK: - Style

    private func setupStyle() {
        DispatchQueue.main.async {
            self.nsview.layer?.backgroundColor = .clear

            let scroller = self.nsview.subviews.lazy
                .compactMap { $0 as? NSScroller }
                .first
            scroller?.isHidden = true
        }
    }

    // MARK: - Session & Shell

    private static let integrationBASH = integration(for: "bash")!
    private static let integrationZSH = integration(for: "zsh")!

    private static func integration(for shell: String) -> String? {
        guard let url = Bundle.main.url(forResource: "codeedit_shell_integration", withExtension: shell) else {
            assertionFailure("Missing shell integration script for '\(shell)', ensure it is present in the bundle")
            return nil
        }
        var path = url.absoluteString
        path.removeFirst(7)
        return path
    }

    /// Gets the default shell from the current user and returns the string of the shell path.
    ///
    /// ```swift
    ///    let bufsize = sysconf(_SC_GETPW_R_SIZE_MAX)
    ///    guard bufsize != -1 else { return "/bin/bash" }
    ///    let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: bufsize)
    /// defer {
    ///        buffer.deallocate()
    ///    }
    ///    var pwd = passwd()
    ///    var result: UnsafeMutablePointer<passwd>? = UnsafeMutablePointer<passwd>.allocate(capacity: 1)
    ///
    /// if getpwuid_r(getuid(), &pwd, buffer, bufsize, &result) != 0 { return "/bin/bash" }
    ///    return String(cString: pwd.pw_shell)
    /// ```
    private static func detectSystemShell() -> String {
        let bufsize = sysconf(_SC_GETPW_R_SIZE_MAX)
        guard bufsize != -1 else { return "/bin/bash" }
        let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: bufsize)
        defer {
            buffer.deallocate()
        }
        var pwd = passwd()
        var result: UnsafeMutablePointer<passwd>? = UnsafeMutablePointer<passwd>.allocate(capacity: 1)

        if getpwuid_r(getuid(), &pwd, buffer, bufsize, &result) != 0 { return "/bin/bash" }
        return String(cString: pwd.pw_shell)
    }

    func setupSession() {
        nsview.getTerminal().silentLog = true

        let shellName = NSString(string: shell).lastPathComponent
        var environment = Terminal.getEnvironmentVariables()
        environment.append("TERM_PROGRAM=CodeEditApp_Terminal")

        // changes working directory to project root
        // TODO: Get rid of FileManager shared instance to prevent problems
        // using shared instance of FileManager might lead to problems when using
        // multiple workspaces. This works for now but most probably will need
        // to be changed later on
        FileManager.default.changeCurrentDirectoryPath(url.path)

        // launch the process
        setupShellIntegration(shell: shellName, environment: environment)
        nsview.startProcess(executable: shell, environment: environment, execName: "-\(shellName)")
    }

    /// Configure shell integration script
    private func setupShellIntegration(shell: String, environment: [String]) {
        // Get user's home dir
        var homePath: String = ""
        environment.forEach { value in
            if value.starts(with: "HOME=") {
                homePath = value
            }
        }
        homePath.removeSubrange(homePath.startIndex..<homePath.index(homePath.startIndex, offsetBy: 5))

        if let shellIntegrationScript = Bundle.main.url(
            forResource: "codeedit_shell_integration", withExtension: shell
        ) {
            // Get the path of shell integration script
            let shellIntegrationScriptPath = (
                shellIntegrationScript.absoluteString[7..<shellIntegrationScript.absoluteString.count]
            ) ?? ""

            // Get the path of user's shell's source file
            // Only zsh and bash are supported for now
            var sourceScriptPath: String = ""
            switch shell {
            case "bash":
                sourceScriptPath = homePath + "/.profile"
            case "zsh":
                sourceScriptPath = homePath + "/.zshrc"
            default:
                return
            }

            // Get the command for setting up shell integration
            let sourceCommand = "[[ \"$TERM_PROGRAM\" == \"CodeEditApp_Terminal\" ]] &&"
            + " . \"\(shellIntegrationScriptPath)\""

            // Add the shell integration setup command if needed
            if !shellIntegrationInstalled(sourceScriptPath: sourceScriptPath, command: sourceCommand) {
                if let handle = FileHandle(forWritingAtPath: sourceScriptPath) {
                    handle.seekToEndOfFile()
                    handle.write("\n\(sourceCommand)\n".data(using: .utf8)!)
                    handle.closeFile()
                }
            }
        }
    }

    /// Check if the source command for shell integration already exists
    /// Returns true if it already exists or encountered an error, no new commands will be added to user's source file
    /// Returns false if it's not there, new commands will be added to user's source file
    private func shellIntegrationInstalled(sourceScriptPath: String, command: String) -> Bool {
        do {
            // Get user's shell's source file
            let sourceScript = try String(contentsOfFile: sourceScriptPath)
            let sourceScriptSeperatedByLines = sourceScript.components(separatedBy: .newlines)
            // Check line by line
            for line in sourceScriptSeperatedByLines where line == command {
                // If one line matches the command, no new commands are needed
                return true
            }
            // If no line matches the command, new command is needed
            return false
        } catch {
            if let error = error as NSError? {
                switch error._code {
                case 260:
                    // If error 260 is thrown, it's just the source file is missing
                    // Create a new file and add new command
                    FileManager.default.createFile(atPath: sourceScriptPath, contents: nil, attributes: nil)
                    return false
                default:
                    // Otherwise just abort the shell integration setup
                    print("Cannot setup shell integration, error: \(error)")
                    return true
                }
            }
        }
    }

}

extension TerminalEmulator: Hashable {

    static func == (lhs: TerminalEmulator, rhs: TerminalEmulator) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

extension TerminalEmulator: LocalProcessTerminalViewDelegate {

    func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

    func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
        activity = title
    }

    func hostCurrentDirectoryUpdate(source: SwiftTerm.TerminalView, directory: String?) {}

    func processTerminated(source: TerminalView, exitCode: Int32?) {
        guard let exitCode else {
            return
        }
        source.feed(text: "Exit code: \(exitCode)\n\r\n")
        source.feed(text: "To open a new session close and reopen the terminal drawer")
    }

}

extension TerminalEmulator: Transferable {

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.cacheIdentifier.uuidString) {
            guard let uuid = UUID(uuidString: $0) else {
                throw ImportError.invalidCacheIdentifier($0)
            }
            guard let terminal = TerminalEmulator.resolve(uuid) else {
                throw ImportError.terminalNotFound(uuid)
            }
            return terminal
        }
        .visibility(.ownProcess)
    }

    enum ImportError: Error {
        case invalidCacheIdentifier(String)
        case terminalNotFound(UUID)
    }

}
