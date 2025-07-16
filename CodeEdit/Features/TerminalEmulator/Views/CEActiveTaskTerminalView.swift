//
//  CEActiveTaskTerminalView.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/14/25.
//

import AppKit
import SwiftTerm

class CEActiveTaskTerminalView: CELocalShellTerminalView {
    var activeTask: CEActiveTask

    private var cachedCaretColor: NSColor?
    var isUserCommandRunning: Bool {
        activeTask.status == .running || activeTask.status == .stopped
    }
    private var enableOutput: Bool = false

    init(activeTask: CEActiveTask) {
        self.activeTask = activeTask
        super.init(frame: .zero)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()
        terminal.parser.oscHandlers[133] = { [weak self] slice in
            guard let string = String(bytes: slice, encoding: .utf8), let self else { return }
            // There's some more commands we could handle but don't right now. See the section on the FinalTerm codes
            // here: https://iterm2.com/documentation-escape-codes.html
            // There's also a few codes we don't emit. This should be improved in the future.

            switch string.first {
            case "C":
                if self.cachedCaretColor == nil {
                    self.cachedCaretColor = self.caretColor
                }
                self.caretColor = self.cachedCaretColor ?? self.caretColor
                self.activeTask.updateTaskStatus(to: .running)

                self.sendOutputMessage("Starting task: " + self.activeTask.task.name)
                self.sendOutputMessage(self.activeTask.task.command)
                self.newline()

                // Command started
                self.enableOutput = true
            case "D":
                // Disabled before we've received the first C CMD from the task
                guard enableOutput else { return }
                // Command terminated with code
                let chunks = string.split(separator: ";")
                guard chunks.count == 2, let status = Int32(chunks[1]) else { return }
                self.activeTask.handleProcessFinished(terminationStatus: status)

                self.enableOutput = false
                self.caretColor = .clear
            default:
                break
            }
        }
    }

    override func startProcess(
        workspaceURL url: URL?,
        shell: Shell? = nil,
        environment: [String] = [],
        interactive: Bool = true
    ) {
        // Start the shell
        do {
            let terminalSettings = Settings.shared.preferences.terminal

            var terminalEnvironment: [String] = Terminal.getEnvironmentVariables()
            terminalEnvironment.append("TERM_PROGRAM=CodeEditApp_Terminal")

            guard let (shell, shellPath) = getShell(shell, userSetting: terminalSettings.shell) else {
                return
            }

            let shellArgs = try ShellIntegration.setUpIntegration(
                for: shell,
                environment: &terminalEnvironment,
                useLogin: terminalSettings.useLoginShell,
                interactive: interactive
            )

            terminalEnvironment.append(contentsOf: environment)
            terminalEnvironment.append("\(ShellIntegration.Variables.disableHistory)=1")
            terminalEnvironment.append(
                contentsOf: activeTask.task.environmentVariables.map({ $0.key + "=" + $0.value })
            )

            process.startProcess(
                executable: shellPath,
                args: shellArgs,
                environment: terminalEnvironment,
                execName: shell.rawValue,
                currentDirectory: URL(filePath: activeTask.task.workingDirectory, relativeTo: url).absolutePath
            )

            // Feed the command and run it
            process.send(text: activeTask.task.command)
            process.send(data: EscapeSequences.cmdRet[0..<1])
        } catch {
            newline()
            sendOutputMessage("Failed to start a terminal session: \(error.localizedDescription)")
            newline()
        }
    }

    func sendOutputMessage(_ message: String) {
        sendSpecialSequence()
        feed(text: message)
        newline()
    }

    func sendSpecialSequence() {
        let start: [UInt8] = [0x1B, 0x5B, 0x37, 0x6D]
        let end: [UInt8] = [0x1B, 0x5B, 0x30, 0x6D]
        feed(byteArray: start[0..<start.count])
        feed(text: " * ")
        feed(byteArray: end[0..<end.count])
        feed(text: " ")
    }

    func newline() {
        // cr cr lf
        feed(byteArray: [13, 13, 10])
    }

    func runningPID() -> pid_t? {
        if process.shellPid != 0 {
            return process.shellPid
        }
        return nil
    }

    func getProcessGroup() -> pid_t? {
        guard let shellPID = runningPID() else { return nil }
        let group = getpgid(shellPID)
        guard group >= 0 else { return nil }
        return group
    }

    func getBufferAsString() -> String {
        terminal.getText(
            start: .init(col: 0, row: 0),
            end: .init(col: terminal.cols, row: terminal.rows + terminal.buffer.yDisp)
        )
    }

    override func dataReceived(slice: ArraySlice<UInt8>) {
        if enableOutput {
            super.dataReceived(slice: slice)
        } else if slice.count >= 5 {
            // ESC [ 1 3 3
            let sequence: [UInt8] = [0x1B, 0x5D, 0x31, 0x33, 0x33]
            // Ignore until we see an OSC 133 code
            for idx in 0..<(slice.count - 5) where slice[idx..<idx + 5] == sequence[0..<5] {
                super.dataReceived(slice: slice[idx..<slice.count])
                return
            }
        }
    }
}
