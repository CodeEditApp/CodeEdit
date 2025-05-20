//
//  EditorJumpBarView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct EditorJumpBarView: View {
    private let file: CEWorkspaceFile?
    private let shouldShowTabBar: Bool
    private let tappedOpenFile: (CEWorkspaceFile) -> Void

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.isActiveEditor)
    private var isActiveEditor

    @Environment(\.controlActiveState)
    private var activeState

    @Binding var codeFile: CodeFileDocument?

    static let height = 28.0

    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var isTruncated: Bool = false
    @State private var crumbWidth: CGFloat?

    init(
        file: CEWorkspaceFile?,
        shouldShowTabBar: Bool,
        codeFile: Binding<CodeFileDocument?>,
        tappedOpenFile: @escaping (CEWorkspaceFile) -> Void
    ) {
        self.file = file ?? nil
        self.shouldShowTabBar = shouldShowTabBar
        self._codeFile = codeFile
        self.tappedOpenFile = tappedOpenFile
    }

    var fileItems: [CEWorkspaceFile] {
        var treePath: [CEWorkspaceFile] = []
        var currentFile: CEWorkspaceFile? = file

        while let currentFileLoop = currentFile {
            treePath.insert(currentFileLoop, at: 0)
            currentFile = currentFileLoop.parent
        }

        return treePath
    }

    var body: some View {
        GeometryReader { containerProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    if file == nil {
                        Text("No Selection")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(
                                activeState != .inactive
                                ? isActiveEditor ? .primary : .secondary
                                : Color(nsColor: .tertiaryLabelColor)
                            )
                    } else {
                        ForEach(fileItems, id: \.self) { fileItem in
                            EditorJumpBarComponent(
                                fileItem: fileItem,
                                tappedOpenFile: tappedOpenFile,
                                isLastItem: fileItems.last == fileItem,
                                isTruncated: $crumbWidth
                            )
                        }

                    }
                }
                .mask(
                    LinearGradient(
                        gradient: Gradient(
                            stops: crumbWidth != nil ?
                            [
                                .init(color: .black, location: 0),
                                .init(color: .black, location: 0.8),
                                .init(color: .clear, location: 1)
                            ] : [
                                .init(color: .black, location: 0),
                                .init(color: .black, location: 1)
                            ]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                if crumbWidth == nil {
                                    textWidth = proxy.size.width
                                }
                            }
                            .onChange(of: proxy.size.width) { newValue in
                                if crumbWidth == nil {
                                    textWidth = newValue
                                }
                            }
                    }
                )
            }
            .onAppear {
                containerWidth = containerProxy.size.width
            }
            .onChange(of: containerProxy.size.width) { newValue in
                containerWidth = newValue
            }
            .onChange(of: textWidth) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    resize()
                }
            }
            .onChange(of: containerWidth) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    resize()
                }
            }
        }
        .padding(.horizontal, shouldShowTabBar ? (file == nil ? 10 : 4) : 0)
        .safeAreaInset(edge: .leading, spacing: 0) {
            if !shouldShowTabBar {
                EditorTabBarLeadingAccessories()
            }
        }
        .safeAreaInset(edge: .trailing, spacing: 0) {
            if !shouldShowTabBar {
                EditorTabBarTrailingAccessories(codeFile: $codeFile)
            }
        }
        .frame(height: Self.height, alignment: .center)
        .opacity(activeState == .inactive ? 0.8 : 1.0)
        .grayscale(isActiveEditor ? 0.0 : 1.0)
    }

    private func resize() {
        let minWidth: CGFloat = 20
        let snapThreshold: CGFloat = 30
        let maxWidth: CGFloat = textWidth / CGFloat(fileItems.count)
        let exponent: CGFloat = 5.0

        if textWidth >= containerWidth {
            let scale = max(0, min(1, containerWidth / textWidth))
            var width = floor((minWidth + (maxWidth - minWidth) * pow(scale, exponent)))
            if width < snapThreshold {
                width = minWidth
            }
            crumbWidth = width
        } else {
            crumbWidth = nil
        }
    }
}
