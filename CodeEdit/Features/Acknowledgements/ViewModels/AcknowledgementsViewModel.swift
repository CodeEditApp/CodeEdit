//
//  AcknowledgementsModel.swift
//  CodeEditModules/Acknowledgements
//
//  Created by Lukas Pistrol on 01.05.22.
//

import SwiftUI

final class AcknowledgementsViewModel: ObservableObject {

    @Published
    private (set) var acknowledgements: [Dependency]

    init(_ dependencies: [Dependency] = []) {
        self.acknowledgements = dependencies

        if acknowledgements.isEmpty {
            fetchDependencies()
        }
    }

    func fetchDependencies() {
        self.acknowledgements.removeAll()
        do {
            if let bundlePath = Bundle.main.path(forResource: "Package.resolved", ofType: nil) {
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8)
                let parsedJSON = try JSONDecoder().decode(RootObject.self, from: jsonData!)
                for dependency in parsedJSON.object.pins.sorted(by: { $0.package < $1.package })
                where dependency.package.range(
                    of: "[Cc]ode[Ee]dit",
                    options: .regularExpression,
                    range: nil,
                    locale: nil
                ) == nil {
                    self.acknowledgements.append(
                        Dependency(
                            name: dependency.package,
                            repositoryLink: dependency.repositoryURL,
                            version: dependency.state.version ?? ""
                        )
                    )
                }
            }
        } catch {
            print(error)
        }
    }
}
