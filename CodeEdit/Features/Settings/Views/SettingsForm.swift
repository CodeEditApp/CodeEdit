//
//  SettingsForm.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/8/23.
//

import SwiftUI
import SwiftUIIntrospect

struct SettingsForm<Content: View>: View {
    @Environment(\.colorScheme)
    private var colorScheme
    @Environment(\.controlActiveState)
    private var activeState
    @EnvironmentObject var model: SettingsViewModel
    @ViewBuilder var content: Content

    var body: some View {
        Form {
            Section {
                EmptyView()
            } footer: {
                Rectangle()
                    .frame(height: 0)
                    .background(
                        GeometryReader {
                            Color.clear.preference(
                                key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named("scroll")).origin.y
                            )
                        }
                    )
                    .onPreferenceChange(ViewOffsetKey.self) {
                        if $0 <= -20.0 && !model.scrolledToTop {
                            withAnimation {
                                model.scrolledToTop = true
                            }
                        } else if $0 > -20.0 && model.scrolledToTop {
                            withAnimation {
                                model.scrolledToTop = false
                            }
                        }
                    }
            }
            content
        }
        .introspect(.scrollView, on: .macOS(.v10_15, .v11, .v12, .v13, .v14, .v15)) {
            $0.scrollerInsets.top = 50
        }
        .formStyle(.grouped)
        .coordinateSpace(name: "scroll")
        .safeAreaInset(edge: .top, spacing: -50) {
            EffectView(.menu)
                .opacity(!model.scrolledToTop ? 1 : 0)
                .transaction { transaction in
                    transaction.animation = nil
                }
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        gradient: Gradient(
                            colors: [.black.opacity(colorScheme == .dark ? 1 : 0.17), .black.opacity(0)]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: colorScheme == .dark || activeState == .inactive ? 1 : 2)
                    .padding(.bottom, colorScheme == .dark || activeState == .inactive ? -1 : -2)
                    .opacity(!model.scrolledToTop ? 1 : 0)
                    .transition(.opacity)
                }
                .ignoresSafeArea()
                .frame(height: 0)
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
