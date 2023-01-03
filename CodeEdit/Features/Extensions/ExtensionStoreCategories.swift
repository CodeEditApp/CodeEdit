//
//  ExtensionStoreCategories.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/01/2023.
//

import SwiftUI

struct ExtensionStoreCategories: View {
    @EnvironmentObject var navigationManager: ExtensionWindowNavigationManager

    var body: some View {
        List(selection: $navigationManager.storeCategorySelection) {
            ForEach(StoreCategories.allCases) { category in
                NavigationLink {
                    ScrollView {

                        LazyVGrid(columns: [.init(spacing: 20), .init(spacing: 20), .init(spacing: 20)], spacing: 30) {
                            ForEach(0..<100, id: \.self) { _ in
                                NavigationLink {
                                    VStack(alignment: .leading) {
                                        Text("DummyExtension")
                                            .font(.largeTitle)
                                            .fontWeight(.heavy)
                                        Text("...")
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                } label: {
                                    HStack {
                                        Image(systemName: "suit.spade.fill")
                                        VStack(alignment: .leading) {
                                            Text("DummyExtension")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                            Text("This is a description")
                                        }
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 5)
                                            .strokeBorder(lineWidth: 1)
                                            .foregroundColor(.gray)
                                            .opacity(0.5)
                                    }

                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                } label: {
                    Label(category.description, systemImage: category.icon)
                }
            }
        }
    }
}
