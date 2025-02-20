//
//  ActivitysDetailView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.06.24.
//

import SwiftUI

struct ActivitysDetailView: View {
    @ObservedObject var activityManager: ActivityManager
    @State private var selectedActivityIndex: Int = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                ForEach(activityManager.activities, id: \.id) { activity in
                    HStack(alignment: .center, spacing: 8) {
                        CECircularProgressView(progress: activity.percentage)
                            .frame(width: 16, height: 16)
                        VStack(alignment: .leading) {
                            Text(activity.title)
                                .fixedSize(horizontal: false, vertical: true)
                                .transition(.identity)

                            if let message = activity.message, !message.isEmpty {
                                Text(message)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding(15)
        .frame(minWidth: 320)
        .onChange(of: activityManager.activities) { newValue in
            if selectedActivityIndex >= newValue.count {
                selectedActivityIndex = 0
            }
        }
    }
}

#Preview {
    ActivitysDetailView(activityManager: ActivityManager())
}
