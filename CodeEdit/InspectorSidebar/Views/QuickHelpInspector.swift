//
//  QuickHelpInspector.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI

struct QuickHelpInspector: View {
    var body: some View {
        VStack(alignment: .leading) {

            Text("Quick Help")
                .foregroundColor(.secondary)
                .fontWeight(.bold)
                .font(.system(size: 13))
                .frame(width: 250, alignment: .leading)

            Text("No Quick Help")
                .foregroundColor(.secondary)
                .font(.system(size: 16))
                .fontWeight(.medium)
                .frame(width: 250, alignment: .center)
                .padding(.top, 10)
                .padding(.bottom, 10)

            Button("Search Documentation") {

            }.background(in: RoundedRectangle(cornerRadius: 4))
                .frame(width: 250, alignment: .center)
                .font(.system(size: 12))

            Divider().padding(.top, 15)

        }.frame(maxWidth: 250).padding(5)
    }
}

struct QuickHelpInspector_Previews: PreviewProvider {
    static var previews: some View {
        QuickHelpInspector()
    }
}
