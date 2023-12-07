//
//  SearchModeSelector.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/21.
//

import SwiftUI
import Combine

struct FindNavigatorForm: View {
    @ObservedObject private var state: WorkspaceDocument.SearchState

    @State private var selectedMode: [SearchModeModel] {
        didSet {
            // sync the variables, as selectedMode is an array
            // and cannot be synced directly with @ObservedObject
            state.selectedMode = selectedMode
        }
    }

    @State private var searchText: String = ""
    @State private var replaceText: String = ""
    @State private var includesText: String = ""
    @State private var excludesText: String = ""
    @State private var scoped: Bool = false
    @State private var caseSensitive: Bool = false
    @State private var matchWholeWord: Bool = false
    @State private var preserveCase: Bool = false
    @State private var scopedToOpenEditors: Bool = false
    @State private var excludeSettings: Bool = true

    init(state: WorkspaceDocument.SearchState) {
        self.state = state
        selectedMode = state.selectedMode
    }

    private func getMenuList(_ index: Int) -> [SearchModeModel] {
        index == 0 ? SearchModeModel.SearchModes : selectedMode[index - 1].children
    }

    private func onSelectMenuItem(_ index: Int, searchMode: SearchModeModel) {
        var newSelectedMode: [SearchModeModel] = []

        switch index {
        case 0:
                newSelectedMode.append(searchMode)
                self.updateSelectedMode(searchMode, searchModel: &newSelectedMode)
                self.selectedMode = newSelectedMode
        case 1:
            if let firstMode = selectedMode.first {
                newSelectedMode.append(contentsOf: [firstMode, searchMode])
                if let thirdMode = searchMode.children.first {
                    if let selectedThirdMode = selectedMode.third, searchMode.children.contains(selectedThirdMode) {
                        newSelectedMode.append(selectedThirdMode)
                    } else {
                        newSelectedMode.append(thirdMode)
                    }
                }
            }
            self.selectedMode = newSelectedMode
        case 2:
            if let firstMode = selectedMode.first, let secondMode = selectedMode.second {
                newSelectedMode.append(contentsOf: [firstMode, secondMode, searchMode])
            }
            self.selectedMode = newSelectedMode
        default:
            return
        }
    }

    private func updateSelectedMode(_ searchMode: SearchModeModel, searchModel: inout [SearchModeModel]) {
        if let secondMode = searchMode.children.first {
            if let selectedSecondMode = selectedMode.second, searchMode.children.contains(selectedSecondMode) {
                searchModel.append(contentsOf: selectedMode.dropFirst())
            } else {
                searchModel.append(secondMode)
                if let thirdMode = secondMode.children.first, let selectedThirdMode = selectedMode.third {
                    if secondMode.children.contains(selectedThirdMode) {
                        searchModel.append(selectedThirdMode)
                    } else {
                        searchModel.append(thirdMode)
                    }
                }
            }
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.compact.right")
            .foregroundStyle(.tertiary)
            .imageScale(.large)
    }

    var body: some View {
        VStack {
            HStack {
                HStack(spacing: 0) {
                    ForEach(0..<selectedMode.count, id: \.self) { index in
                        FindModePicker(
                            modes: getMenuList(index),
                            selection: Binding(
                                get: {
                                    selectedMode[index]
                                },
                                set: { searchMode in
                                    onSelectMenuItem(index, searchMode: searchMode)
                                }
                            ),
                            onSelect: { searchMode in
                                onSelectMenuItem(index, searchMode: searchMode)
                            },
                            isLastItem: index == selectedMode.count-1
                        )
                    }
                    Spacer()
                }
                Spacer()
                Text("Scoped")
                    .controlSize(.small)
                    .foregroundStyle(Color(nsColor: scoped ? .controlAccentColor : .controlTextColor))
                    .onTapGesture {
                        scoped.toggle()
                    }
            }
            .padding(.top, -5)
            .padding(.bottom, -8)
            PaneTextField(
                state.selectedMode[1].title,
                text: $searchText,
                axis: .vertical,
                leadingAccessories: {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, 8)
                        .foregroundStyle(.tertiary)
                        .font(.system(size: 12))
                        .frame(width: 16, height: 20)
                },
                trailingAccessories: {
                    Divider()
                    Toggle(
                        isOn: $caseSensitive,
                        label: {
                        Image(systemName: "textformat")
                            .foregroundStyle(caseSensitive ? Color(.controlAccentColor) : Color(.secondaryLabelColor))
                        }
                    )
                    .help("Match Case")
                    Divider()
                    Toggle(
                        isOn: $matchWholeWord,
                        label: {
                            Image(systemName: "textformat.abc.dottedunderline")
                                .foregroundStyle(
                                    matchWholeWord ? Color(.controlAccentColor) : Color(.secondaryLabelColor)
                                )
                        }
                    )
                    .help("Match Whole Word")
                },
                clearable: true,
                onClear: {
                    state.clearResults()
                },
                hasValue: caseSensitive || matchWholeWord
            )
            .onSubmit {
                Task {
                    await state.search(searchText)
                }
            }
            if selectedMode[0] == SearchModeModel.Replace {
                PaneTextField(
                    "With",
                    text: $replaceText,
                    axis: .vertical,
                    leadingAccessories: {
                        Image(systemName: "arrow.2.squarepath")
                            .padding(.leading, 8)
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 12))
                            .frame(width: 16, height: 20)
                    },
                    trailingAccessories: {
                        Divider()
                        Toggle(
                            isOn: $preserveCase,
                            label: {
                                Text("AB")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundStyle(
                                        preserveCase ? Color(.controlAccentColor) : Color(.secondaryLabelColor)
                                    )
                            }
                        )
                        .help("Preserve Case")
                    },
                    clearable: true,
                    hasValue: preserveCase
                )
            }
            if scoped {
                PaneTextField(
                    "Only in folders",
                    text: $includesText,
                    axis: .vertical,
                    leadingAccessories: {
                        Image(systemName: "folder.badge.plus")
                            .padding(.leading, 8)
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 12))
                            .frame(width: 16, height: 20)
                    },
                    trailingAccessories: {
                        Divider()
                        Toggle(
                            isOn: $scopedToOpenEditors,
                            label: {
                                Image(systemName: "doc.plaintext")
                                    .foregroundStyle(
                                        scopedToOpenEditors ? Color(.controlAccentColor) : Color(.secondaryLabelColor)
                                    )
                            }
                        )
                        .help("Search only in Open Editors")
                    },
                    clearable: true,
                    hasValue: scopedToOpenEditors
                )
                PaneTextField(
                    "Excluding folders",
                    text: $excludesText,
                    axis: .vertical,
                    leadingAccessories: {
                        Image(systemName: "folder.badge.minus")
                            .padding(.leading, 8)
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 12))
                            .frame(width: 16, height: 20)
                    },
                    trailingAccessories: {
                        Divider()
                        Toggle(
                            isOn: $excludeSettings,
                            label: {
                                Image(systemName: "gearshape")
                                    .foregroundStyle(
                                        excludeSettings ? Color(.controlAccentColor) : Color(.secondaryLabelColor)
                                    )
                            }
                        )
                        .help("Use Exclude Settings and Ignore Files")
                    },
                    clearable: true,
                    hasValue: excludeSettings
                )
            }
            if selectedMode[0] == SearchModeModel.Replace {
                Button {
                    // replace all
                } label: {
                    Text("Replace All")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .lineLimit(1...5)
    }
}

struct FindModePicker: View {
    var modes: [SearchModeModel]
    private let onSelect: (SearchModeModel) -> Void
    @Binding var selection: SearchModeModel

    private let isLastItem: Bool

    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    @EnvironmentObject var workspace: WorkspaceDocument

    @State var position: NSPoint?
    @State var isHovering: Bool = false
    @State private var button: NSPopUpButton?

    init(
        modes: [SearchModeModel],
        selection: Binding<SearchModeModel>,
        onSelect: @escaping (SearchModeModel) -> Void,
        isLastItem: Bool
    ) {
        self.modes = modes
        self._selection = selection
        self.onSelect = onSelect
        self.isLastItem = isLastItem
    }

    var body: some View {
        NSPopUpButtonView(selection: $selection) {
            let button = NSPopUpButton()
            button.menu = FindModeMenu(
                modes: modes,
                onSelect: onSelect
            )
            button.font = .systemFont(ofSize: NSFont.systemFontSize(for: .small))
            button.isBordered = false
            (button.cell as? NSPopUpButtonCell)?.arrowPosition = .noArrow
            DispatchQueue.main.async {
                self.button = button
            }
            return button
        }
        .fixedSize()
        .frame(height: 21)
        .padding(.trailing, 11)
        .background {
            Color(nsColor: colorScheme == .dark ? .white : .black)
                .opacity(isHovering ? 0.05 : 0)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4)))
            HStack {
                Spacer()
                if isHovering {
                    chevronUpDown
                        .padding(.trailing, 4)
                } else if !isLastItem {
                    chevron
                        .padding(.trailing, 3)
                }
            }
        }
        .padding(.vertical, 3)
        .onHover { hover in
            isHovering = hover
        }
        .onTapGesture {
            button?.performClick(nil)
        }
        .opacity(activeState != .inactive ? 1 : 0.75)
    }

    private var chevron: some View {
        Image(systemName: "chevron.compact.right")
            .font(.system(size: 9, weight: activeState != .inactive ? .medium : .bold, design: .default))
            .foregroundStyle(.secondary)
            .scaleEffect(x: 1.30, y: 1.0, anchor: .center)
            .imageScale(.large)
    }

    private var chevronUpDown: some View {
        VStack(spacing: 1) {
            Image(systemName: "chevron.up")
            Image(systemName: "chevron.down")
        }
        .font(.system(size: 6, weight: .bold, design: .default))
        .padding(.top, 0.5)
    }

    struct NSPopUpButtonView<ItemType>: NSViewRepresentable where ItemType: Equatable {
        @Binding var selection: ItemType

        var popupCreator: () -> NSPopUpButton

        typealias NSViewType = NSPopUpButton

        func makeNSView(context: NSViewRepresentableContext<NSPopUpButtonView>) -> NSPopUpButton {
            let newPopupButton = popupCreator()
            setPopUpFromSelection(newPopupButton, selection: selection)
            if let menu = newPopupButton.menu {
                context.coordinator.registerForChanges(in: menu)
            }
            return newPopupButton
        }

        func updateNSView(_ nsView: NSPopUpButton, context: NSViewRepresentableContext<NSPopUpButtonView>) {
            setPopUpFromSelection(nsView, selection: selection)
        }

        func setPopUpFromSelection(_ button: NSPopUpButton, selection: ItemType) {
            let itemsList = button.itemArray
            let matchedMenuItem = itemsList.filter {
                ($0.representedObject as? ItemType) == selection
            }.first
            if matchedMenuItem != nil {
                button.select(matchedMenuItem)
            }
        }

        func makeCoordinator() -> Coordinator {
            return Coordinator(self)
        }

        class Coordinator: NSObject {
            var parent: NSPopUpButtonView

            var cancellable: AnyCancellable?

            init(_ parent: NSPopUpButtonView) {
                self.parent = parent
                super.init()
            }

            func registerForChanges(in menu: NSMenu) {
                cancellable = NotificationCenter.default
                    .publisher(for: NSMenu.didSendActionNotification, object: menu)
                    .sink { [weak self] notification in
                        if let menuItem = notification.userInfo?["MenuItem"] as? NSMenuItem,
                           let selection = menuItem as? ItemType {
                            self?.parent.selection = selection
                        }
                    }
            }
        }
    }
}

extension Array {
    var second: Element? {
        self.count > 1 ? self[1] : nil
    }

    var third: Element? {
        self.count > 2 ? self[2] : nil
    }
}

final class FindModeMenu: NSMenu, NSMenuDelegate {
    private let modes: [SearchModeModel]
    private let onSelect: (SearchModeModel) -> Void

    init(
        modes: [SearchModeModel],
        onSelect: @escaping (SearchModeModel) -> Void
    ) {
        self.modes = modes
        self.onSelect = onSelect
        super.init(title: "")
        delegate = self
        modes.forEach { mode in
            let menuItem = FindModeMenuItem(mode: mode, onSelect: onSelect)
            menuItem.onStateImage = nil
            self.addItem(menuItem)
        }
        autoenablesItems = false
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class FindModeMenuItem: NSMenuItem {
    private let mode: SearchModeModel
    private let onSelect: (SearchModeModel) -> Void

    init(
        mode: SearchModeModel,
        onSelect: @escaping (SearchModeModel) -> Void
    ) {
        self.mode = mode
        self.onSelect = onSelect
        super.init(title: mode.title, action: #selector(handleSelect), keyEquivalent: "")

        representedObject = mode
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    func handleSelect() {
        onSelect(mode)
    }
}
