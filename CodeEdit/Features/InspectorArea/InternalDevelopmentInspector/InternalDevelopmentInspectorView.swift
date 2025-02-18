import SwiftUI

struct InternalDevelopmentInspectorView: View {
    var body: some View {
        Form {
            Section("Test Notifications") {
                Button("Add Notification") {
                    let (iconSymbol, iconColor) = randomSymbolAndColor()
                    NotificationManager.shared.post(
                        iconSymbol: iconSymbol,
                        iconColor: iconColor,
                        title: "Test Notification",
                        description: "This is a test notification.",
                        actionButtonTitle: "Action",
                        action: {
                            print("Test notification action triggered")
                        }
                    )
                }
                Button("Add Sticky Notification") {
                    NotificationManager.shared.post(
                        iconSymbol: "pin.fill",
                        iconColor: .orange,
                        title: "Sticky Notification",
                        description: "This notification will stay until dismissed.",
                        actionButtonTitle: "Acknowledge",
                        action: {
                            print("Sticky notification acknowledged")
                        },
                        isSticky: true
                    )
                }
                Button("Add Image Notification") {
                    NotificationManager.shared.post(
                        iconImage: randomImage(),
                        title: "Test Notification with Image",
                        description: "This is a test notification with a custom image.",
                        actionButtonTitle: "Action",
                        action: {
                            print("Test notification action triggered")
                        }
                    )
                }
                Button("Add Text Notification") {
                    NotificationManager.shared.post(
                        iconText: randomLetter(),
                        iconTextColor: .white,
                        iconColor: randomColor(),
                        title: "Text Notification",
                        description: "This is a test notification with text.",
                        actionButtonTitle: "Acknowledge",
                        action: {
                            print("Test notification action triggered")
                        }
                    )
                }
                Button("Add Emoji Notification") {
                    NotificationManager.shared.post(
                        iconText: randomEmoji(),
                        iconTextColor: .white,
                        iconColor: randomColor(),
                        title: "Emoji Notification",
                        description: "This is a test notification with an emoji.",
                        actionButtonTitle: "Acknowledge",
                        action: {
                            print("Test notification action triggered")
                        }
                    )
                }
            }
        }
    }

    // Helper functions moved from FileInspectorView
    private func randomColor() -> Color {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, .mint, .cyan,
            .teal, .blue, .indigo, .purple, .pink, .gray
        ]
        return colors.randomElement() ?? .black
    }

    private func randomSymbolAndColor() -> (String, Color) {
        let symbols: [(String, Color)] = [
            ("bell.fill", .red),
            ("bell.badge.fill", .red),
            ("exclamationmark.triangle.fill", .orange),
            ("info.circle.fill", .blue),
            ("checkmark.seal.fill", .green),
            ("xmark.octagon.fill", .red),
            ("bubble.left.fill", .teal),
            ("envelope.fill", .blue),
            ("phone.fill", .green),
            ("megaphone.fill", .pink),
            ("clock.fill", .gray),
            ("calendar", .red),
            ("flag.fill", .green),
            ("bookmark.fill", .orange),
            ("bolt.fill", .indigo),
            ("shield.lefthalf.fill", .red),
            ("gift.fill", .purple),
            ("heart.fill", .pink),
            ("star.fill", .orange),
            ("curlybraces", .cyan),
        ]
        return symbols.randomElement() ?? ("bell.fill", .red)
    }

    private func randomEmoji() -> String {
        let emoji: [String] = [
            "🔔", "🚨", "⚠️", "👋", "😍", "😎", "😘", "😜", "😝", "😀", "😁",
            "😂", "🤣", "😃", "😄", "😅", "😆", "😇", "😉", "😊", "😋", "😌"
        ]
        return emoji.randomElement() ?? "🔔"
    }

    private func randomImage() -> Image {
        let images: [Image] = [
            Image("GitHubIcon"),
            Image("BitBucketIcon"),
            Image("GitLabIcon")
        ]
        return images.randomElement() ?? Image("GitHubIcon")
    }

    private func randomLetter() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }
        return letters.randomElement() ?? "A"
    }
}
