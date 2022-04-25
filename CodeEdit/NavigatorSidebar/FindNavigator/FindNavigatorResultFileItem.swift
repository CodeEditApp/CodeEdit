//
//  SearchResultFileItem.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/22.
//

import SwiftUI
import WorkspaceClient
import Search

struct FindNavigatorResultFileItem: View {
    @ObservedObject
    var state: WorkspaceDocument.SearchState

    @State
    var isExpanded: Bool = true

    var fileItem: WorkspaceClient.FileItem
    var results: [SearchResultModel]
    var jumpToFile: () -> Void

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(results, id: \.lineContent) { (result: SearchResultModel) in
                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 12))
                        .padding(.top, 2)
                    ResultView(lineContent: result.lineContent, keywordRange: result.keywordRange)
                        .lineLimit(Int.max)
                        .font(.system(size: 12, weight: .light))
                    Spacer()
                }
            }
        } label: {
            FileNameView(fileItem: fileItem, fileURL: state.workspace.fileURL)
        }
    }

    // MARK: - Subviews

    struct FileNameView: View {
        let fileItem: WorkspaceClient.FileItem
        let fileURL: URL?

        private var formattedFilePath: String {
            return fileItem.url.path.replacingOccurrences(of: fileURL?.path ?? "", with: "")
        }

        var body: some View {
            HStack {
                Image(systemName: fileItem.systemImage)
                Text(fileItem.fileName).font(.system(size: 13, weight: .semibold))
                + Text("  ")
                + Text(formattedFilePath).font(.system(size: 12, weight: .light))
                Spacer()
            }
        }
    }

    struct ResultView: View {

        let lineContent: String?
        let keywordRange: Range<String.Index>?

        var body: some View {
            if let lineContent = lineContent, let keywordRange = keywordRange {
                Text(lineContent[lineContent.startIndex..<keywordRange.lowerBound]) +
                Text(lineContent[keywordRange.lowerBound..<keywordRange.upperBound])
                    .font(.system(size: 12, weight: .bold)) +
                Text(lineContent[keywordRange.upperBound..<lineContent.endIndex])
            } else {
                EmptyView()
            }
        }
    }
}
