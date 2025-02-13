//
//  NotificationBannerView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 2/10/24.
//

import SwiftUI

struct NotificationBannerView: View {
    @Environment(\.colorScheme)
    private var colorScheme

    @ObservedObject private var notificationManager = NotificationManager.shared

    let notification: CENotification
    let onDismiss: () -> Void
    let onAction: () -> Void

    @State private var offset: CGFloat = 0
    @State private var opacity: CGFloat = 1
    @State private var isHovering = false

    private let dismissThreshold: CGFloat = 100

    let cornerRadius: CGFloat = 10

    private var backgroundContainer: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.regularMaterial)
    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(Color(nsColor: .separatorColor), lineWidth: 2)
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

    private var xOffset: CGFloat {
        if offset > 0 {
            return offset
        }
        if !notificationManager.isNotificationVisible(notification) && !notification.isBeingDismissed {
            return 350 // Width of banner + padding
        }
        return 0
    }

    var body: some View {
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
                .mask(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                .black,
                                .black,
                                !notification.isSticky && isHovering ? .clear : .black,
                                !notification.isSticky && isHovering ? .clear : .black
                            ]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
            if notification.isSticky {
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
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(10)
        .background(backgroundContainer)
        .overlay(borderOverlay)
        .cornerRadius(cornerRadius)
        .shadow(
            color: Color(.black.withAlphaComponent(colorScheme == .dark ? 0.2 : 0.1)),
            radius: 5,
            x: 0,
            y: 2
        )
        .overlay(alignment: .bottomTrailing) {
            if !notification.isSticky && isHovering {
                Button(action: onAction, label: {
                    Text(notification.actionButtonTitle)
                })
                .buttonStyle(.secondaryBlur)
                .controlSize(.small)
                .padding(10)
                .transition(.opacity)
            }
        }
        .overlay(alignment: .topLeading) {
            if !notification.isSticky && isHovering {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .frame(width: 20, height: 20, alignment: .center)
                        .background(.regularMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(nsColor: .separatorColor), lineWidth: 2)
                        )
                        .cornerRadius(10)
                        .shadow(
                            color: Color(.black.withAlphaComponent(colorScheme == .dark ? 0.2 : 0.1)),
                            radius: 5,
                            x: 0,
                            y: 2
                        )
                }
                .buttonStyle(.borderless)
                .padding(.top, -5)
                .padding(.leading, -5)
                .transition(.opacity)
            }
        }
        .frame(width: 300)
        .offset(x: xOffset)
        .opacity(opacity)
        .simultaneousGesture(dragGesture)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.2)) {
                isHovering = hovering
            }

            if hovering {
                NotificationManager.shared.pauseTimer()
            } else {
                NotificationManager.shared.resumeTimer()
            }
        }
    }
}
