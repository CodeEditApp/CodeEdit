# Adding a New Tab Type

This article is about how to add a new tab type to `TabBar`

## Overview

First of all, each data type to be represented as tab in the UI should conform to
``TabBarItemRepresentable`` protocol. For example, this is how it is done for
`FileItem`:

```swift
final class FileItem: Identifiable, Codable, TabBarItemRepresentable {
    public var tabID: TabBarItemID {
        .codeEditor(id)
    }

    public var title: String {
        self.url.lastPathComponent
    }

    public var icon: Image {
        Image(systemName: self.systemImage)
    }

    public var iconColor: Color {
        ...
    }

    ...
}
```

### Add new item identifier case

Each new tab type must have new identifier case, for example:
```swift
public enum TabBarItemID: Codable, Identifiable, Hashable {
    public var id: String {
        switch self {
        ...
        case .gitHistory(let repo):
            return "gitHistory_\(repo)"
        }
    }

    /// Represents Git history
    case gitHistory(String)
}
```

### Opening and closing new tab types

Tabs are opened using ``WorkspaceDocument.openTab(item:)`` method. It does a set of common
things for all tabs. But also it calls a private method based on the ``TabBarItemID`` of the
item. The private method for your ``TabBarItemRepresentable`` MUST persist this item
somewhere (I recommend persisting them in ``WorkspaceDocument.SelectionState``).

The same is for closing tabs using ``WorkspaceDocument.closeTab(item:)`` method.
Closing multiple tabs at once is handled by common functions, so there are no changes
required for them.

``WorkspaceDocument.close`` calls ``WorkspaceDocument.saveSelectionState`` to persist Workspace Selection State to UserDefaults.

``WorkspaceDocument.read`` calls ``WorkspaceDocument.readSelectionState`` to retrieve Workspace Selection State from UserDefaults.

Also, because previously opened tabs are persisted in UserDefaults,
they should be recovered some way later. To recover new tab types you need to add
a case for ``WorkspaceDocument.read`` to let it know how to recover your new tab type.

If you need to persist something as code editor tabs do for files, then you need to add
functionality to persist changes to ``WorkspaceDocument.close``.

Also, you need to add a case for new tab type to
``WorkspaceDocument.SelectionState.getItemByTab(id:)``. It will allow to use
``WorkspaceDocument.SelectionState.selected`` property and other features.

### Adding a view for the new tab type

To add a view for new tab type, you need to add a case for your tab type to
``WorkspaceView.tabContent``:

```swift
@ViewBuilder var tabContent: some View {
    if let tabID = workspace.selectionState.selectedId {
        switch tabID {
            ...
        case .gitHistory:
            GitHistoryView(windowController: windowController, workspace: workspace)
        }
    } else {
        noEditor
    }
}
```
