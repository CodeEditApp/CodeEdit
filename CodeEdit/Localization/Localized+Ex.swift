import SwiftUI

extension String {
    func localized(_ custom: String? = nil) -> LocalizedStringKey {
        if let custom = custom {
            return LocalizedStringKey(custom)
        } else {
            return LocalizedStringKey(self)
        }
    }
}

extension LocalizedStringKey {
    static let helloWorld = "Hello, world!".localized()
}
