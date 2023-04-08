//
//  SettingsForm.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/8/23.
//

import SwiftUI
import Introspect

struct SettingsForm<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var model: SettingsModel
    @ViewBuilder var content: Content
    @State private var offset = CGFloat.zero

    var body: some View {
        Form {
            Section {
                EmptyView()
            } footer: {
                Rectangle()
                    .frame(height: 0)
                    .background(.red)
                    .background(
                        GeometryReader {
                            Color.clear.preference(
                                key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named("scroll")).origin.y
                            )
                        }
                    )
                    .onPreferenceChange(ViewOffsetKey.self) {
                        if $0 <= 80.0 && !model.scrolledToTop {
                            model.scrolledToTop = true
                        } else if $0 > 80.0 && model.scrolledToTop {
                            model.scrolledToTop = false
                        }
                    }
            }
                .padding(.vertical, -100)

            content
        }
        .introspectScrollView { scrollView in
            scrollView.scrollerInsets.top = 48
        }
        .formStyle(.grouped)
        .coordinateSpace(name: "scroll")
        .safeAreaInset(edge: .top, spacing: -50) {
            if !model.scrolledToTop {
                EffectView(.menu)
                    .shadow(
                        color: .black.opacity(colorScheme == .dark ? 1 : 0.2),
                        radius: 0.33,
                        x: 0,
                        y: 0.5
                    )
                    .transition(.opacity)
                    .ignoresSafeArea()
                    .frame(height: 0)
            }
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
