//
//  Language.swift
//  CodeEditor
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

public extension CodeEditor {
    
    @frozen
    struct Language: TypedString {
        
        public let rawValue : String
        
        @inlinable
        public init(rawValue: String) { self.rawValue = rawValue }
    }
}

public extension CodeEditor.Language {
    
    static var accesslog    = CodeEditor.Language(rawValue: "accesslog")
    static var actionscript = CodeEditor.Language(rawValue: "actionscript")
    static var ada          = CodeEditor.Language(rawValue: "ada")
    static var apache       = CodeEditor.Language(rawValue: "apache")
    static var applescript  = CodeEditor.Language(rawValue: "applescript")
    static var bash         = CodeEditor.Language(rawValue: "bash")
    static var basic        = CodeEditor.Language(rawValue: "basic")
    static var brainfuck    = CodeEditor.Language(rawValue: "brainfuck")
    static var c            = CodeEditor.Language(rawValue: "c")
    static var clojure      = CodeEditor.Language(rawValue: "clojure")
    static var coffeescript = CodeEditor.Language(rawValue: "coffeescript")
    static var cmake        = CodeEditor.Language(rawValue: "cmake")
    static var cpp          = CodeEditor.Language(rawValue: "cpp")
    static var cs           = CodeEditor.Language(rawValue: "cs")
    static var css          = CodeEditor.Language(rawValue: "css")
    static var diff         = CodeEditor.Language(rawValue: "diff")
    static var delphi       = CodeEditor.Language(rawValue: "delphi")
    static var django       = CodeEditor.Language(rawValue: "django")
    static var dockerfile   = CodeEditor.Language(rawValue: "dockerfile")
    static var fsharp       = CodeEditor.Language(rawValue: "fsharp")
    static var dart         = CodeEditor.Language(rawValue: "dart")
    static var go           = CodeEditor.Language(rawValue: "go")
    static var gradle       = CodeEditor.Language(rawValue: "gradle")
    static var groovy       = CodeEditor.Language(rawValue: "groovy")
    static var http         = CodeEditor.Language(rawValue: "http")
    static var java         = CodeEditor.Language(rawValue: "java")
    static var javascript   = CodeEditor.Language(rawValue: "javascript")
    static var json         = CodeEditor.Language(rawValue: "json")
    static var lua          = CodeEditor.Language(rawValue: "lua")
    static var markdown     = CodeEditor.Language(rawValue: "markdown")
    static var makefile     = CodeEditor.Language(rawValue: "makefile")
    static var mathematica  = CodeEditor.Language(rawValue: "mathematica")
    static var matlab       = CodeEditor.Language(rawValue: "matlab")
    static var nginx        = CodeEditor.Language(rawValue: "nginx")
    static var objectivec   = CodeEditor.Language(rawValue: "objectivec")
    static var perl         = CodeEditor.Language(rawValue: "perl")
    static var pgsql        = CodeEditor.Language(rawValue: "pgsql")
    static var php          = CodeEditor.Language(rawValue: "php")
    static var python       = CodeEditor.Language(rawValue: "python")
    static var protobuf     = CodeEditor.Language(rawValue: "protobuf")
    static var ruby         = CodeEditor.Language(rawValue: "ruby")
    static var rust         = CodeEditor.Language(rawValue: "rust")
    static var scala        = CodeEditor.Language(rawValue: "scala")
    static var scss         = CodeEditor.Language(rawValue: "scss")
    static var shell        = CodeEditor.Language(rawValue: "shell")
    static var smalltalk    = CodeEditor.Language(rawValue: "smalltalk")
    static var sql          = CodeEditor.Language(rawValue: "sql")
    static var swift        = CodeEditor.Language(rawValue: "swift")
    static var tcl          = CodeEditor.Language(rawValue: "tcl")
    static var tex          = CodeEditor.Language(rawValue: "tex")
    static var twig         = CodeEditor.Language(rawValue: "twig")
    static var typescript   = CodeEditor.Language(rawValue: "typescript")
    static var vbnet        = CodeEditor.Language(rawValue: "vbnet")
    static var vbscript     = CodeEditor.Language(rawValue: "vbscript")
    static var xml          = CodeEditor.Language(rawValue: "xml")
    static var yaml         = CodeEditor.Language(rawValue: "yaml")
}
