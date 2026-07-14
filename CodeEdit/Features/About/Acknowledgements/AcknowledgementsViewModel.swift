//
//  AcknowledgementsModel.swift
//  CodeEditModules/Acknowledgements
//
//  Created by Lukas Pistrol on 01.05.22.
//

import SwiftUI

final class AcknowledgementsViewModel: ObservableObject {

    @Published private(set) var acknowledgements: [AcknowledgementDependency]

    var indexedAcknowledgements: [(index: Int, acknowledgement: AcknowledgementDependency)] {
      return Array(zip(acknowledgements.indices, acknowledgements))
    }

    init(_ dependencies: [AcknowledgementDependency] = []) {
        self.acknowledgements = dependencies

        if acknowledgements.isEmpty {
            fetchDependencies()
        }
    }

    func fetchDependencies() {
        self.acknowledgements.removeAll()
        do {
            if let bundlePath = Bundle.main.path(forResource: "Package", ofType: "resolved") {
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8)
                let parsedJSON = try JSONDecoder().decode(AcknowledgementObject.self, from: jsonData!)
                for dependency in parsedJSON.pins.sorted(by: { $0.identity < $1.identity })
                where dependency.identity.range(
                    of: "[Cc]ode[Ee]dit",
                    options: .regularExpression,
                    range: nil,
                    locale: nil
                ) == nil {
                    self.acknowledgements.append(
                        AcknowledgementDependency(
                            name: dependency.name,
                            repositoryLink: dependency.location,
                            version: dependency.state.version ?? "-"
                        )
                    )
                }
            }
        } catch {
            print(error)
        }
    }
}
