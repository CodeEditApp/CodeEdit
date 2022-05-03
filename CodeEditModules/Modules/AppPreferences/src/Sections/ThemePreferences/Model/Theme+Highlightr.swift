//
//  Theme+Highlightr.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 24.04.22.
//

import Foundation
import CodeEditUtils

public extension Theme {
    /// Returns a CSS string describing a highlight.js theme that represents the
    /// theme set in preferences.
    ///
    /// Reference for CSS stylable scopes can be found in
    /// [`highlightjs docs`](https://highlightjs.readthedocs.io/en/latest/css-classes-reference.html)
    var highlightrThemeString: String {
        let themeColors = editor
        let themeString = """
.hljs{
  display:block;
  overflow-x:auto;
  padding:0.5em;
  background:\(themeColors.background.color);
  color:\(themeColors.text.color)
}
.xml .hljs-meta {
  color:#c0c0c0
}
.hljs-keyword,.hljs-literal,.hljs-symbol {
  color:\(themeColors.keywords.color)
}
.hljs-built_in {
  color:\(themeColors.values.color)
}
.hljs-type {
  color:\(themeColors.types.color)
}
.hljs-class {
  color:\(themeColors.types.color)
}
.hljs-number {
  color:\(themeColors.numbers.color)
}
.hljs-string,.hljs-meta-string {
  color:\(themeColors.strings.color)
}
.hljs-property {
  color:\(themeColors.commands.color)
}
.hljs-variable,.hljs-template-variable {
  color:\(themeColors.variables.color)
}
.hljs-subst,.hljs-function,.hljs-title,.hljs-params,.hljs-formula{
  color:\(themeColors.variables.color)
}
.hljs-comment,.hljs-quote {
  color:\(themeColors.comments.color)
}
.hljs-doctag,.hljs-strong{
  font-weight:bold
}
.hljs-emphasis{
  font-style:italic
}
.hljs-tag {
  color:\(themeColors.text.color)
}
.hljs-attr,.hljs-attribute,.hljs-builtin-name{
  color:\(themeColors.attributes.color)
}
.hljs-meta {
  color:\(themeColors.keywords.color)
}
.hljs-code {
  color:\(themeColors.strings.color)
}
"""
        return themeString
            .removingNewLines()
            .removingSpaces()
    }
}
