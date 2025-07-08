//
//  DataChannel+localProcess.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/8/25.
//

import Foundation
import LanguageServerProtocol
import JSONRPC
import ProcessEnv

// This is almost exactly the same as the extension provided by `LanguageServerProtocol`, except it returns the
// process ID as well as the channel, which we need.

extension DataChannel {
	@available(macOS 12.0, *)
	public static func localProcessChannel(
		parameters: Process.ExecutionParameters,
		terminationHandler: @escaping @Sendable () -> Void
    ) throws -> (pid: pid_t, channel: DataChannel) {
		let process = Process()

		let stdinPipe = Pipe()
		let stdoutPipe = Pipe()
		let stderrPipe = Pipe()

		process.standardInput = stdinPipe
		process.standardOutput = stdoutPipe
		process.standardError = stderrPipe

		process.parameters = parameters

		let (stream, continuation) = DataSequence.makeStream()

		process.terminationHandler = { _ in
			continuation.finish()
			terminationHandler()
		}

		Task {
			let dataStream = stdoutPipe.fileHandleForReading.dataStream

			for try await data in dataStream {
				continuation.yield(data)
			}

			continuation.finish()
		}

		Task {
			for try await line in stderrPipe.fileHandleForReading.bytes.lines {
				print("stderr: ", line)
			}
		}

		try process.run()

		let handler: DataChannel.WriteHandler = {
			// this is wacky, but we need the channel to hold a strong reference to the process
			// to prevent it from being deallocated
			_ = process

			try stdinPipe.fileHandleForWriting.write(contentsOf: $0)
		}

        return (process.processIdentifier, DataChannel(writeHandler: handler, dataSequence: stream))
	}
}
