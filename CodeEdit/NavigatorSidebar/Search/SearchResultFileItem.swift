//
//  SearchResultFileItem.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import SwiftUI
import WorkspaceClient

struct SearchResultFileItem: View {
    @ObservedObject var state: WorkspaceDocument.SearchState
    @State var isExpanded: Bool = true
    var fileItem: WorkspaceClient.FileItem
    var results: [SearchResultModel]
    var jumpToFile: () -> Void

    private func foundLineResult(_ lineContent: String?, keywordRange: Range<String.Index>?) -> some View {
        guard let lineContent = lineContent, let keywordRange = keywordRange else {
            return AnyView(EmptyView())
        }
        return AnyView(
            Text(lineContent[lineContent.startIndex..<keywordRange.lowerBound]) +
            Text(lineContent[keywordRange.lowerBound..<keywordRange.upperBound])
                .foregroundColor(.white)
                .font(.system(size: 12, weight: .bold)) +
            Text(lineContent[keywordRange.upperBound..<lineContent.endIndex])
        )
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(results, id: \.lineContent) { (result: SearchResultModel) in
                HStack(alignment: .top) {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 12))
                        .padding(.top, 2)
                    foundLineResult(result.lineContent, keywordRange: result.keywordRange)
                        .lineLimit(Int.max)
                        .foregroundColor(Color(nsColor: .secondaryLabelColor))
                        .font(.system(size: 12, weight: .light))
                    Spacer()
                }
                .padding(.leading, 15)
            }
        } label: {
            HStack {
                Image(systemName: fileItem.fileIcon)
                Text(fileItem.fileName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(nsColor: NSColor.headerTextColor))
                Text(fileItem.url.path.replacingOccurrences(of: state.workspace.fileURL?.path ?? "", with: ""))
                Spacer()
            }
        }
    }
}
