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
    @State var showExtensionActivator = false
    @FocusState private var focusedField: FocusedField?

    enum FocusedField {
        case installedList,
             store,
             searchfield
    }

    var body: some View {

        VStack(spacing: 0) {

            // Keyboard shortcut for seacrhbar
            Button("Focus Searchbar") {
                switch scope {
                case .installed:
                    scope = .store
                    // Small delay, otherwise focus doesn't work right.
                    Task {
                        try? await Task.sleep(for: .seconds(0.2))
                        focusedField = .searchfield
                    }
                case .store:
                    focusedField = .searchfield
                }

            }
            .focusable(false)
            .keyboardShortcut("f")
            .hidden()
            .frame(width: 0, height: 0)

            VStack {
                // TODO: Find a way to have a magnifying glass icon in the prompt
                // Text(Image(systemName: "magnifyingglass")) should work, but doesn't work in a textfield for some reason.
                // .searchable can't be used as the picker needs to be displayed below it
                // the picker can be shown when .searchScopes works in the sidebar
                HStack {
                    TextField("Search Field", text: $filter, prompt: Text("Search..."))
                        .focused($focusedField, equals: .searchfield)
                        .focusable(false)
                        .textFieldStyle(.roundedBorder)
                        .controlSize(.large)
                    
                    Button {
                        showExtensionActivator.toggle()
                    } label: {
                        Image(systemName: "puzzlepiece.extension")
                    }
                    .controlSize(.large)
                    .popover(isPresented: $showExtensionActivator) {
                        ExtensionActivatorView()
                            .frame(width: 400, height: 300)
                    }
                }

                SegmentedControlImproved(selection: $scope, options: SearchScope.allCases, prominent: true)
                    .controlSize(.regular)

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
