//
//  UtilityAreaDebugView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI
import Combine

struct UtilityAreaDebugView: View {
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel
    @EnvironmentObject private var taskManager: TaskManager

    @State var tabSelection: UUID?
    @State var activeTasks: [CEActiveTask] = []

    @State private var scrollProxy: ScrollViewProxy?

    @Namespace var bottomID

    var body: some View {
        UtilityAreaTabView(model: utilityAreaViewModel.tabViewModel) { _ in
            if let tabSelection, !activeTasks.isEmpty {
                ScrollViewReader { proxy in
                    VStack {
                        HStack {
                            Button {
                                if let task = taskManager.activeTasks[tabSelection]?.task {
                                    taskManager.runTask(task: task)
                                }
                            } label: {
                                Image(systemName: "memories")
                                    .foregroundStyle(.green)
                            }.buttonStyle(.icon)

                            Button {
                                if let taskID = taskManager.activeTasks[tabSelection]?.task.id {
                                    taskManager.terminateTask(taskID: taskID)
                                }
                            } label: {
                                Image(systemName: "stop.fill")
                                    .foregroundStyle(.red)
                            }.buttonStyle(.icon)

                            Divider()

                            Button {
                                withAnimation {
                                    scrollProxy?.scrollTo(bottomID, anchor: .bottom)
                                }
                            } label: {
                                Image(systemName: "text.append")
                            }.buttonStyle(.icon)

                            Button {
                                Task {
                                    await taskManager.activeTasks[tabSelection]?.clearOutput()
                                }
                            } label: {
                                Image(systemName: "trash")
                            }.buttonStyle(.icon)

                            Spacer()
                        }
                        .padding(.horizontal, 5)
                        .padding(.top, 8)
                        .frame(maxHeight: 20)

                        Divider()

                        ScrollView {
                            VStack {
                                if taskManager.activeTasks[tabSelection] != nil {
                                    TaskOutputView(task: taskManager.activeTasks[tabSelection]!)
                                }

                                Rectangle()
                                    .frame(width: 1, height: 1)
                                    .foregroundStyle(.clear)
                                    .id(bottomID)

                            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        }
                        .onAppear {
                            withAnimation {
                                scrollProxy?.scrollTo(bottomID, anchor: .bottom)
                            }
                        }
                        Spacer()
                    }
                    .onAppear {
                        scrollProxy = proxy
                    }
                }
            } else {
                Text("Nothing to debug")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .paneToolbar {
                        EmptyView()
                    }
            }
        } leadingSidebar: { _ in
            if activeTasks.isEmpty {
                Text("No active tasks")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(selection: $tabSelection) {
                    ForEach(activeTasks, id: \.task.id) { task in
                        SidebarTaskTileView(task: task)
                    }
                }
                .listStyle(.automatic)
                .accentColor(.secondary)
//                .paneToolbar {
//                    Button {
//                        // add
//                    } label: {
//                        Image(systemName: "plus")
//                    }
//                    Button {
//                        // remove
//                    } label: {
//                        Image(systemName: "minus")
//                    }
//                }
            }
        }
        .onReceive(taskManager.$activeTasks) { activeTasks in
            self.activeTasks = Array(activeTasks.values)
        }
    }
}

struct SidebarTaskTileView: View {
    @ObservedObject var task: CEActiveTask
    var body: some View {
        HStack {
            Image(systemName: "gearshape")
                .imageScale(.medium)
            Text(task.task.name)
            Spacer()

            Circle()
                .fill(task.status.color)
                .frame(width: 5, height: 5)
        }
    }
}
struct TaskOutputView: View {
    @ObservedObject var task: CEActiveTask
    var body: some View {
        VStack(alignment: .leading) {
            Text(task.output)
                .fontDesign(.monospaced)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
    }
}
