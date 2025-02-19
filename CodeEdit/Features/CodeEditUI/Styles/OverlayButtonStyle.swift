import SwiftUI

/// A button style for overlay buttons (like close, action buttons in notifications)
struct OverlayButtonStyle: ButtonStyle {
    @Environment(\.isEnabled)
    private var isEnabled

    @Environment(\.controlActiveState)
    private var controlActive

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(
                isEnabled
                ? (configuration.isPressed
                   ? .primary.opacity(0.3)
                   : (controlActive == .inactive
                      ? .primary.opacity(0.5)
                      : .primary.opacity(0.7)))
                : .primary.opacity(0.3)
            )
            .padding(4)
            .contentShape(Rectangle())
    }
}

extension ButtonStyle where Self == OverlayButtonStyle {
    /// A button style for overlay buttons
    static var overlay: OverlayButtonStyle {
        OverlayButtonStyle()
    }
}
