//
//  UXCodeTextView.swift
//  CodeEditor
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import Highlightr

#if os(macOS)
  import AppKit

  typealias UXTextView          = NSTextView
  typealias UXTextViewDelegate  = NSTextViewDelegate
#else
  import UIKit

  typealias UXTextView          = UITextView
  typealias UXTextViewDelegate  = UITextViewDelegate
#endif

/**
 * Subclass of NSTextView/UITextView which adds some code editing features to
 * the respective Cocoa views.
 *
 * Currently pretty tightly coupled to `CodeEditor`.
 */
final class UXCodeTextView: UXTextView {
  
  fileprivate let highlightr = Highlightr()
  
  private var hlTextStorage : CodeAttributedString? {
    return textStorage as? CodeAttributedString
  }
  
  /// If the user starts a newline, the editor automagically adds the same
  /// whitespace as on the previous line.
  var isSmartIndentEnabled = true

  var indentStyle          = CodeEditor.IndentStyle.system {
    didSet {
      guard oldValue != indentStyle else { return }
      reindent(oldStyle: oldValue)
    }
  }
  
  var autoPairCompletion = [ String : String ]()
  
  var language : CodeEditor.Language? {
    set {
      guard hlTextStorage?.language != newValue?.rawValue else { return }
      hlTextStorage?.language = newValue?.rawValue
    }
    get { return hlTextStorage?.language.flatMap(CodeEditor.Language.init) }
  }
  private(set) var themeName = CodeEditor.ThemeName.default {
    didSet {
      highlightr?.setTheme(to: themeName.rawValue)
      if let font = highlightr?.theme?.codeFont { self.font = font }
    }
  }
  
  init() {
    let textStorage = highlightr.flatMap {
                        CodeAttributedString(highlightr: $0)
                      }
                   ?? NSTextStorage()
    
    let layoutManager = NSLayoutManager()
    textStorage.addLayoutManager(layoutManager)
    
    let textContainer = NSTextContainer()
    textContainer.widthTracksTextView  = true // those are key!
    layoutManager.addTextContainer(textContainer)
    
    super.init(frame: .zero, textContainer: textContainer)
  
    #if os(macOS)
      isVerticallyResizable = true
      maxSize               = .init(width: 0, height: 1_000_000)
    
      isRichText                           = false
      allowsImageEditing                   = false
      isGrammarCheckingEnabled             = false
      isContinuousSpellCheckingEnabled     = false
      isAutomaticSpellingCorrectionEnabled = false
      isAutomaticLinkDetectionEnabled      = false
      isAutomaticDashSubstitutionEnabled   = false
      isAutomaticQuoteSubstitutionEnabled  = false
      usesRuler                            = false
    #endif
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Actions

  #if os(macOS)
    override func changeFont(_ sender: Any?) {
      let coordinator = delegate as? UXCodeTextViewDelegate
      
      let old = coordinator?.fontSize
             ?? highlightr?.theme?.codeFont?.pointSize
             ?? NSFont.systemFontSize
      let new : CGFloat
      
      let fm = NSFontManager.shared
      switch fm.currentFontAction {
        case .sizeUpFontAction   : new = old + 1
        case .sizeDownFontAction : new = old - 1

        case .viaPanelFontAction :
          guard let font = fm.selectedFont else {
            return super.changeFont(sender)
          }
          new = font.pointSize

        case .addTraitFontAction, .removeTraitFontAction: // bold/italic
          NSSound.beep()
          return
          
        default:
          guard let font = fm.selectedFont else {
            return super.changeFont(sender)
          }
          new = font.pointSize
      }
      
      coordinator?.fontSize = new
      applyNewFontSize(new)
    }
  #endif // macOS
  
  override func copy(_ sender: Any?) {
    guard let coordinator = delegate as? UXCodeTextViewDelegate else {
      assertionFailure("Expected coordinator as delegate")
      return super.copy(sender)
    }
    if coordinator.allowCopy { super.copy(sender) }
  }
  
  
  #if os(macOS)
    // MARK: - Smarts as shown in https://github.com/naoty/NTYSmartTextView
    
    private var isAutoPairEnabled : Bool { return !autoPairCompletion.isEmpty }
    
    override func insertNewline(_ sender: Any?) {
      guard isSmartIndentEnabled else { return super.insertNewline(sender) }
      
      let currentLine = self.currentLine
      let wsPrefix = currentLine.prefix(while: {
        guard let scalar = $0.unicodeScalars.first else { return false }
        return CharacterSet.whitespaces.contains(scalar) // yes, yes
      })
      
      super.insertNewline(sender)
      
      if !wsPrefix.isEmpty {
        insertText(String(wsPrefix), replacementRange: selectedRange())
      }
    }
    
    override func insertTab(_ sender: Any?) {
      guard case .softTab(let width) = indentStyle else {
        return super.insertTab(sender)
      }
      super.insertText(String(repeating: " ", count: width),
                       replacementRange: selectedRange())
    }
  
    override func insertText(_ string: Any, replacementRange: NSRange) {
      super.insertText(string, replacementRange: replacementRange)
      guard isAutoPairEnabled              else { return }
      guard let string = string as? String else { return } // TBD: NSAttrString
      
      guard let end = autoPairCompletion[string] else { return }
      super.insertText(end, replacementRange: selectedRange())
      super.moveBackward(self)
    }
  
    override func deleteBackward(_ sender: Any?) {
      guard isAutoPairEnabled, !isStartOrEndOfLine else {
        return super.deleteBackward(sender)
      }
      
      let s             = self.string
      let selectedRange = swiftSelectedRange
      guard selectedRange.lowerBound > s.startIndex,
            selectedRange.lowerBound < s.endIndex else
      {
        return super.deleteBackward(sender)
      }
      
      let startIdx  = s.index(before: selectedRange.lowerBound)
      let startChar = s[startIdx..<selectedRange.lowerBound]
      guard let expectedEndChar = autoPairCompletion[String(startChar)] else {
        return super.deleteBackward(sender)
      }
      
      let endIdx    = s.index(after: selectedRange.lowerBound)
      let endChar   = s[selectedRange.lowerBound..<endIdx]
      guard expectedEndChar[...] == endChar else {
        return super.deleteBackward(sender)
      }
      
      super.deleteForward(sender)
      super.deleteBackward(sender)
    }
  #endif // macOS
  
  private func reindent(oldStyle: CodeEditor.IndentStyle) {
    // - walk over the lines, strip and count the whitespaces and do something
    //   clever :-)
  }


  // MARK: - Themes
  
  @discardableResult
  func applyNewFontSize(_ newSize: CGFloat) -> Bool {
    applyNewTheme(nil, andFontSize: newSize)
  }
  
  @discardableResult
  func applyNewTheme(_ newTheme: CodeEditor.ThemeName) -> Bool {
    guard themeName != newTheme else { return false }
    guard let highlightr = highlightr,
          highlightr.setTheme(to: newTheme.rawValue),
          let theme      = highlightr.theme else { return false }
    if let font = theme.codeFont, font !== self.font { self.font = font }
    return true
  }

  @discardableResult
  func applyNewTheme(_ newTheme: CodeEditor.ThemeName? = nil,
                     andFontSize newSize: CGFloat) -> Bool
  {
    // Setting the theme reloads it (i.e. makes a "copy").
    guard let highlightr = highlightr, highlightr.setTheme(to: (newTheme ?? themeName).rawValue),
          let theme      = highlightr.theme else { return false }
    
    guard theme.codeFont?.pointSize != newSize else { return true }
    
    theme.codeFont       = theme.codeFont?      .withSize(newSize)
    theme.boldCodeFont   = theme.boldCodeFont?  .withSize(newSize)
    theme.italicCodeFont = theme.italicCodeFont?.withSize(newSize)
    if let font = theme.codeFont, font !== self.font { self.font = font }
    return true
  }
}

protocol UXCodeTextViewDelegate: UXTextViewDelegate {
  
  var allowCopy : Bool     { get }
  var fontSize  : CGFloat? { get set }
}

// MARK: - Smarts as shown in https://github.com/naoty/NTYSmartTextView

extension UXTextView {
  
  fileprivate var swiftSelectedRange : Range<String.Index> {
    let s = self.string
    guard !s.isEmpty else { return s.startIndex..<s.startIndex }
    #if os(macOS)
      guard let selectedRange = Range(self.selectedRange(), in: s) else {
        assertionFailure("Could not convert the selectedRange?")
        return s.startIndex..<s.startIndex
      }
    #else
      guard let selectedRange = Range(self.selectedRange, in: s) else {
        assertionFailure("Could not convert the selectedRange?")
        return s.startIndex..<s.startIndex
      }
    #endif
    return selectedRange
  }
  
  fileprivate var currentLine: String {
    let s = self.string
    return String(s[s.lineRange(for: swiftSelectedRange)])
  }
  
  fileprivate var isEndOfLine : Bool {
    let ( _, isEnd ) = getStartOrEndOfLine()
    return isEnd
  }
  fileprivate var isStartOrEndOfLine : Bool {
    let ( isStart, isEnd ) = getStartOrEndOfLine()
    return isStart || isEnd
  }
  
  fileprivate func getStartOrEndOfLine() -> ( isStart: Bool, isEnd: Bool ) {
    let s             = self.string
    let selectedRange = self.swiftSelectedRange
    var lineStart = s.startIndex, lineEnd = s.endIndex, contentEnd = s.endIndex
    string.getLineStart(&lineStart, end: &lineEnd, contentsEnd: &contentEnd,
                        for: selectedRange)
    return ( isStart : selectedRange.lowerBound == lineStart,
             isEnd   : selectedRange.lowerBound == lineEnd )
  }
}


// MARK: - UXKit

#if os(macOS)

  extension NSTextView {
    var codeTextStorage : NSTextStorage? { return textStorage }
  }
#else // iOS
  extension UITextView {
    
    var string : String { // NeXTstep was right!
      set { text = newValue}
      get { return text }
    }

    var codeTextStorage : NSTextStorage? { return textStorage }
  }
#endif // iOS
