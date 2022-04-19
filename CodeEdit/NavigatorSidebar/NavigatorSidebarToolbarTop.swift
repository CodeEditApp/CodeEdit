//
//  SideBarToolbar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import CodeEditSymbols

struct NavigatorSidebarToolbarTop: View {
    @Environment(\.controlActiveState)
    var activeState

    @Binding
    var selection: Int

    @State private var icons = [
        SidebarDockIcon(imageName: "folder", title: "Project", id: 0),
        SidebarDockIcon(imageName: "vault", title: "Version Control", id: 1),
        SidebarDockIcon(imageName: "magnifyingglass", title: "Search", id: 2),
        SidebarDockIcon(imageName: "shippingbox", title: "...", id: 3),
        SidebarDockIcon(imageName: "play", title: "...", id: 4),
        SidebarDockIcon(imageName: "exclamationmark.triangle", title: "...", id: 5),
        SidebarDockIcon(imageName: "curlybraces.square", title: "...", id: 6),
        SidebarDockIcon(imageName: "puzzlepiece.extension", title: "...", id: 7),
        SidebarDockIcon(imageName: "square.grid.2x2", title: "...", id: 8)
    ]
    var body: some View {
        HStack(spacing: 2) {
            ForEach(icons) { icon in
                makeIcon(named: icon.imageName, title: icon.title, id: icon.id)
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
    }

    func makeIcon(named: String, title: String, id: Int, scale: Image.Scale = .medium) -> some View {
        Button {
            selection = id
        } label: {
            getSafeImage(named: named, accesibilityDescription: title)
                .help(title)
                .onDrop(of: [.utf8PlainText], isTargeted: nil) { providers in
                    guard let provider = providers.first else { return false }
                    provider.loadItem(forTypeIdentifier: "public.utf8-plain-text", options: nil) { data, _ in
                        if let data = data as? Data,
                            let name = String(data: data, encoding: .utf8),
                            let movedIndex = icons.firstIndex(where: { $0.imageName == name }),
                            let insertionIndex = icons.firstIndex(where: { $0.imageName == named }) {

                            let tempIcon = icons[movedIndex]
                            icons.remove(at: movedIndex)
                            icons.insert(tempIcon, at: insertionIndex)
                        }
                    }
                    return false
                }
                .onDrag {
                    return .init(object: NSString(string: named))
                }
        }
        .buttonStyle(NavigatorToolbarButtonStyle(id: id, selection: selection, activeState: activeState))
        .imageScale(scale)
    }

    private func getSafeImage(named: String, accesibilityDescription: String?) -> Image {
        if let nsImage = NSImage(systemSymbolName: named, accessibilityDescription: accesibilityDescription) {
            return Image(nsImage: nsImage)
        } else {
            return Image(symbol: named)
        }
    }

    struct NavigatorToolbarButtonStyle: ButtonStyle {
        var id: Int
        var selection: Int
        var activeState: ControlActiveState
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.system(size: 12, weight: id == selection ? .semibold : .regular))
                .symbolVariant(id == selection ? .fill : .none)
                .foregroundColor(id == selection ? .accentColor : configuration.isPressed ? .primary : .secondary)
                .frame(width: 25, height: 25, alignment: .center)
                .contentShape(Rectangle())
                .opacity(activeState == .inactive ? 0.45 : 1)
        }
    }

    private struct SidebarDockIcon: Identifiable {
        let imageName: String
        let title: String
        var id: Int
    }
}

struct NavigatorSidebarToolbar_Previews: PreviewProvider {
    static var previews: some View {
        NavigatorSidebarToolbarTop(selection: .constant(0))
    }
}
