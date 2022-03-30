//
//  AppearenceChangeView.swift
//  
//
//  Created by 朱浩宇 on 2022/3/30.
//

import SwiftUI
import Preferences

struct AppearenceChangeView: View {
    @AppStorage(Appearances.storageKey)
    private var appearance: Appearances = .default

    var body: some View {
        HStack {
            AppearenceItem(name: "Auto", image: "Settings Image - Auto", type: .system)
                .padding(.trailing)

            AppearenceItem(name: "Light", image: "Settings Image - Light", type: .light)
                .padding(.trailing)

            AppearenceItem(name: "Dark", image: "Settings Image - Dark", type: .dark)
        }
        .onChange(of: appearance) { tag in
            tag.applyAppearance()
        }
    }

    struct AppearenceItem: View {
        @StateObject var model = KeyModel.shared

        @AppStorage(Appearances.storageKey)
        private var appearance: Appearances = .default

        let name: String
        let image: String
        let type: Appearances

        var body: some View {
            VStack {
                ZStack(alignment: .center) {
                    if model.key {
                        Color.focusedColor.opacity(appearance == type ? 1 : 0)
                            .frame(width: 67 + 3, height: 46 + 3)
                            .cornerRadius(5)
                    } else {
                        Color.unfocusedColor.opacity(appearance == type ? 1 : 0)
                            .frame(width: 67 + 3, height: 46 + 3)
                            .cornerRadius(5)
                    }

                    Image(image, bundle: Bundle.module)
                        .resizable()
                        .frame(width: 67, height: 46)
                        .scaledToFit()
                        .cornerRadius(5)
                        .onTapGesture {
                            appearance = type
                        }
                }

                Text(name)
            }
        }
    }
}
