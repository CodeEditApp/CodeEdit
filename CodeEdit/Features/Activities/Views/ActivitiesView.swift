//
//  ActivityView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 21.06.24.
//

import SwiftUI

struct ActivityView: View {
    @Environment(\.controlActiveState)
    private var activeState

    @ObservedObject var activityManager: ActivityManager
    @State private var isPresented: Bool = false
    @State var activity: CEActivity?

    var body: some View {
        ZStack {
            if let activity {
                HStack {
                    Text(activity.title)
                        .font(.subheadline)
                        .transition(
                            .asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom))
                            .combined(with: .opacity)
                        )
                        .id("ActivityTitle" + activity.title)

                    if activity.isLoading {
                        CECircularProgressView(
                            progress: activity.percentage,
                            currentTaskCount: activityManager.activities.count
                        )
                        .padding(.horizontal, -1)
                        .frame(height: 16)
                    } else {
                        if activityManager.activities.count > 1 {
                            Text("\(activityManager.activities.count)")
                                .font(.caption)
                                .padding(5)
                                .background(
                                    Circle()
                                        .foregroundStyle(.gray)
                                        .opacity(0.2)
                                )
                                .padding(-5)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
                .opacity(activeState == .inactive ? 0.4 : 1.0)
                .padding(3)
                .padding(-3)
                .padding(.trailing, 3)
                .popover(isPresented: $isPresented, arrowEdge: .bottom) {
                    ActivitysDetailView(activityManager: activityManager)
                }
                .onTapGesture {
                    self.isPresented.toggle()
                }
            }
        }
        .animation(.easeInOut, value: activity)
        .onChange(of: activityManager.activities) { newValue in
            withAnimation {
                activity = newValue.first
            }
        }
    }

}

#Preview {
    ActivityView(activityManager: ActivityManager())
}
