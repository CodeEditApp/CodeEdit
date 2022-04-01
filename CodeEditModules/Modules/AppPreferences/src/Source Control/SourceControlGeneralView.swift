//
//  SourceControlGeneralView.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct SourceControlGeneralView: View {

    @State var isChecked: Bool
    @State var branchName: String

    var body: some View {
        VStack {
            // Source Control
            HStack(alignment: .top) {
                Text("Source Control:")
                VStack(alignment: .leading) {
                    Toggle("Enable Source Control", isOn: $isChecked)
                        .toggleStyle(.checkbox)

                    VStack(alignment: .leading) {
                        Toggle("Refresh local status automatically", isOn: $isChecked)
                            .toggleStyle(.checkbox)
                        Toggle("Fetch and refresh server status automatically", isOn: $isChecked)
                            .toggleStyle(.checkbox)
                        Toggle("Add and remove files automatically", isOn: $isChecked)
                            .toggleStyle(.checkbox)
                        Toggle("Select files to commit automatically", isOn: $isChecked)
                            .toggleStyle(.checkbox)
                    }.padding(.leading, 20)
                }
            }.padding(.trailing, 15)

            HStack(alignment: .top) {
                Text("Text Editing:")
                VStack(alignment: .leading) {
                    Toggle("Show Source Control chnages", isOn: $isChecked)
                        .toggleStyle(.checkbox)

                    Toggle("Include upstream changes", isOn: $isChecked)
                        .toggleStyle(.checkbox)
                        .padding(.leading, 20)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            .padding(.trailing, 105)

            HStack(alignment: .top) {
                VStack(alignment: .trailing) {
                    Text("Comparison View:")
                    Text("Source Control Navigator:")
                        .padding(.top, 2)
                    Text("Default Branch Name:")
                        .padding(.top, 2)
                }

                VStack(alignment: .leading) {
                    Menu {
                        Button("Comparison") {}
                    } label: {
                        Text("Local Revision on Left Side")
                            .font(.system(size: 11))
                    }.frame(maxWidth: 170)
                    Menu {
                        Button("Control Navigator") {}
                    } label: {
                        Text("Sort by Name")
                            .font(.system(size: 11))
                    }.frame(maxWidth: 170)
                    VStack(alignment: .leading) {
                        TextField("Text", text: $branchName)
                            .frame(width: 170)
                        Text("Branch names cannot contain spaces, backslashes, or other symbols")
                            .font(.system(size: 12))
                    }
                }
            }.padding(.top, 10)
        }
        .frame(width: 844, height: 350)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct SourceControlGeneralView_Previews: PreviewProvider {
    static var previews: some View {
        SourceControlGeneralView(isChecked: true, branchName: "main")
    }
}
