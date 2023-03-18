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
                    PaletteTextField(text: $queryContent, overruleKeyCode: handleKeyCodes)
                        .frame(height: 20)
                        .onChange(of: data) { newValue in
                            if newValue.isEmpty {
                                selectedItem = nil
                            } else {
                                if selectedItem == nil {
                                    selectedItem = newValue.first
                                }
                            }
                        }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 12)
                .foregroundColor(.primary.opacity(0.85))
                .background(EffectView(.sidebar, blendingMode: .behindWindow))
            }
            if !queryContent.isEmpty {

                        Divider()
                            .padding(0)
                HStack(spacing: 0) {
                    NSTableViewWrapper(data: data, rowHeight: 50, selection: $selectedItem, itemView: rowViewBuilder)
                        .frame(maxWidth: showsPreview ? 272 : .infinity)
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
        .overlay {
            Button {
                onClose()
            } label: { EmptyView() }
                .opacity(0)
                .keyboardShortcut(.escape, modifiers: [])
                .accessibilityLabel("Close Overlay")
        }
        .background(EffectView(.sidebar, blendingMode: .behindWindow))
        .edgesIgnoringSafeArea(.vertical)
        .frame(
            minWidth: 680,
            minHeight: queryContent.isEmpty ? 19 : 400,
            maxHeight: queryContent.isEmpty ? 19 : .infinity
        )
    }

    func handleKeyCodes(keycode: Int) {
        switch keycode {
        case 125: // Key Down
            guard selectedItem != data.last else {
                return
            }
            if let selectedItem, let index = data.firstIndex(of: selectedItem) {

                self.selectedItem = data[index+1]
            } else {
                selectedItem = data.first
            }

        case 126: // Key Up
            guard selectedItem != data.first else {
                return
            }
            if let selectedItem, let index = data.firstIndex(of: selectedItem) {
                self.selectedItem = data[index-1]
            } else {
                selectedItem = data.first
            }
        case 36: // Enter
            if let selectedItem {
                onRowClick(selectedItem)
            } else {
                NSSound.beep()
            }
        default:
            break
        }
    }
}
