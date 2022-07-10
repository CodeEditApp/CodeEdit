//
//  OtherFileView.swift
//  
//
//  Created by Shibo Tong on 10/7/2022.
//

import SwiftUI
import QuickLookUI

/// A SwiftUI Wrapper for `QLPreviewView`
/// Mainly used for other unsupported files
/// ## Usage
/// ```swift
/// OtherFileView(otherFile)
/// ```
public struct OtherFileView: NSViewRepresentable {

    @ObservedObject
    private var otherFile: CodeFileDocument

    /// Initialize the OtherFileView
    /// - Parameter otherFile: a file which contains URL to show preview
    public init(
        _ otherFile: CodeFileDocument
    ) {
        self.otherFile = otherFile
    }

    public func makeNSView(context: Context) -> QLPreviewView {
        let qlPreviewView = QLPreviewView()
        qlPreviewView.previewItem = otherFile
        return qlPreviewView
    }

    public func updateNSView(_ nsView: QLPreviewView, context: Context) {
        
    }
}
