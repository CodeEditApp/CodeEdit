//
//  AppearenceChangeView.swift
//  
//
//  Created by 朱浩宇 on 2022/3/30.
//

import SwiftUI
import Preferences

struct AppearenceChangeView: View {
    @StateObject var model = KeyModel.shared

    @AppStorage(Appearances.storageKey)
    private var appearance: Appearances = .default

    var body: some View {
        HStack {
            VStack {
                ZStack(alignment: .center) {
                    if model.key {
                        Color.focusedColor.opacity(appearance == .system || appearance == .default ? 1 : 0)
                            .frame(width: 67 + 3, height: 46 + 3)
                            .cornerRadius(5)
                    } else {
                        Color.unfocusedColor.opacity(appearance == .system || appearance == .default ? 1 : 0)
                            .frame(width: 67 + 3, height: 46 + 3)
                            .cornerRadius(5)
                    }

                    Image("Settings Image - Auto", bundle: Bundle.module)
                        .resizable()
                        .frame(width: 67, height: 46)
                        .scaledToFit()
                        .cornerRadius(5)
                        .onTapGesture {
                            appearance = .system
                        }
                }

                Text("Auto")
            }
            .padding(.trailing)

            VStack {
                ZStack(alignment: .center) {
                    if model.key {
                        Color.focusedColor.opacity(appearance == .light ? 1 : 0)
                            .frame(width: 67 + 3, height: 46 + 3)
                            .cornerRadius(5)
                    } else {
                        Color.unfocusedColor.opacity(appearance == .light ? 1 : 0)
                            .frame(width: 67 + 3, height: 46 + 3)
                            .cornerRadius(5)
                    }

                    Image("Settings Image - Light", bundle: Bundle.module)
                        .resizable()
                        .frame(width: 67, height: 46)
                        .scaledToFit()
                        .cornerRadius(5)
                        .onTapGesture {
                            appearance = .light
                        }
                }

                Text("Light")
            }
            .padding(.trailing)

            VStack {
                ZStack(alignment: .center) {
                    if model.key {
                        Color.focusedColor.opacity(appearance == .dark ? 1 : 0)
                            .frame(width: 67 + 3, height: 46 + 3)
                            .cornerRadius(5)
                    } else {
                        Color.unfocusedColor.opacity(appearance == .dark ? 1 : 0)
                            .frame(width: 67 + 3, height: 46 + 3)
                            .cornerRadius(5)
                    }

                    Image("Settings Image - Dark", bundle: Bundle.module)
                        .resizable()
                        .frame(width: 67, height: 46)
                        .scaledToFit()
                        .cornerRadius(5)
                        .onTapGesture {
                            appearance = .dark
                        }
                }

                Text("Dark")
            }
            .padding(.trailing)
        }
        .onChange(of: appearance) { tag in
            tag.applyAppearance()
        }
    }
}
