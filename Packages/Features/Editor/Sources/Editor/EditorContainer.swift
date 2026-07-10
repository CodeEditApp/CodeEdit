//
//  EditorContainer.swift
//  Editor
//
//  Created by Matthijs Eikelenboom on 10.07.26.
//

import Factory
import CodeEditDocument

extension Container {
    var languageServicesProvider: Factory<LanguageServicesProvider> {
        self { fatalError("languageServicesProvider not registered") }
    }
}
