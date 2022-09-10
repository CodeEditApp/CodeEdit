//
//  Mocks.swift
//  CodeEditModules/ShellClient
//
//  Created by Marco Carnevali on 27/03/22.
//
import Combine

// swiftlint:disable missing_docs
public extension ShellClient {
    static func always(_ output: String) -> Self {
        Self(
            runLive: { _ in
                CurrentValueSubject<String, Never>(output)
                    .eraseToAnyPublisher()
            },
            run: { _ in
                output
            }
        )
    }
}
