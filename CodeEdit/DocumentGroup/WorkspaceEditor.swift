//
//  WorkspaceEditor.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 04/01/2023.
//

import SwiftUI
import CodeEditTextView

//swiftlint:disable all

indirect enum WorkspaceLayout: View {

    case one(Int)

    case horizontal(Int, WorkspaceLayout)

    case vertical(Int, WorkspaceLayout)

    var body: some View {
        switch self {
        case .one(let file):

                ReferenceWorkspaceEditor(identifier: file)


            .overlay(alignment: .top) {

                    VStack(spacing: 0) {

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<10, id: \.self) {
                                    Text("Hello \($0)")
                                }
                            }
                        }
                        .frame(height: 30)
                        .padding(.leading)


                        .scrollContentBackground(.hidden)
                        Divider()

                    }
                    //                        .background(.ultraThinMaterial)
                    .background(EffectView(.titlebar, blendingMode: .withinWindow, emphasized: false))

                }
        case .horizontal(let file, let workspaceLayout):
            HSplitView {
                ReferenceWorkspaceEditor(identifier: file)
                    .ignoresSafeArea(.all, edges: .top)
                    .overlay(alignment: .top) {

                        VStack(spacing: 0) {

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(0..<10, id: \.self) {
                                        Text("Hello \($0)")
                                    }
                                }
                            }
                            .frame(height: 30)
                            .padding(.leading)


                            .scrollContentBackground(.hidden)
                            Divider()

                        }
//                        .background(.ultraThinMaterial)
                        .background(EffectView(.titlebar, blendingMode: .withinWindow, emphasized: false))
                        .padding(.bottom, -8)
                    }
                workspaceLayout
            }
            
        case .vertical(let file, let workspaceLayout):
            VSplitView {
                ReferenceWorkspaceEditor(identifier: file)
                    .ignoresSafeArea(.all, edges: .top)
                    .overlay(alignment: .top) {

                        VStack(spacing: 0) {

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(0..<10, id: \.self) {
                                        Text("Hello \($0)")
                                    }
                                }
                            }
                            .frame(height: 30)
                            .padding(.leading)


                            .scrollContentBackground(.hidden)
                            Divider()

                        }
                        //                        .background(.ultraThinMaterial)
                        .background(EffectView(.titlebar, blendingMode: .withinWindow, emphasized: false))
                        .padding(.bottom, -8)
                    }
                workspaceLayout
            }
//            .safeAreaInset(edge: .top) {
//                Divider()
//                    .background(.ultraThinMaterial)
//            }
        }
    }

    var file: Int {
        switch self {
        case .one(let url):
            return url
        case .horizontal(let url, _), .vertical(let url, _):
            return url
        }
    }
}



//swiftlint:disable all



struct ReferenceWorkspaceEditor: View {
    @EnvironmentObject var doc: ReferenceWorkspaceFileDocument
    var identifier: Int
    var body: some View {

        TextEditor(text: $doc.currentFile)
            .foregroundColor(.red)
            .fontWeight(.semibold)

//            CodeEditTextView(
//                $doc.currentFile,
//                language: .swift,
//                theme: .constant(ThemeModel.shared.selectedTheme!.editor.editorTheme),
//                font: .constant(.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)),
//                tabWidth: .constant(4),
//                lineHeight: .constant(1.4))
//            

//            .id(doc.currentWrapper?.filename)

    }
}
