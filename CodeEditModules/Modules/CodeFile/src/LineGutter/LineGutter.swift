//
//  LineGutter.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 19/03/22.
//

import Cocoa

final class LineGutter: NSRulerView {
    private var _lineIndices: [Int]? {
        didSet {
            DispatchQueue.main.async {
                let newThickness = self.calculateRuleThickness()
                if abs(self.ruleThickness - newThickness) > 1 {
                    self.ruleThickness = CGFloat(ceil(newThickness))
                    self.needsDisplay = true
                }
            }
        }
    }

    private var lineIndices: [Int]? {
            if _lineIndices == nil {
                calculateLines()
            }

            return _lineIndices
    }

    private var textView: NSTextView? { clientView as? NSTextView }
    override var isOpaque: Bool { false }
    override var clientView: NSView? {
        willSet {
            let center = NotificationCenter.default
            if let oldView = clientView as? NSTextView, oldView != newValue {
                center.removeObserver(self, name: NSText.didEndEditingNotification, object: oldView.textStorage)
                center.removeObserver(self, name: NSView.boundsDidChangeNotification, object: scrollView?.contentView)
            }
            center.addObserver(
                self,
                selector: #selector(textDidChange(_:)),
                name: NSText.didChangeNotification,
                object: newValue
            )
            scrollView?.contentView.postsBoundsChangedNotifications = true
            center.addObserver(
                self,
                selector: #selector(boundsDidChange(_:)),
                name: NSView.boundsDidChangeNotification,
                object: scrollView?.contentView
            )
            invalidateLineIndices()
        }
    }

    private let rulerMargin: CGFloat = 5
    private let rulerWidth: CGFloat
    private let font: NSFont
    public var textColor: NSColor
    public var backgroundColor: NSColor

    init(
        scrollView: NSScrollView,
        width: CGFloat,
        font: NSFont,
        textColor: NSColor,
        backgroundColor: NSColor
    ) {
        rulerWidth = width
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        super.init(scrollView: scrollView, orientation: .verticalRuler)
        clientView = scrollView.documentView
        ruleThickness = width
        needsDisplay = true
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func boundsDidChange(_ notification: Notification) {
        needsDisplay = true
    }

    @objc
    func textDidChange(_ notification: Notification) {
        invalidateLineIndices()
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        drawHashMarksAndLabels(in: dirtyRect)
    }

    func invalidateLineIndices() {
        _lineIndices = nil
    }

    func lineNumberForCharacterIndex(index: Int) -> Int {
        guard let lineIndices = lineIndices else {
            return 0
        }

        var left = 0, right = lineIndices.count
        while right - left > 1 {
            let mid = (left + right) / 2
            let lineIndex = lineIndices[mid]
            if index < lineIndex {
                right = mid
            } else if index > lineIndex {
                left = mid
            } else {
                return mid + 1
            }
        }
        return left + 1
    }

    func calculateRuleThickness() -> CGFloat {
        let string = String(lineIndices?.last ?? 0) as NSString
        let rect = calculateStringSize(string)
        return max(rect.width, rulerWidth)
    }

    func calculateLines() {
        var lineIndices = [Int]()
        guard let textView = textView else {
            return
        }
        let text = textView.string as NSString
        let textLength = text.length
        var totalLines = 0
        var charIndex = 0
        repeat {
            lineIndices.append(charIndex)
            charIndex = text.lineRange(for: NSRange(location: charIndex, length: 0)).upperBound
            totalLines += 1
        } while charIndex < textLength

        // Check for trailing return
        var lineEndIndex = 0, contentEndIndex = 0
        let lastObject = lineIndices[lineIndices.count - 1]
        text.getLineStart(
            nil,
            end: &lineEndIndex,
            contentsEnd: &contentEndIndex,
            for: NSRange(location: lastObject, length: 0)
        )
        if contentEndIndex < lineEndIndex {
            lineIndices.append(lineEndIndex)
        }
        _lineIndices = lineIndices
    }

    // swiftlint:disable function_body_length
    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView = textView,
              let clientView = clientView,
              let layoutManager = textView.layoutManager,
              let container = textView.textContainer,
              let scrollView = scrollView,
              let lineIndices = lineIndices
        else { return }

        // Make background
        let docRect = convert(clientView.bounds, from: clientView)
        let yOrigin = docRect.origin.y
        let height = docRect.size.height
        let width = bounds.size.width
        backgroundColor.set()

        NSRect(x: 0, y: yOrigin, width: width, height: height).fill()

        // Code folding area
        NSRect(x: width - 8, y: yOrigin, width: 8, height: height).fill()

        let nullRange = NSRange(location: NSNotFound, length: 0)
        var lineRectCount = 0

        let textVisibleRect = scrollView.contentView.bounds
        let rulerBounds = bounds
        let textInset = textView.textContainerInset.height

        let glyphRange = layoutManager.glyphRange(forBoundingRect: textVisibleRect, in: container)
        let charRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

        let startChange = lineNumberForCharacterIndex(index: charRange.location)
        let endChange = lineNumberForCharacterIndex(index: charRange.upperBound)
        for lineNumber in startChange...endChange {
            let charIndex = lineIndices[lineNumber - 1]
            if let lineRectsForRange = layoutManager.rectArray(
                forCharacterRange: NSRange(location: charIndex, length: 0),
                withinSelectedCharacterRange: nullRange,
                in: container,
                rectCount: &lineRectCount
            ), lineRectCount > 0 {
                let ypos = textInset + lineRectsForRange[0].minY - textVisibleRect.minY
                let labelText = NSString(format: "%ld", lineNumber)
                let labelSize = calculateStringSize(labelText)

                let lineNumberRect = NSRect(
                    x: rulerBounds.width - labelSize.width - rulerMargin,
                    y: ypos + (lineRectsForRange[0].height - labelSize.height) / 2,
                    width: rulerBounds.width - rulerMargin * 2,
                    height: lineRectsForRange[0].height
                )

                labelText.draw(in: lineNumberRect, withAttributes: textAttributes())
            }

            // we are past the visible range so exit for
            if charIndex > charRange.upperBound {
                break
            }
        }
    }

    func calculateStringSize(_ string: NSString) -> CGRect {
        string.boundingRect(
            with: NSSize(width: self.frame.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: textAttributes(),
            context: nil
        )
    }

    func textAttributes() -> [NSAttributedString.Key: AnyObject] {
        [
            NSAttributedString.Key.font: self.font,
            NSAttributedString.Key.foregroundColor: self.textColor
        ]
    }
}
