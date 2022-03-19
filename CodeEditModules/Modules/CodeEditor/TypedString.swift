//
//  TypedString.swift
//  CodeEditor
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * Simple helper to make typed strings.
 */
public protocol TypedString: RawRepresentable, Hashable, Comparable, Codable,
                             CustomStringConvertible,
                             Identifiable
{
  var rawValue: String { get }
}

public extension TypedString where RawValue == String {
  
  @inlinable
  var description : String { return self.rawValue }
  @inlinable
  var id          : String { return self.rawValue }

  @inlinable
  static func < (lhs: Self, rhs: Self) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}
