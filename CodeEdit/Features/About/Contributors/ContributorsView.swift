//
//  ContributorsView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 19.01.23.
//

import SwiftUI
import AboutWindow

struct ContributorsView: View {
    @StateObject var model = ContributorsViewModel()

    var body: some View {
        AboutDetailView(title: "Contributors") {
            LazyVStack(spacing: 0) {
                ForEach(model.contributors) { contributor in
                    ContributorRowView(contributor: contributor)
                    Divider()
                        .frame(height: 0.5)
                        .opacity(0.5)
                }
            }
        }
    }
}

class ContributorsViewModel: ObservableObject {
    @Published private(set) var contributors: [Contributor] = []

    init() {
        guard let url = Bundle.main.url(
            forResource: ".all-contributorsrc",
            withExtension: nil
        ) else { return }
        do {
            let data = try Data(contentsOf: url)
            let root = try JSONDecoder().decode(ContributorsRoot.self, from: data)
            self.contributors = root.contributors
        } catch {
            print(error)
        }
    }
}
