import SwiftUI

/// A view that displays Text with custom chevron up/down symbol
internal struct StatusBarMenuLabel: View {
    internal let text: String

    internal var body: some View {
        Text(text + " ") +
        Text(Image("custom.chevron.up.chevron.down"))
    }
}
