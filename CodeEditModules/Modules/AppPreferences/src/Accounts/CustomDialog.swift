//
//  CustomDialog.swift
//  
//
//  Created by Tihan-Nico Paxton on 2022/04/01.
//

import SwiftUI

struct CustomDialog<DialogContent: View>: ViewModifier {
    @Binding var isShowing: Bool
    let cancelOnTapOutside: Bool
    let cancelAction: (() -> Void)?
    let dialogContent: DialogContent

    public init(isShowing: Binding<Bool>,
                cancelOnTapOutside: Bool,
                cancelAction: (() -> Void)?,
                @ViewBuilder dialogContent: () -> DialogContent) {
        _isShowing = isShowing
        self.cancelOnTapOutside = cancelOnTapOutside
        self.cancelAction = cancelAction
        self.dialogContent = dialogContent()
    }

    public func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                Rectangle()
                    .foregroundColor(Color.black.opacity(0.6))
                    .onTapGesture {
                        if cancelOnTapOutside {
                            cancelAction?()
                            isShowing = false
                        }
                    }
                ZStack {
                    dialogContent
                }.padding(40)
            }
        }
    }
}

public extension View {
    func customDialog<DialogContent: View>(isShowing: Binding<Bool>,
                                           cancelOnTapOutside: Bool = true,
                                           cancelAction: (() -> Void)? = nil,
                                           @ViewBuilder dialogContent: @escaping () -> DialogContent) -> some View {
        self.modifier(CustomDialog(isShowing: isShowing,
                                   cancelOnTapOutside: cancelOnTapOutside,
                                   cancelAction: cancelAction,
                                   dialogContent: dialogContent))
    }

}
