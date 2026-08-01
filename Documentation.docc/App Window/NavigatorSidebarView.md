# ``CodeEdit/NavigatorSidebarView``

Navigator and inspector sidebars use ``WorkspacePanelView``, which keeps every tab panel
mounted and toggles visibility with opacity. That preserves AppKit outline expansion and
scroll position when switching between Project, Source Control, Search, and inspector tabs
(see issue #711).

## Topics

### Toolbars

- ``NavigatorSidebarToolbarTop``
- ``NavigatorSidebarToolbarBottom``

### Project Navigator

- ``ProjectNavigatorView``
- ``OutlineView``
- ``OutlineViewController``
- ``OutlineMenu``
- ``OutlineTableViewCell``
- ``OutlineTableViewCellDelegate``

### Source Control Navigator

- ``SourceControlNavigatorView``
- ``SourceControlModel``
- ``SourceControlSearchToolbar``
- ``SourceControlToolbarBottom``
- ``SourceControlNavigatorRepositoriesView``
- ``SourceControlNavigatorChangesView``
- ``SourceControlNavigatorChangedFileView``

### Find Navigator

- ``FindNavigatorView``
- ``FindNavigatorSearchBar``
- ``FindNavigatorModeSelector``
- ``FindNavigatorResultList``
- ``FindNavigatorListViewController``
- ``FindNavigatorListMatchCell``

### Extension Navigator

- ``ExtensionNavigatorView``
- ``ExtensionNavigatorItemView``
- ``ExtensionNavigatorData``
- ``ExtensionInstallationView``
- ``ExtensionInstallationViewModel``
