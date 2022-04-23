//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 24.04.22.
//

import Foundation

public extension Theme {
    var highlightrThemeString: String {
        let themeColors = editor
        return """
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
.hljs-keyword,.hljs-literal,.hljs-symbol,.hljs-name {
 color:\(themeColors.keywords.color)
}
.hljs-built_in,.hljs-type {
 color:\(themeColors.types.color)
}
.hljs-number {
  color:\(themeColors.numbers.color)
}
.hljs-string,.hljs-meta-string {
  color:\(themeColors.strings.color)
}
.hljs-variable, .hljs-template-variable {
 color:\(themeColors.variables.color)
}
.hljs-title {
 color:\(themeColors.variables.color)
}
.hljs-params {
 color:\(themeColors.values.color)
}
.hljs-comment, .hljs-quote {
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
""".replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
    }
}
