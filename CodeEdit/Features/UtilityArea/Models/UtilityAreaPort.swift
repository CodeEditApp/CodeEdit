//
//  UtilityAreaPort.swift
//  CodeEdit
//
//  Created by Leonardo Larrañaga on 4/21/25.
//

import Foundation

/// A forwared port for the UtilityArea
final class UtilityAreaPort: Identifiable, ObservableObject {
    let id: UUID
    let address: String

    @Published var label: String
    @Published var forwaredAddress = ""
    @Published var runningProcess = ""
    @Published var visibility = Visibility.privatePort
    @Published var origin = Origin.userForwarded
    @Published var portProtocol = PortProtocol.https

    init(address: String, label: String = "") {
        self.id = UUID()
        self.address = address
        self.label = label
    }

    enum Visibility: String, CaseIterable {
        case publicPort
        case privatePort

        var rawValue: String {
            switch self {
            case .publicPort: "Public"
            case .privatePort: "Private"
            }
        }
    }

    enum Origin: String {
        case userForwarded

        var rawValue: String {
            switch self {
            case .userForwarded: "User Forwarded"
            }
        }
    }

    enum PortProtocol: String, CaseIterable {
        case http
        case https

        var rawValue: String {
            switch self {
            case .http: "HTTP"
            case .https: "HTTPS"
            }
        }
    }

    var url: URL? {
        URL(string: address)
    }
}
