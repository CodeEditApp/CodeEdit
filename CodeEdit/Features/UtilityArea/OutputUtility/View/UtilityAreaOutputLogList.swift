//
//  UtilityAreaOutputLogList.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/18/25.
//

import SwiftUI

struct UtilityAreaOutputLogList<Source: UtilityAreaOutputSource, Toolbar: View>: View {
    let source: Source

    @State var output: [Source.Message] = []
    @Binding var filterText: String
    var toolbar: () -> Toolbar

    init(source: Source, filterText: Binding<String>, @ViewBuilder toolbar: @escaping () -> Toolbar) {
        self.source = source
        self._filterText = filterText
        self.toolbar = toolbar
    }

    var filteredOutput: [Source.Message] {
        if filterText.isEmpty {
            return output
        }
        return output.filter { item in
            return filterText == "" ? true : item.message.contains(filterText)
        }
    }

    var body: some View {
        List(filteredOutput.reversed()) { item in
            VStack(spacing: 2) {
                HStack(spacing: 0) {
                    Text(item.message)
                        .fontDesign(.monospaced)
                        .font(.system(size: 12, weight: .regular).monospaced())
                    Spacer(minLength: 0)
                }
                HStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: item.level.iconName)
                            .foregroundColor(.white)
                            .font(.system(size: 7, weight: .semibold))
                            .frame(width: 12, height: 12)
                            .background(
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(item.level.color)
                                    .aspectRatio(1.0, contentMode: .fit)
                            )
                        Text(item.date.logFormatted())
                            .fontWeight(.medium)
                    }
                    if let subsystem = item.subsystem {
                        HStack(spacing: 2) {
                            Image(systemName: "gearshape.2")
                                .font(.system(size: 8, weight: .regular))
                            Text(subsystem)
                        }
                    }
                    if let category = item.category {
                        HStack(spacing: 2) {
                            Image(systemName: "square.grid.3x3")
                                .font(.system(size: 8, weight: .regular))
                            Text(category)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .foregroundStyle(.secondary)
                .font(.system(size: 9, weight: .semibold).monospaced())
            }
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
            .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
            .listRowBackground(item.level.backgroundColor)
        }
        .listStyle(.plain)
        .listRowInsets(EdgeInsets())
        .rotationEffect(.radians(.pi))
        .scaleEffect(x: -1, y: 1, anchor: .center)
        .task(id: source.id) {
            output = source.cachedMessages()
            for await item in source.streamMessages() {
                output.append(item)
            }
        }
        .paneToolbar {
            toolbar()
            Spacer()
            UtilityAreaFilterTextField(title: "Filter", text: $filterText)
                .frame(maxWidth: 175)
            Button {
                output.removeAll(keepingCapacity: true)
            } label: {
                Image(systemName: "trash")
            }
        }
    }
}
