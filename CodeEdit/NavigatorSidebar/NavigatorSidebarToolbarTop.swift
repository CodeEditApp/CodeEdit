//
//  SideBarToolbar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import CodeEditSymbols
import AppKit

struct NavigatorSidebarToolbarTop: View {
    @Environment(\.controlActiveState)
    var activeState

    typealias iconInfo = (imageName: String, title: String, id: Int)
    @State private var icons = [
        DockIcon(imageName: "folder", title: "Project", id: 0),
        DockIcon(imageName: "vault", title: "Version Control", id: 1),
        DockIcon(imageName: "magnifyingglass", title: "Search", id: 2),
        DockIcon(imageName: "shippingbox", title: "...", id: 3),
        DockIcon(imageName: "play", title: "...", id: 4),
        DockIcon(imageName: "exclamationmark.triangle", title: "...", id: 5),
        DockIcon(imageName: "curlybraces.square", title: "...", id: 6),
        DockIcon(imageName: "puzzlepiece.extension", title: "...", id: 7),
        DockIcon(imageName: "square.grid.2x2", title: "...", id: 8)
    ]
    
    @Binding
    var selection: Int
    @State var targeted: Bool = true
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(icons) { icon in
                makeIcon(named: icon.imageName, title: icon.title, id: icon.id)
                    .onDrop(of: [.utf8PlainText], isTargeted: self.$targeted) { providers in
                        guard let provider = providers.first else { return false }
                        provider.loadItem(forTypeIdentifier: "public.utf8-plain-text", options: nil) { data, error in
                            if let data = data as? Data, let name = String(data: data, encoding: .utf8), let movedIndex = icons.firstIndex(where: { $0.imageName == name }), let insertionIndex = icons.firstIndex (where: { $0.imageName == icon.imageName }) {
                                let tempIcon = icons[movedIndex]
                                icons.remove(at: movedIndex)
                                icons.insert(tempIcon, at: insertionIndex)
                            }
                        }
                        return false
                    }
                    .onDrag {
                        return NSItemProvider(object: NSString(string: icon.imageName))
                    }
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
    
    func move(from source: IndexSet, to destination: Int) {
        print("source: \(source) and index: \(destination)")
        icons.move(fromOffsets: source, toOffset: destination)
    }

    func makeIcon(named: String,
              title: String,
              id: Int,
              scale: Image.Scale = .medium
    ) -> some View {
        getSafeImage(named: named, accesibilityDescription: title)
            .help(title)
            .frame(width: 25, height: 25, alignment: .center)
            .onAppear {
                selection = id
            }
            
//        Button {
//            selection = id
//        } label: {
//            getSafeImage(named: named, accesibilityDescription: title)
//                .help(title)
//        }
        //.buttonStyle(NavigatorToolbarButtonStyle(id: id, selection: selection, activeState: activeState))
        //.imageScale(scale)
    }
    
    func getSafeImage(named: String, accesibilityDescription: String?) -> Image {
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
    
    private struct DockIcon: Identifiable, DropDelegate {
        func performDrop(info: DropInfo) -> Bool {
            guard let provider = info.itemProviders(for: [.utf8PlainText]).first else { return false }
            provider.loadItem(forTypeIdentifier: "public.utf8-plain-text", options: nil) { data, error in
                if let data = data as? Data, let name = String(data: data, encoding: .utf8) {
                    print(name)
                }
            }
            return false
        }
        
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
