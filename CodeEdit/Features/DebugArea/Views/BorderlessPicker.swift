////
////  BorderlessPicker.swift
////  CodeEdit
////
////  Created by Austin Condiff on 5/26/23.
////
//
//import SwiftUI
//import AppKit
//
//struct Option<T: Hashable> {
//    let label: String
//    let id: T
//}
//
//struct BorderlessPicker<T: Hashable>: NSViewRepresentable {
//    typealias NSViewType = NSPopUpButton
//
//    var selection: Binding<T>
//    var content: () -> [Option<T>]
//
//    init(selection: Binding<T>, content: @escaping () -> [Option<T>]) {
//        self.selection = selection
//        self.content = content
//    }
//
//    func makeNSView(context: Context) -> NSPopUpButton {
//        let picker = NSPopUpButton(frame: .zero)
//        picker.bezelStyle = .borderless
//        picker.target = context.coordinator
//        picker.action = #selector(Coordinator.selectionDidChange(_:))
//        picker.translatesAutoresizingMaskIntoConstraints = false
//        return picker
//    }
//
//    func updateNSView(_ nsView: NSPopUpButton, context: Context) {
//        nsView.removeAllItems()
//        let options = content()
//        for option in options {
//            nsView.addItem(withTitle: option.label)
//        }
//        if let selectedItem = options.first(where: { $0.id == selection.wrappedValue }) {
//            let index = options.firstIndex(of: selectedItem)!
//            nsView.selectItem(at: index)
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(selection: selection)
//    }
//
//    class Coordinator: NSObject {
//        var selection: Binding<T>
//
//        init(selection: Binding<T>) {
//            self.selection = selection
//        }
//
//        @objc func selectionDidChange(_ sender: NSPopUpButton) {
//            let selectedIndex = sender.indexOfSelectedItem
//            let options = content()
//            if selectedIndex >= 0 && selectedIndex < options.count {
//                selection.wrappedValue = options[selectedIndex].id
//            }
//        }
//    }
//}
//
//struct ContentView: View {
//    @State private var selectedOption: String = "Option 1"
//    let options = [
//        Option(label: "Option 1", id: "option1"),
//        Option(label: "Option 2", id: "option2"),
//        Option(label: "Option 3", id: "option3")
//    ]
//
//    var body: some View {
//        VStack {
//            Text("Selected option: \(selectedOption)")
//
//            BorderlessPicker(selection: $selectedOption) {
//                ForEach(options, id: \.id) { option in
//                    Text(option.label)
//                        .tag(option.id)
//                }
//            }
//            .frame(width: 200)
//        }
//        .padding()
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
