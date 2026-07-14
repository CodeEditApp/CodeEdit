//
//  RegistryItem+FuzzySearchable.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/07/2026.
//

import CELSP
import CodeEditCore

extension RegistryItem: FuzzySearchable {
    public var searchableString: String { name }
}
