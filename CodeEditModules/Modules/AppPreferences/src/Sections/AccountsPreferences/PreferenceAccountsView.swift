//
//  PreferenceAccountsView.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

public struct PreferenceAccountsView: View {

    @State private var useHHTP = false

    public init() {}

    public var body: some View {
        VStack {
            HStack(alignment: .top) {
                AccountSelectionView()
                Divider().padding([.leading, .trailing], -10)
                AccountTypeView(useHTTP: false, useSSH: true)
            }
            .background(Rectangle().foregroundColor(Color(NSColor.controlBackgroundColor)))
            .padding([.top, .bottom], 15)
            .frame(height: 468)
        }
        .frame(width: 872)
    }
}

struct PreferenceAccountsView_Previews: PreviewProvider {
    static var previews: some View {
        PreferenceAccountsView().preferredColorScheme(.dark)
    }
}
