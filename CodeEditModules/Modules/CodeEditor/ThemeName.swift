//
//  ThemeName.swift
//  CodeEditor
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

public extension CodeEditor {
    
    @frozen
    struct ThemeName: TypedString {
        
        public let rawValue : String
        
        @inlinable
        public init(rawValue: String) { self.rawValue = rawValue }
    }
}

public extension CodeEditor.ThemeName {
    
    static var `default` = pojoaque
    
    static var pojoaque   = CodeEditor.ThemeName(rawValue: "pojoaque")
    static var agate      = CodeEditor.ThemeName(rawValue: "agate")
    static var ocean      = CodeEditor.ThemeName(rawValue: "ocean")
    static var xcode      = CodeEditor.ThemeName(rawValue: "xcode")
    static var github     = CodeEditor.ThemeName(rawValue: "github")
    static var googlecode = CodeEditor.ThemeName(rawValue: "googlecode")
    static var vs         = CodeEditor.ThemeName(rawValue: "vs")
    
    static var atelierSavannaLight = CodeEditor.ThemeName(rawValue: "atelier-savanna-light")
    static var atelierSavannaDark = CodeEditor.ThemeName(rawValue: "atelier-savanna-dark")
}
