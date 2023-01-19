//
//  ContributorsView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 19.01.23.
//

import SwiftUI

struct ContributorsView: View {

    @StateObject private var viewModel = ContributorsViewModel()
    @State private var displayDivider = false

    var body: some View {
        VStack(spacing: 0) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 48, height: 48)
            Text("Contributors")
                .font(.title)
                .padding(.vertical, 8)
            Divider()
                .opacity(displayDivider ? 1 : 0)
            OffsettableScrollView(showsIndicator: false) { offset in
                displayDivider = offset.y < 0
            } content: {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.contributors) { contributor in
                        ContributorRowView(contributor: contributor)
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
        }
        .frame(width: 350, height: 500)
        .background(.regularMaterial)
        .task {
            viewModel.loadContributors()
        }
    }

    func showWindow(width: CGFloat, height: CGFloat) {
        ContributorsWindowController(view: self, size: NSSize(width: width, height: height)).showWindow(nil)
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
