//
//  ContributorsView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 19.01.23.
//

import SwiftUI

struct ContributorsView: View {
    @StateObject private var viewModel = ContributorsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.contributors) { contributor in
                ContributorRowView(contributor: contributor)
                Divider()
                    .frame(height: 0.5)
                    .opacity(0.5)
            }
        }
        .task {
            viewModel.loadContributors()
        }
    }
}

struct ContributorsView_Previews: PreviewProvider {
    static var previews: some View {
        ContributorsView()
    }
}

class ContributorsViewModel: ObservableObject {
    @Published private(set) var contributors: [Contributor] = []

    func loadContributors() {
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
