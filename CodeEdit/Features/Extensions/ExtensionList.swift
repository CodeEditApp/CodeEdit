//
//  ExtensionList.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 30/12/2022.
//

import SwiftUI
import ExtensionFoundation

struct ExtensionList: View {
    @EnvironmentObject var manager: ExtensionDiscovery
    @State var filter: String = ""
    @Binding var scope: SearchScope

    @FocusState private var focusedField: FocusedField?
    

    enum FocusedField {
        case installedList,
             store,
             sea
    }

    var body: some View {

        VStack(spacing: 0) {

            Button("Test") {
                focusedField = .sea
                print("Pressed")
            }
            .focusable(false)
            .keyboardShortcut("f")
            .hidden()
            .frame(width: 0, height: 0)

            VStack {
                TextField("Search Field", text: $filter, prompt: (Text(Image(systemName: "magnifyingglass")) + Text("Search...")))
                    .focused($focusedField, equals: .sea)
                    .focusable(false)
                    .textFieldStyle(.roundedBorder)
                    .controlSize(.large)

                Picker("Search Scope", selection: $scope) {
                    ForEach(SearchScope.allCases) {
                        Text($0.description)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
            .padding([.horizontal, .bottom], 10)

            switch scope {
            case .installed:
                InstalledExtensionsList()
                    .transition(.move(edge: .leading))
                    .focused($focusedField, equals: .installedList)

            case .store:
                ExtensionStoreCategories()
                    .transition(.move(edge: .trailing))
                    .focused($focusedField, equals: .store)
            }
        }
        .animation(.spring(response: 0.3), value: scope)
        .onChange(of: scope) { newValue in
            switch newValue {
            case .store:
                focusedField = .store
            case .installed:
                focusedField = .installedList
            }
        }
    }
}



