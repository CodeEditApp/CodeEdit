# Create a View

Now that you followed the <doc:Getting-Started> guide it's time to create a view.

## Add Option to existing Section

In our example we added `ourNewOption` in ``AppPreferences/AppPreferences/GeneralPreferences``.

Now let's take a look at the ``AppPreferences/GeneralPreferencesView``.

```swift
import SwiftUI

public struct PreferencesGeneralView: View {

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    public init() {}

    public var body: some View {
        PreferencesContent {
            PreferencesSection("Appearance") {
                // ...
            }
            PreferencesSection("File Icon Style") {
                // ...
            }
            PreferencesSection("Reopen Behavior") {
                // ...
            }
        }
    }
}
```

As you can see ``AppPreferences/AppPreferencesModel`` is already setup and ready to use.
Note that in order to align all the options in a nice and uniform way we wrap them into a
``AppPreferences/PreferencesContent`` and individual ``AppPreferences/PreferencesSection`` views.

To add your option toggle below the other options just add something like this:

```swift
PreferencesSection("Reopen Behavior") {
    Toggle("Your new Option", value: $prefs.preferences.general.yourNewOption)
}
```

And now you're done!

## Implement new Section

To implement a new section first create a new folder inside the `Sections` folder and name it accordingly.

In this example we might want to name it "AdvancedPreferences".

Inside the folder create a new SwiftUI view and name it "PreferencesAdvancedView.swift".

Then go to the main `CodeEdit` target and open the "AppDelegate.swift" and scroll down to find the `private lazy var preferencesWindowController` instance. Search for the `Pane` titled "Advanced" and replace `PreferencesPlaceholderView()` with your newly created `PreferencesAdvancedView()`.

Back in "PreferencesAdvancedView.swift" implement your option like that:

```swift
import SwiftUI

public struct PreferencesAdvancedView: View {

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    public init() {}

    public var body: some View {
        PreferencesContent {
            PreferencesSection("Reopen Behavior") {
                Toggle("Your new Option", value: $prefs.preferences.general.yourNewOption)
            }
        }
    }
}
```

