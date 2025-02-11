struct FileInspector: View {
    var body: some View {
        List {
            Section("Testing") {
                Button("Test Notification (3s)") {
                    NotificationManager.shared.testNotification()
                }
                .buttonStyle(.borderless)
            }
        }
        .listStyle(.inset)
    }
} 