//
//  DiagnosticsManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/15/25.
//

import Combine
import SwiftUI
import Foundation
import LanguageServerProtocol

class DiagnosticsManager: ObservableObject {
    @Published var rootNode: ProjectIssueNode?
    @Published var filterOptions = IssueFilterOptions()
    @Published private(set) var filteredRootNode: ProjectIssueNode?

    let diagnosticsDidChangePublisher = PassthroughSubject<Void, Never>()

    private var fileNodesByUri: [DocumentUri: FileIssueNode] = [:]
    private var expandedFileUris: Set<DocumentUri> = []

    func initialize(projectName: String) {
        self.rootNode = ProjectIssueNode(name: projectName)
        self.filteredRootNode = ProjectIssueNode(name: projectName)
    }

    func updateDiagnostics(params: PublishDiagnosticsParams) {
        let uri = params.uri
        let diagnostics = params.diagnostics

        if diagnostics.isEmpty {
            // Remove the file node if no diagnostics
            fileNodesByUri.removeValue(forKey: uri)
            expandedFileUris.remove(uri)
        } else {
            // Get or create file node
            let fileNode: FileIssueNode
            if let existingNode = fileNodesByUri[uri] {
                fileNode = existingNode
                fileNode.diagnostics.removeAll(keepingCapacity: true)
            } else {
                // Create new file node
                let fileName = getFileName(from: uri)
                fileNode = FileIssueNode(uri: uri, name: fileName)
                fileNodesByUri[uri] = fileNode
            }

            // Convert diagnostics to diagnostic nodes and add to file node
            let diagnosticNodes = diagnostics.map { diagnostic in
                DiagnosticIssueNode(diagnostic: diagnostic, fileUri: uri)
            }

            // Sort diagnostics by severity and line number
            let sortedDiagnosticNodes = diagnosticNodes.sorted { node1, node2 in
                let severity1 = node1.diagnostic.severity?.rawValue ?? Int.max
                let severity2 = node2.diagnostic.severity?.rawValue ?? Int.max

                if severity1 == severity2 {
                    // If same severity, sort by line number
                    return node1.diagnostic.range.start.line < node2.diagnostic.range.start.line
                }

                return severity1 < severity2
            }

            fileNode.diagnostics = sortedDiagnosticNodes

            // Restore expansion state if it was previously expanded
            if expandedFileUris.contains(uri) {
                fileNode.isExpanded = true
            }
        }

        rebuildTree()
        diagnosticsDidChangePublisher.send()
    }

    func clearDiagnostics() {
        fileNodesByUri.removeAll()
        expandedFileUris.removeAll()
        rebuildTree()
        diagnosticsDidChangePublisher.send()
    }

    func removeDiagnostics(uri: DocumentUri) {
        fileNodesByUri.removeValue(forKey: uri)
        expandedFileUris.remove(uri)
        rebuildTree()
        diagnosticsDidChangePublisher.send()
    }

    func updateFilter(options: IssueFilterOptions) {
        self.filterOptions = options
        applyFilter()
        diagnosticsDidChangePublisher.send()
    }

    /// Save expansion state for a file
    func setFileExpanded(_ uri: DocumentUri, isExpanded: Bool) {
        if isExpanded {
            expandedFileUris.insert(uri)
        } else {
            expandedFileUris.remove(uri)
        }

        if let fileNode = fileNodesByUri[uri] {
            fileNode.isExpanded = isExpanded
        }
    }

    /// Get all expanded file URIs for persistence
    func getExpandedFileUris() -> Set<DocumentUri> {
        return expandedFileUris
    }

    /// Restore expansion state from persisted data
    func restoreExpandedFileUris(_ uris: Set<DocumentUri>) {
        expandedFileUris = uris

        // Apply to existing file nodes
        for uri in uris {
            if let fileNode = fileNodesByUri[uri] {
                fileNode.isExpanded = true
            }
        }
    }

    private func applyFilter() {
        guard let rootNode else { return }
        let filteredRoot = ProjectIssueNode(name: rootNode.name)
        filteredRoot.isExpanded = rootNode.isExpanded

        // Filter files and diagnostics
        for fileNode in rootNode.files {
            let filteredDiagnostics = fileNode.diagnostics.filter {
                filterOptions.shouldShow(diagnostic: $0.diagnostic)
            }

            if !filteredDiagnostics.isEmpty {
                let filteredFileNode = FileIssueNode(
                    uri: fileNode.uri,
                    name: fileNode.name,
                    diagnostics: filteredDiagnostics,
                    isExpanded: fileNode.isExpanded
                )
                filteredRoot.files.append(filteredFileNode)
            }
        }

        filteredRoot.files.sort { $0.name < $1.name }
        filteredRootNode = filteredRoot
    }

    /// Rebuilds the tree structure based on current diagnostics
    private func rebuildTree() {
        guard let rootNode else { return }

        let projectExpanded = rootNode.isExpanded
        let sortedFileNodes = fileNodesByUri.values
            .sorted { $0.name < $1.name }

        rootNode.files = sortedFileNodes
        rootNode.isExpanded = projectExpanded

        applyFilter()
    }

    /// Extracts file name from document URI
    private func getFileName(from uri: DocumentUri) -> String {
        if let url = URL(string: uri) {
            return url.lastPathComponent
        }

        let components = uri.split(separator: "/")
        return String(components.last ?? "Unknown")
    }

    func getAllDiagnostics() -> [Diagnostic] {
        return fileNodesByUri.values.flatMap { fileNode in
            fileNode.diagnostics.map { $0.diagnostic }
        }
    }

    func getDiagnostics(for uri: DocumentUri) -> [Diagnostic]? {
        return fileNodesByUri[uri]?.diagnostics.map { $0.diagnostic }
    }

    func getFileNode(for uri: DocumentUri) -> FileIssueNode? {
        return fileNodesByUri[uri]
    }

    func getDiagnosticCountBySeverity() -> [DiagnosticSeverity?: Int] {
        let allDiagnostics = getAllDiagnostics()
        var countBySeverity: [DiagnosticSeverity?: Int] = [:]

        for severity in DiagnosticSeverity.allCases {
            countBySeverity[severity] = allDiagnostics.filter { $0.severity == severity }.count
        }

        countBySeverity[nil] = allDiagnostics.filter { $0.severity == nil }.count
        return countBySeverity
    }

    func getDiagnosticAt(uri: DocumentUri, line: Int, character: Int) -> Diagnostic? {
        guard let fileNode = fileNodesByUri[uri] else { return nil }

        return fileNode.diagnostics.first { diagnosticNode in
            let range = diagnosticNode.diagnostic.range

            // Check if position is within the diagnostic range
            if line < range.start.line || line > range.end.line {
                return false
            }
            if line == range.start.line && character < range.start.character {
                return false
            }
            if line == range.end.line && character > range.end.character {
                return false
            }
            return true
        }?.diagnostic
    }
}

/// Options for filtering diagnostics in the issue navigator
struct IssueFilterOptions {
    var showErrors: Bool = true
    var showWarnings: Bool = true
    var showInformation: Bool = true
    var showHints: Bool = true
    var searchText: String = ""

    func shouldShow(diagnostic: Diagnostic) -> Bool {
        if let severity = diagnostic.severity {
            switch severity {
            case .error:
                guard showErrors else { return false }
            case .warning:
                guard showWarnings else { return false }
            case .information:
                guard showInformation else { return false }
            case .hint:
                guard showHints else { return false }
            }
        }

        if !searchText.isEmpty {
            return diagnostic.message.lowercased().contains(searchText.lowercased())
        }
        return true
    }
}
