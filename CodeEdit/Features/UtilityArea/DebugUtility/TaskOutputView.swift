//
//  TaskOutputView.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 27.06.24.
//

import SwiftUI

struct TaskOutputView: View {
    @ObservedObject var activeTask: CEActiveTask
    var body: some View {
        VStack(alignment: .leading) {
            Text(activeTask.output)
                .fontDesign(.monospaced)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(10)
    }
}
