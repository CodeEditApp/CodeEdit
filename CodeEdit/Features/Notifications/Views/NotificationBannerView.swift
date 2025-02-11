//
//  NotificationBannerView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/10/24.
//

import SwiftUI

struct NotificationBannerView: View {
    @Environment(\.isOverlay)
    private var isOverlay

    @Environment(\.isSingleListItem)
    private var isSingleListItem

    let notification: CENotification
    let namespace: Namespace.ID
    let onDismiss: () -> Void
    let onAction: () -> Void

    @State private var offset: CGFloat = 0
    @State private var opacity: CGFloat = 1
    @State private var isHovering = false

    private let dismissThreshold: CGFloat = 100

    private var cornerRadius: CGFloat {
        isOverlay ? 10 : 6
    }

    private var shouldShowBackground: Bool {
        isOverlay || !isSingleListItem
    }

    private var content: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                switch notification.icon {
                case let .symbol(name, color):
                    FeatureIcon(
                        symbol: name,
                        color: color ?? Color(.systemBlue),
                        size: 26
                    )
                case let .text(text, backgroundColor, textColor):
                    FeatureIcon(
                        text: text,
                        textColor: textColor ?? .primary,
                        color: backgroundColor ?? Color(.systemBlue),
                        size: 26
                    )
                case let .image(image):
                    FeatureIcon(
                        image: image,
                        size: 26
                    )
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(notification.title)
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                        .padding(.top, -3)
                    Text(notification.description)
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(spacing: 8) {
                Button(action: onDismiss, label: {
                    Text("Dismiss")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(.secondaryBlur)
                .controlSize(.small)
                Button(action: onAction, label: {
                    Text(notification.actionButtonTitle)
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(.secondaryBlur)
                .controlSize(.small)
            }
        }
        .padding(10)
        .matchedGeometryEffect(id: "content-\(notification.id)", in: namespace)
    }

    private var backgroundContainer: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.regularMaterial)
            .matchedGeometryEffect(id: "background-\(notification.id)", in: namespace)
    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(Color(nsColor: .separatorColor), lineWidth: 2)
            .matchedGeometryEffect(id: "border-\(notification.id)", in: namespace)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                if value.translation.width > 0 {
                    offset = value.translation.width
                    opacity = 1 - (offset / dismissThreshold)
                }
            }
            .onEnded { value in
                let velocity = value.predictedEndLocation.x - value.location.x

                if offset > dismissThreshold || velocity > 100 {
                    withAnimation(.easeOut(duration: 0.2)) {
                        offset = NSScreen.main?.frame.width ?? 1000
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onDismiss()
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.2)) {
                        offset = 0
                        opacity = 1
                    }
                }
            }
    }

    var body: some View {
        VStack {
            if shouldShowBackground {
                content
                    .background(backgroundContainer)
                    .overlay(borderOverlay)
                    .cornerRadius(cornerRadius)
                    .shadow(
                        color: Color(.black.withAlphaComponent(0.2)),
                        radius: 5,
                        x: 0,
                        y: 2
                    )
            } else {
                content
            }
        }
        .frame(width: 300)
        .offset(x: offset)
        .opacity(opacity)
        .simultaneousGesture(dragGesture)
        .onHover { hovering in
            isHovering = hovering
            if hovering {
                NotificationManager.shared.pauseTimer()
            } else {
                NotificationManager.shared.resumeTimer()
            }
        }
    }
}
