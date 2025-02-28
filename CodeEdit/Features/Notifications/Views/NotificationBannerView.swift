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

    @EnvironmentObject private var workspace: WorkspaceDocument
    @ObservedObject private var notificationManager = NotificationManager.shared

    let notification: CENotification
    let onDismiss: () -> Void
    let onAction: () -> Void

    @State private var isHovering = false

    let cornerRadius: CGFloat = 10

    private var backgroundContainer: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.regularMaterial)
    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(Color(nsColor: .separatorColor), lineWidth: 2)
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
                }
                .buttonStyle(.overlay)
                .padding(.top, -5)
                .padding(.leading, -5)
                .transition(.opacity)
            }
        }
        .frame(width: 300)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .modifier(
                active: DismissTransition(
                    useOpactityTransition: notification.isBeingDismissed,
                    isIdentity: false
                ),
                identity: DismissTransition(
                    useOpactityTransition: notification.isBeingDismissed,
                    isIdentity: true
                )
            )
        ))
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.2)) {
                isHovering = hovering
            }

            if hovering {
                workspace.notificationPanel.pauseTimer()
            } else {
                workspace.notificationPanel.resumeTimer()
            }
        }
    }
}

struct DismissTransition: ViewModifier {
    let useOpactityTransition: Bool
    let isIdentity: Bool

    func body(content: Content) -> some View {
        content
            .opacity(useOpactityTransition && !isIdentity ? 0 : 1)
            .offset(x: !useOpactityTransition && !isIdentity ? 350 : 0)
    }
}
