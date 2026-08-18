# ``CodeEdit/StatusBarView``

The status bar shows editor context for the active tab, including the cursor line and column.

``StatusBarCursorPositionLabel`` observes the active ``EditorInstance`` by object identity
(not file equality) and keeps the last known caret when SourceEditor omits cursor state on
scroll-only updates. Unresolved range-only positions fall back to `Line: 1  Col: 1` until the
text view resolves line and column.

## Topics

### Model

- ``ImageDimensions``

### View Model

- ``StatusBarViewModel``

### View Modifiers

- ``UpdateStatusBarInfo``

### Items

- ``StatusBarMenuStyle``
- ``StatusBarBreakpointButton``
- ``StatusBarIndentSelector``
- ``StatusBarEncodingSelector``
- ``StatusBarLineEndSelector``
- ``StatusBarToggleUtilityAreaButton``
- ``StatusBarCursorPositionLabel``
