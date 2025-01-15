# UI Testing in CodeEdit

CodeEdit uses XCUITests for automating tests that require user interaction. Ideally, we have UI tests for every UI 
component in CodeEdit, but right now (as of Jan, 2025) we have fewer tests than we'd like.

## Test Application Setup

To test workspaces with real files, launch the application with the `App` enum. To create a temporary test directory,
use the `App.launchWithTempDir()` method. This will create a random directory in the temporary directory and return
the created path. In tests you can add files to that directory and it will be cleaned up when the tests finish.

There is a `App.launchWithCodeEditWorkspace` method, but please try not to use it. It exists for compatibility with a
few existing tests and would be a pain to replace. It's more likely to be flaky, and can't test things like file
modification, creation, or anything besides clicking around the workspace or you risk modifying the very project
that's being tested!

## Query Extensions

For common, long, queries, add static methods to the `Query` enum. This enum should be used to help clarify tests
without having to read long XCUI queries. For instance
```swift
let window = application.windows.element(matching: .window, identifier: "workspace")
let navigator = window.descendants(matching: .any).matching(identifier: "ProjectNavigator").element
let newFileCell = navigator
                .descendants(matching: .outlineRow)
                .containing(.textField, identifier: "ProjectNavigatorTableViewCell-FileName")
                .element(boundBy: 0)
```

Should be shortened to the following, which should be easier to read and intuit what the test is doing.

```swift
let window = Query.getWindow(app)
let navigator = Query.Window.getProjectNavigator(window)
let newFileCell = Query.Navigator.getProjectNavigatorRow(fileTitle: "FileName", navigator)
```

This isn't necessary for all tests, but useful for querying common regions like the project navigator, window, or 
utility area.
