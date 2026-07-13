//
//  CommandPaletteView.swift
//  CodeEdit
//
//  Created by Alex Sinelnikov on 24.05.2022.
//

import SwiftUI
import CodeEditUI
import CodeEditCore

/// Quick actions view
struct QuickActionsView: View {

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    @ObservedObject private var state: QuickActionsViewModel

    @State private var monitor: Any?

    @State private var selectedItem: Command?

    private let closePalette: () -> Void

    init(state: QuickActionsViewModel, closePalette: @escaping () -> Void) {
        self.state = state
        self.closePalette = closePalette
        state.reset()
    }

    func callHandler(command: Command) {
        closePalette()
        command.closureWrapper()
        selectedItem = nil
        state.commandQuery = ""
        state.filteredCommands = []
    }

    func onQueryChange(text: String) {
        state.commandQuery = text
        state.fetchMatchingCommands(val: text)
    }

    var body: some View {
        SearchPanelView<QuickSearchResultLabel, EmptyView, Command>(
            title: "Commands",
            image: Image(systemName: "magnifyingglass"),
            options: $state.filteredCommands,
            text: $state.commandQuery,
            alwaysShowOptions: true,
            optionRowHeight: 30
        ) { command in
            QuickSearchResultLabel(
                labelName: command.title,
                charactersToHighlight: [],
                nsLabelName: state.highlight(command.title)
            )
        } onRowClick: { command in
            callHandler(command: command)
        } onClose: {
            closePalette()
        }
        .onReceive(state.$commandQuery.debounce(for: 0.2, scheduler: DispatchQueue.main)) { _ in
            state.fetchMatchingCommands(val: state.commandQuery)
        }
    }
}
