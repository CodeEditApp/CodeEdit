//
//  UtilityAreaDebugView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI

struct UtilityAreaDebugView: View {
    @AppSettings(\.theme.matchAppearance)
    private var matchAppearance
    @AppSettings(\.terminal.darkAppearance)
    private var darkAppearance
    @AppSettings(\.theme.useThemeBackground)
    private var useThemeBackground

    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel
    @EnvironmentObject private var taskManager: TaskManager

    @State private var scrollProxy: ScrollViewProxy?

    @StateObject private var themeModel: ThemeModel = .shared

    @Namespace var bottomID

    var body: some View {
        UtilityAreaTabView(model: utilityAreaViewModel.tabViewModel) { _ in
            ZStack {
                HStack {
                    Spacer()
                    Text("No Task Selected")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Spacer()
                }
                .opacity(taskManager.taskShowingOutput == nil ? 1 : 0)

                if let taskShowingOutput = taskManager.taskShowingOutput,
                   let activeTask = taskManager.activeTasks[taskShowingOutput] {
                    ScrollViewReader { proxy in
                        VStack {
                            ScrollView {
                                VStack {
                                    TaskOutputView(activeTask: activeTask)

                                    Rectangle()
                                        .frame(width: 1, height: 1)
                                        .foregroundStyle(.clear)
                                        .id(bottomID)

                                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            }.animation(.default, value: bottomID)
                                .onAppear {
                                    // assign proxy to scrollProxy in order
                                    // to use the button to scroll down and scroll down on reappear
                                    scrollProxy = proxy
                                    scrollProxy?.scrollTo(bottomID, anchor: .bottom)
                                }
                            Spacer()
                        }
                        .onReceive(activeTask.$output, perform: { _ in
                            proxy.scrollTo(bottomID)
                        })
                    }
                    .paneToolbar {
                        TaskOutputActionsView(
                            activeTask: activeTask,
                            taskManager: taskManager,
                            scrollProxy: $scrollProxy,
                            bottomID: _bottomID
                        )
                    }
                    .background {
                        if utilityAreaViewModel.selectedTerminals.isEmpty {
                            EffectView(.contentBackground)
                        } else if useThemeBackground {
                            Color(nsColor: backgroundColor)
                        } else {
                            if colorScheme == .dark {
                                EffectView(.underPageBackground)
                            } else {
                                EffectView(.contentBackground)
                            }
                        }
                    }
                    .colorScheme(
                        utilityAreaViewModel.selectedTerminals.isEmpty
                            ? colorScheme
                            : matchAppearance && darkAppearance
                            ? themeModel.selectedDarkTheme?.appearance == .dark ? .dark : .light
                            : themeModel.selectedTheme?.appearance == .dark ? .dark : .light
                    )
                }
            }
        } leadingSidebar: { _ in
            ZStack {
                Text("No Tasks are Running")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(taskManager.activeTasks.isEmpty ? 1 : 0)

                List(selection: $taskManager.taskShowingOutput) {
                    ForEach(Array(taskManager.activeTasks.keys), id: \.self) { taskID in
                        if let activeTask = taskManager.activeTasks[taskID] {
                            ActiveTaskView(activeTask: activeTask)
                                .onTapGesture {
                                    taskManager.taskShowingOutput = taskID
                                }
                                .contextMenu(
                                    ContextMenu {
                                        Button {
                                            taskManager.deleteTask(taskID: taskID)
                                        } label: {
                                            Text("Delete")
                                        }
                                    }
                                )
                        }
                    }
                }
                .listStyle(.automatic)
                .accentColor(.secondary)
                .paneToolbar { Spacer() } // Background
            }
        }.onReceive(taskManager.$activeTasks) { newTasks in
            if taskManager.taskShowingOutput == nil {
                taskManager.taskShowingOutput = newTasks.first?.key
            }
        }
    }

    /// Returns the `background` color of the selected theme
    private var backgroundColor: NSColor {
        if let selectedTheme = matchAppearance && darkAppearance
            ? themeModel.selectedDarkTheme
            : themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.background.swiftColor)
        }
        return .windowBackgroundColor
    }
}
