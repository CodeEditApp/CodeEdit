//
//  GeneralSettingsView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 11.03.22.
//

import SwiftUI
import CodeFile
import Preferences

// MARK: - View

struct GeneralSettingsView: View {
    @AppStorage(Appearances.storageKey) var appearance: Appearances = .default
    @AppStorage(ReopenBehavior.storageKey) var reopenBehavior: ReopenBehavior = .default
    @AppStorage(FileIconStyle.storageKey) var fileIconStyle: FileIconStyle = .default

    @StateObject var model = KeyModel.shared

    var body: some View {
        VStack {
            HStack {
                Text("Appearance:".localized())
                    .padding(.trailing)

                Image("Auto")
                    .resizable()
                    .frame(width: 116, height: 62)
                    .scaledToFit()
                    .cornerRadius(5)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(model.key ? Color.accentColor.opacity(0.7) : Color.gray.opacity(0.3), lineWidth: 3)
                            .opacity(appearance == .system || appearance == .default ? 1 : 0)
                    }
                    .onTapGesture {
                        appearance = .system
                    }
                    .padding(.trailing)

                Image("Light")
                    .resizable()
                    .frame(width: 116, height: 62)
                    .scaledToFit()
                    .cornerRadius(5)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(model.key ? Color.accentColor.opacity(0.7) : Color.gray.opacity(0.3), lineWidth: 3)
                            .opacity(appearance == .light ? 1 : 0)
                    }
                    .onTapGesture {
                        appearance = .light
                    }
                    .padding(.trailing)

                Image("Dark")
                    .resizable()
                    .frame(width: 116, height: 62)
                    .scaledToFit()
                    .cornerRadius(5)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(model.key ? Color.accentColor.opacity(0.7) : Color.gray.opacity(0.3), lineWidth: 3)
                            .opacity(appearance == .dark ? 1 : 0)
                    }
                    .onTapGesture {
                        appearance = .dark
                    }
            }
            .onChange(of: appearance) { tag in
                tag.applyAppearance()
            }
            .padding(.bottom)

			Picker("File Icon Style".localized(), selection: $fileIconStyle) {
				Text("Color".localized())
					.tag(FileIconStyle.color)
				Text("Monochrome".localized())
					.tag(FileIconStyle.monochrome)
			}
            .fixedSize()

			Picker("Reopen Behavior".localized(), selection: $reopenBehavior) {
                Text("Welcome Screen".localized())
                    .tag(ReopenBehavior.welcome)
                Divider()
				Text("Open Panel".localized())
                    .tag(ReopenBehavior.openPanel)
				Text("New Document".localized())
                    .tag(ReopenBehavior.newDocument)
            }
            .fixedSize()

            Spacer()
        }
        .frame(width: 820, height: 450)
        .padding()
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
