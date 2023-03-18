//
//  OverlayWindow.swift
//  CodeEdit
//
//  Created by Khan Winter on 3/17/23.
//

import Foundation
import SwiftUI

struct OverlayView<RowView: View, PreviewView: View, Data: Identifiable & Hashable>: View {
    @ViewBuilder
    let rowViewBuilder: ((Data) -> RowView)

    @ViewBuilder
    let previewViewBuilder: ((Data) -> PreviewView)?

    @Binding
    var data: [Data]

    @State
    var selectedItem: Data?

    @Binding
    var queryContent: String

    let title: String
    let image: Image
    let showsPreview: Bool
    let onRowClick: ((Data) -> Void)
    let onClose: (() -> Void)

    init(
        title: String,
        image: Image,
        data: Binding<[Data]>,
        queryContent: Binding<String>,
        content: @escaping ((Data) -> RowView),
        preview: ((Data) -> PreviewView)? = nil,
        onRowClick: @escaping ((Data) -> Void),
        onClose: @escaping () -> Void
    ) {
        self.title = title
        self.image = image
        self._data = data
        self._queryContent = queryContent
        self.rowViewBuilder = content
        self.previewViewBuilder = preview
        self.onRowClick = onRowClick
        self.onClose = onClose
        self.showsPreview = preview != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack(alignment: .center, spacing: 0) {
                    image
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                        .padding(.leading, 1)
                        .padding(.trailing, 10)
                    TextField(title, text: $queryContent)
                        .font(.system(size: 20, weight: .light, design: .default))
                        .textFieldStyle(.plain)
                        .onReceive(queryContent.publisher) { _ in
                            if queryContent.isEmpty {
                                selectedItem = nil
                            } else {
                                // Select the first item by default to indicate the "enter" action
                                if selectedItem == nil {
                                    selectedItem = data.first
                                }
                            }
                        }
                        .onSubmit {
                            if queryContent.isEmpty {
                                // Nothing to select!
                                NSSound.beep()
                            } else {
                                // Handle enter pressed in the text view
                                if let dataItem = selectedItem ?? data.first {
                                    onRowClick(dataItem)
                                }
                            }
                        }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .foregroundColor(.primary.opacity(0.85))
                .background(EffectView(.sidebar, blendingMode: .behindWindow))
            }
            if !queryContent.isEmpty {
                ScrollViewReader { scrollReader in
                    ZStack {
                        // Hide these buttons (they're just keyboard shortcuts)
                        Button {
                            if let selectedItem, let index = data.firstIndex(of: selectedItem) {
                                if index > 0 {
                                    self.selectedItem = data[index - 1]
                                    withAnimation(.default) {
                                        scrollReader.scrollTo(data[index - 1])
                                    }
                                } else {
                                    NSSound.beep()
                                }
                            }
                        } label: { EmptyView() }
                            .opacity(0)
                            .keyboardShortcut(.upArrow, modifiers: [])
                            .accessibilityLabel("Select Up")

                        Button {
                            if let selectedItem, let index = data.firstIndex(of: selectedItem) {
                                if data.count > index + 1 {
                                    self.selectedItem = data[index + 1]
                                    withAnimation(.default) {
                                        scrollReader.scrollTo(data[index + 1])
                                    }
                                } else {
                                    NSSound.beep()
                                }
                            }
                        } label: { EmptyView() }
                            .opacity(0)
                            .keyboardShortcut(.downArrow, modifiers: [])
                            .accessibilityLabel("Select Down")

                        Button {
                            onClose()
                        } label: { EmptyView() }
                            .opacity(0)
                            .keyboardShortcut(.escape, modifiers: [])
                            .accessibilityLabel("Close Overlay")
                    }
                    Group {
                        // The real content.
                        Divider()
                            .padding(0)
                        HStack(spacing: 0) {
                            ScrollView {
                                LazyVStack(
                                    alignment: .leading,
                                    spacing: 0
                                ) {
                                    ForEach(data) { dataItem in
                                        rowViewBuilder(dataItem)
                                            .onTapGesture {
                                                onRowClick(dataItem)
                                            }
                                            .padding([.trailing, .vertical], 8)
                                            .padding(.leading, 10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .buttonStyle(.borderless)
                                            .background(
                                                Color(
                                                    self.selectedItem == dataItem
                                                    ? .selectedContentBackgroundColor : .clear
                                                )
                                            )
                                            .cornerRadius(5)
                                            .onHover { isHovering in
                                                if isHovering {
                                                    selectedItem = dataItem
                                                }
                                            }
                                            .id(dataItem)
                                    }
                                }
                                .frame(maxWidth: showsPreview ? 272 : .infinity)
                                .padding(.horizontal, 8)
                            }
                            if showsPreview {
                                Divider()
                                if data.isEmpty {
                                    EmptyView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    if let selectedItem, let previewViewBuilder {
                                        previewViewBuilder(selectedItem)
                                            .frame(maxWidth: .infinity)
                                    } else {
                                        Text("Select a file to preview")
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .background(EffectView(.sidebar, blendingMode: .behindWindow))
        .edgesIgnoringSafeArea(.vertical)
        .frame(
            minWidth: 680,
            minHeight: queryContent.isEmpty ? 19 : 400,
            maxHeight: queryContent.isEmpty ? 19 : .infinity
        )
    }
}
