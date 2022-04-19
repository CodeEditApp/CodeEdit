//
//  InspectorSidebarToolbar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/21/22.
//

import SwiftUI

struct InspectorSidebarToolbarTop: View {
    @Binding
    var selection: Int

    @State var targeted: Bool = true
    @State private var icons = [
        InspectorDockIcon(imageName: "doc", title: "File Inspector", id: 0),
        InspectorDockIcon(imageName: "clock", title: "History Inspector", id: 1),
        InspectorDockIcon(imageName: "questionmark.circle", title: "Quick Help Inspector", id: 2)
    ]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(icons) { icon in
                makeInspectorIcon(systemImage: icon.imageName, title: icon.title, id: icon.id)
            }
        }
        .frame(height: 29, alignment: .center)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            Divider()
        }
        .overlay(alignment: .bottom) {
            Divider()
        }
        .background(Rectangle()
            .foregroundColor(Color("InspectorBackgroundColor")))
    }

    func makeInspectorIcon(systemImage: String, title: String, id: Int) -> some View {
        Button {
            selection = id
        } label: {
            Image(systemName: systemImage)
                .help(title)
                .symbolVariant(id == selection ? .fill : .none)
                .foregroundColor(id == selection ? .accentColor : .secondary)
                .frame(width: 16, alignment: .center)
                .onDrop(of: [.utf8PlainText], isTargeted: nil) { providers in
                    guard let provider = providers.first else { return false }
                    provider.loadItem(forTypeIdentifier: "public.utf8-plain-text", options: nil) { data, _ in
                        if let data = data as? Data,
                            let name = String(data: data, encoding: .utf8),
                            let movedIndex = icons.firstIndex(where: { $0.imageName == name }),
                            let insertionIndex = icons.firstIndex(where: { $0.imageName == systemImage }) {

                            let tempIcon = icons[movedIndex]
                            icons.remove(at: movedIndex)
                            icons.insert(tempIcon, at: insertionIndex)
                        }
                    }
                    return false
                }
                .onDrag {
                    return .init(object: NSString(string: systemImage))
                }
        }
        .buttonStyle(.plain)
    }

    private func getSafeImage(named: String, accesibilityDescription: String?) -> Image {
        if let nsImage = NSImage(systemSymbolName: named, accessibilityDescription: accesibilityDescription) {
            return Image(nsImage: nsImage)
        } else {
            return Image(symbol: named)
        }
    }

    private struct InspectorDockIcon: Identifiable {
        let imageName: String
        let title: String
        var id: Int
    }
}

struct InspectorSidebarToolbar_Previews: PreviewProvider {
    static var previews: some View {
        InspectorSidebarToolbarTop(selection: .constant(0))
    }
}
