#  ``CodeEditUI/ToolbarBranchPicker``

## Overview

When the current project is a git repository, this will show the currently 
checked-out branch as a subtitle. Once a tap is registered, a popup will 
appear displaying the currently checked-out branch and all other local branches.

This view should be set to the `view` property in a [`NSToolbarItem`](https://developer.apple.com/documentation/appkit/nstoolbaritem).

## Usage

First make sure a `WorkspaceDocument` is accessible in the context.

```swift
var workspace: WorkspaceDocument?
```

Then in 
[`toolbar(_:itemForItemIdentifier:willBeInsertedIntoToolbar:)`](https://developer.apple.com/documentation/appkit/nstoolbardelegate/1516985-toolbar), 
create a new [`NSToolbarItem`](https://developer.apple.com/documentation/appkit/nstoolbaritem):

```swift
let toolbarItem = NSToolbarItem(itemIdentifier: /* Identifier */)

// create a NSHostingView
let view = BranchPickerToolbarItem(workspace?.workspaceClient)
let hostingView = NSHostingView(rootView: view)

// set the view property of the toolbar item
toolbarItem.view = hostingView

// return the toolbar item
return toolbarItem
```

## Preview

![BranchPicker](BranchPicker_View.png)
