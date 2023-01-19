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
        VStack {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 70, height: 70)
            Text("Contributors")
                .font(.largeTitle)
                .fontWeight(.bold)
            ScrollView(showsIndicators: false) {
                ForEach(viewModel.contributors) { contributor in
                    ContributorRowView(contributor: contributor)
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
