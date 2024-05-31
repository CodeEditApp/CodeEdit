//
//  OverlayWindow.swift
//  CodeEdit
//
//  Created by Khan Winter on 3/17/23.
//

import Foundation
import SwiftUI

struct SearchPanelView<RowView: View, PreviewView: View, Option: Identifiable & Hashable>: View {
    @ViewBuilder let rowViewBuilder: ((Option) -> RowView)
    @ViewBuilder let previewViewBuilder: ((Option) -> PreviewView)?

    @Binding var options: [Option]
    @Binding var text: String

    @State var selection: Option?
    @State var previewVisible: Bool = true

    let title: String
    let image: Image
    let hasPreview: Bool
    let onRowClick: ((Option) -> Void)
    let onClose: (() -> Void)
    let alwaysShowOptions: Bool
    let optionRowHeight: CGFloat

    init(
        title: String,
        image: Image,
        options: Binding<[Option]>,
        text: Binding<String>,
        alwaysShowOptions: Bool = false,
        optionRowHeight: CGFloat = 30,
        content: @escaping ((Option) -> RowView),
        preview: ((Option) -> PreviewView)? = nil,
        onRowClick: @escaping ((Option) -> Void),
        onClose: @escaping () -> Void
    ) {
        self.title = title
        self.image = image
        self._options = options
        self._text = text
        self.rowViewBuilder = content
        self.previewViewBuilder = preview
        self.onRowClick = onRowClick
        self.onClose = onClose
        self.hasPreview = preview != nil
        self.alwaysShowOptions = alwaysShowOptions
        self.optionRowHeight = optionRowHeight
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
                    TextField(title, text: $text)
                        .font(.system(size: 20, weight: .light, design: .default))
                        .textFieldStyle(.plain)
                        .onSubmit {
                            if let selection {
                                onRowClick(selection)
                            } else {
                                NSSound.beep()
                            }
                        }
                        .task(id: options) {
                            if options.isEmpty {
                                selection = nil
                            } else {
                                if !options.isEmpty {
                                    selection = options.first
                                }
                            }
                        }
                    if hasPreview {
                        PreviewToggle(previewVisible: $previewVisible)
                            .onTapGesture {
                                withAnimation {
                                    previewVisible.toggle()
                                }
                            }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .foregroundColor(.primary.opacity(0.85))
                .background(EffectView(.sidebar, blendingMode: .behindWindow))
            }
            if !text.isEmpty || alwaysShowOptions == true {
                Divider()
                    .padding(0)
                HStack(spacing: 0) {
                    if options.isEmpty {
                        Text("No matching options")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: hasPreview ? 272 : .infinity, maxHeight: .infinity)
                    } else {
                        NSTableViewWrapper(
                            data: options,
                            rowHeight: optionRowHeight,
                            selection: $selection,
                            itemView: rowViewBuilder
                        )
                        .frame(maxWidth: hasPreview && previewVisible ? 272 : .infinity)
                    }
                    if hasPreview && previewVisible {
                        Divider()
                        if options.isEmpty {
                            Spacer()
                                .frame(maxWidth: .infinity)
                        } else {
                            if let selection, let previewViewBuilder {
                                previewViewBuilder(selection)
                                    .clipped()
                                    .frame(maxWidth: .infinity)
                                    .transition(.move(edge: .trailing))
                            } else {
                                Text("Select an option to preview")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
        }
        .overlay {
            keyHandlers
        }
        .background(EffectView(.sidebar, blendingMode: .behindWindow))
        .edgesIgnoringSafeArea(.vertical)
        .frame(
            minWidth: 680,
            minHeight: text.isEmpty && !alwaysShowOptions ? 19 : 400,
            maxHeight: text.isEmpty && !alwaysShowOptions ? 19 : .infinity
        )
    }

    @ViewBuilder var keyHandlers: some View {
        Button {
            onClose()
        } label: { EmptyView() }
            .opacity(0)
            .keyboardShortcut(.escape, modifiers: [])
            .accessibilityLabel("Close Overlay")
        Button {
            guard selection != options.first else {
                return
            }
            if let selection, let index = options.firstIndex(of: selection) {
                self.selection = options[index-1]
            } else {
                selection = options.first
            }
        } label: { EmptyView() }
            .opacity(0)
            .keyboardShortcut(.upArrow, modifiers: [])
            .accessibilityLabel("Select Up")
        Button {
            guard selection != options.last else {
                return
            }
            if let selection, let index = options.firstIndex(of: selection) {

                self.selection = options[index+1]
            } else {
                selection = options.first
            }
        } label: { EmptyView() }
            .opacity(0)
            .keyboardShortcut(.downArrow, modifiers: [])
            .accessibilityLabel("Select Down")
    }
}

struct PreviewToggle: View {
    @Binding var previewVisible: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(NSColor.secondaryLabelColor))
                .frame(width: previewVisible ? 12 : 14, height: 1)
                .offset(CGSize(width: 0, height: -2.5))
            if !previewVisible {
                Rectangle()
                    .fill(Color(NSColor.secondaryLabelColor))
                    .frame(width: 1, height: 8)
                    .offset(CGSize(width: -2.5, height: 2))
            }
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .strokeBorder(Color(NSColor.secondaryLabelColor), lineWidth: 1)
                .frame(width: previewVisible ? 14 : 16, height: 14)
        }
        .frame(width: 16, height: 16)
        .padding(4)
        .contentShape(Rectangle())
    }
}
