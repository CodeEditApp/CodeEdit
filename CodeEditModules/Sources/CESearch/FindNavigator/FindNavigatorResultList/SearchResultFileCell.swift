//
//  SearchResultFileCell.swift
//  Search
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import AppKit
import CodeEditCore

/// File-row cell for the find navigator's result list.
/// Owned by the Search package so it renders from `SearchResultFile`
/// (name + system file icon) without the project navigator's cell.
final class SearchResultFileCell: NSTableCellView {
    init(frame frameRect: NSRect, file: SearchResultFile, rowHeight: Double) {
        super.init(frame: frameRect)

        let icon = NSImageView(frame: NSRect(x: 2, y: 0, width: rowHeight, height: frameRect.height))
        icon.image = NSWorkspace.shared.icon(forFile: file.url.path)
        icon.symbolConfiguration = .init(pointSize: rowHeight * 0.64, weight: .regular)
        addSubview(icon)
        imageView = icon

        let label = NSTextField(labelWithString: file.name)
        label.frame = NSRect(
            x: icon.frame.maxX + 4,
            y: (frameRect.height - 17) / 2,
            width: frameRect.width - icon.frame.maxX - 8,
            height: 17
        )
        label.font = .systemFont(ofSize: NSFont.systemFontSize(for: .regular))
        label.lineBreakMode = .byTruncatingTail
        addSubview(label)
        textField = label
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
