import SwiftUI

struct DismissTransition: ViewModifier {
    let useOpactityTransition: Bool
    let isIdentity: Bool

    func body(content: Content) -> some View {
        content
            .opacity(useOpactityTransition ? (isIdentity ? 1 : 0) : 1)
            .offset(x: useOpactityTransition ? 0 : (isIdentity ? 0 : 350))
    }
}
