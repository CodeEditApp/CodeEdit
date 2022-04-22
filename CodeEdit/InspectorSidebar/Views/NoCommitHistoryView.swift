//
//  NoCommitHistoryView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/04/19.
//

import SwiftUI

struct NoCommitHistoryView: View {
    var body: some View {
        VStack {
            Text("No History")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
    }
}

struct NoCommitHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NoCommitHistoryView()
    }
}
