import SwiftUI

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

struct EffectView: View {
    private let material: Material
    private let blendingMode: BlendingMode
    private let emphasized: Bool

    init(
        _ material: Material = .headerView,
        blendingMode: BlendingMode = .withinWindow,
        emphasized: Bool = false
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.emphasized = emphasized
    }

    var body: some View {
        #if os(macOS)
        NSViewEffectWrapper(material: material.nsMaterial, blendingMode: blendingMode.nsBlendingMode, emphasized: emphasized)
        #elseif os(iOS)
        UIViewEffectWrapper(style: material.uiBlurEffectStyle, emphasized: emphasized)
        #endif
    }

    // Mapping enum for multiplatform support
    enum Material {
        case headerView, selection, underWindowBackground
        
        #if os(macOS)
        var nsMaterial: NSVisualEffectView.Material {
            switch self {
            case .headerView: return .headerView
            case .selection: return .selection
            case .underWindowBackground: return .underWindowBackground
            }
        }
        #elseif os(iOS)
        var uiBlurEffectStyle: UIBlurEffect.Style {
            switch self {
            case .headerView, .underWindowBackground: return .systemMaterial
            case .selection: return .dark // TODO: Example mapping, adjust as needed
            }
        }
        #endif
    }

    enum BlendingMode {
        case withinWindow, behindWindow

        #if os(macOS)
        var nsBlendingMode: NSVisualEffectView.BlendingMode {
            // macOS specific mapping
            switch self {
            case .withinWindow: return .withinWindow
            case .behindWindow: return .behindWindow
            }
        }
        #endif
    }

    #if os(macOS)
    // macOS specific wrapper
    struct NSViewEffectWrapper: NSViewRepresentable {
        var material: NSVisualEffectView.Material
        var blendingMode: NSVisualEffectView.BlendingMode
        var emphasized: Bool

        func makeNSView(context: Context) -> NSVisualEffectView {
            let view = NSVisualEffectView()
            view.material = material
            view.blendingMode = blendingMode
            view.isEmphasized = emphasized
            view.state = .followsWindowActiveState
            return view
        }

        func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
            nsView.material = material
            nsView.blendingMode = blendingMode
            nsView.isEmphasized = emphasized
        }
    }
    #elseif os(iOS)
    // iOS specific wrapper
    struct UIViewEffectWrapper: UIViewRepresentable {
        var style: UIBlurEffect.Style
        var emphasized: Bool // This might be used to adjust the effect based on context
        
        func makeUIView(context: Context) -> UIVisualEffectView {
            let effect = UIBlurEffect(style: style)
            return UIVisualEffectView(effect: effect)
        }

        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
            uiView.effect = UIBlurEffect(style: style)
        }
    }
    #endif
}

extension EffectView {
    /// Returns the system selection style as an ``EffectView`` if the `condition` is met.
    /// Otherwise it returns `Color.clear`
    ///
    /// - Parameter condition: The condition of when to apply the background. Defaults to `true`.
    /// - Returns: A View
    @ViewBuilder
    static func selectionBackground(_ condition: Bool = true) -> some View {
        if condition {
            EffectView(.selection, blendingMode: .withinWindow, emphasized: true)
        } else {
            Color.clear
        }
    }
}
