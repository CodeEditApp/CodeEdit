import Foundation

enum TabWidth: Int, CaseIterable {
  case twoSpaces = 2
  case threeSpaces
  case fourSpaces
  case fiveSpaces
  case sixSpaces
  case sevenSpaces
  case eightSpaces

  static let `default`: TabWidth = .fourSpaces
  static let storageKey: String = "defaultTabWidth"
}

extension TabWidth: Identifiable {
  var id: Int { self.rawValue }
}
