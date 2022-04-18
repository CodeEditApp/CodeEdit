//
//  HistoryItem.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI
import GitClient

struct HistoryItem: View {

    var commit: Commit

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }

    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                Text(commit.author)
                    .fontWeight(.bold)
                    .font(.system(size: 11))
                Spacer()
                Text(commit.hash)
                    .font(.system(size: 10))
                    .background(RoundedRectangle(cornerRadius: 3)
                        .padding(.trailing, -5)
                        .padding(.leading, -5)
                        .foregroundColor(Color("HistoryInspectorHash")))
                    .padding(.trailing, 5)
            }

            HStack(alignment: .top) {
                Text(commit.message)
                    .font(.system(size: 11))
                    .lineLimit(2)
                Spacer()
                Text(dateFormatter.string(from: commit.date))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .frame(height: 30).padding(.top, -8)

            Divider().frame(maxWidth: 60).padding(.top, -3)

        }
        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
    }
}
