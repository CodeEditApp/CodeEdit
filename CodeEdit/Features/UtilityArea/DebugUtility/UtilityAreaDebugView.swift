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

    @AppSettings(\.textEditing.font)
    private var textEditingFont
    @AppSettings(\.terminal.font)
    private var terminalFont
    @AppSettings(\.terminal.useTextEditorFont)
    private var useTextEditorFont

    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel
    @EnvironmentObject private var taskManager: TaskManager

    @State private var scrollProxy: ScrollViewProxy?

    @StateObject private var themeModel: ThemeModel = .shared

    @Namespace var bottomID

    var font: NSFont {
        useTextEditorFont == true ? textEditingFont.current : terminalFont.current
    }

    var body: some View {
        UtilityAreaTabView(model: utilityAreaViewModel.tabViewModel) { _ in
            ZStack {
                HStack { Spacer() }

                if let taskShowingOutput = taskManager.taskShowingOutput,
                   let activeTask = taskManager.activeTasks[taskShowingOutput] {
                    GeometryReader { geometry in
                        let containerHeight = geometry.size.height
                        let totalFontHeight = fontTotalHeight(nsFont: font).rounded(.up)
                        let constrainedHeight = containerHeight - containerHeight.truncatingRemainder(
                            dividingBy: totalFontHeight
                        )
                        VStack(spacing: 0) {
                            Spacer(minLength: 0).frame(minHeight: 0)

                            TaskOutputView(activeTask: activeTask)
                                .frame(height: max(0, constrainedHeight - 1))
                                .id(activeTask.task.id)
                                .padding(.horizontal, 10)
                        }
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
                } else {
                    CEContentUnavailableView("No Task Selected")
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

    /// Estimate the font's height for keeping the terminal aligned with the bottom.
    /// - Parameter nsFont: The font being used in the terminal.
    /// - Returns: The height in pixels of the font.
    private func fontTotalHeight(nsFont: NSFont) -> CGFloat {
        let ctFont = nsFont as CTFont
        let ascent = CTFontGetAscent(ctFont)
        let descent = CTFontGetDescent(ctFont)
        let leading = CTFontGetLeading(ctFont)
        return ascent + descent + leading
    }
}
