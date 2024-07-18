//
//  UtilityAreaDebugView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI

struct UtilityAreaDebugView: View {
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel
    @EnvironmentObject private var taskManager: TaskManager

    @State var tabSelection: UUID?
    @State private var scrollProxy: ScrollViewProxy?

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
                .opacity(tabSelection == nil ? 1 : 0)

                if let tabSelection,
                   let activeTask = taskManager.activeTasks[tabSelection] {
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
                    .background(EffectView(.contentBackground))
                }
            }
        } leadingSidebar: { _ in
            ZStack {
                Text("No Tasks are Running")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(taskManager.activeTasks.isEmpty ? 1 : 0)

                List(selection: $tabSelection) {
                    ForEach(Array(taskManager.activeTasks.keys), id: \.self) { taskID in
                        if let activeTask = taskManager.activeTasks[taskID] {
                            TaskSidebarTileView(activeTask: activeTask)
                                .onTapGesture {
                                    withAnimation {
                                        self.tabSelection = taskID
                                    }
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
            if tabSelection == nil {
                self.tabSelection = newTasks.first?.key
            }
        }
    }
}
