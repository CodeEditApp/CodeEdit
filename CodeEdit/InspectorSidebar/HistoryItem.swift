//
//  HistoryItem.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//

import SwiftUI

struct HistoryItem: View {

    var name: String
    var description: String
    var commitId: String
    var date: String

    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                Text(name)
                    .fontWeight(.bold)
                    .font(.system(size: 11))
                Spacer()
                Text(commitId)
                    .font(.system(size: 11))
                    .background(RoundedRectangle(cornerRadius: 3)
                        .padding(.trailing, -5)
                        .padding(.leading, -5)
                        .foregroundColor(Color("History Item")))
                    .padding(.trailing, 5)
            }

            HStack(alignment: .top) {
                Text(description)
                    .font(.system(size: 11))
                    .lineLimit(2)
                Spacer()
                Text(date)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }.frame(height: 30).padding(.top, -10)

            Divider().frame(maxWidth: 60).padding(.top, -3)

        }.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
    }
}

struct HistoryItem_Previews: PreviewProvider {
    static var previews: some View {
        HistoryItem(name: "Nanashi",
                    description: "A Random description for the commit",
                    commitId: "28bsc8",
                    date: "2022/03/24")
    }
}
