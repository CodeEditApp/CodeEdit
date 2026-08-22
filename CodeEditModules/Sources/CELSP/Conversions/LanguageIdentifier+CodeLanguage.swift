//
//  LanguageIdentifier+CodeLanguage.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/9/24.
//

import LanguageServerProtocol
import CodeEditLanguages

extension CodeLanguage {
    var lspLanguage: LanguageIdentifier? {
        switch self.id {
        case .agda,
                .bash,
                .haskell,
                .julia,
                .kotlin,
                .ocaml,
                .ocamlInterface,
                .regex,
                .toml,
                .verilog,
                .zig,
                .plainText:
            return nil
        case .c:
            return .c
        case .cpp:
            return .cpp
        case .cSharp:
            return .csharp
        case .css:
            return .css
        case .dart:
            return .dart
        case .dockerfile:
            return .dockerfile
        case .elixir:
            return .elixir
        case .go, .goMod:
            return  .go
        case .html:
            return .html
        case .java:
            return .java
        case .javascript, .jsdoc:
            return .javascript
        case .json:
            return .json
        case .jsx:
            return .javascriptreact
        case .lua:
            return .lua
        case .markdown, .markdownInline:
            return .markdown
        case .objc:
            return .objc
        case .perl:
            return .perl
        case .php:
            return .php
        case .python:
            return .python
        case .ruby:
            return .ruby
        case .rust:
            return .rust
        case .scala:
            return .scala
        case .sql:
            return .sql
        case .swift:
            return .swift
        case .tsx:
            return .typescriptreact
        case .typescript:
            return .typescript
        case .yaml:
            return .yaml
        }
    }
}
