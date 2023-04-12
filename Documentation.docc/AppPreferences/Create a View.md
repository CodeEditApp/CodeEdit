# Create a View

Now that you followed the <doc:Getting-Started> guide it's time to create a view.

## Add Option to existing Section

In our example we added `ourNewOption` in ``Settings/GeneralPreferences``.

Now let's take a look at the ``GeneralPreferencesView``.

```swift
import SwiftUI

struct GeneralPreferencesView: View {

    // MARK: - View

    init() {}

    var body: some View {
        PreferencesContent {
            appearanceSection
            showIssuesSection
            fileExtensionsSection
        }
    }

    @AppSettings var settings
}
```

As you can see ``SettingsModel`` is already setup and ready to use.

To add your option toggle below the other options just add something like this:

```swift
private extension GeneralPreferencesView {
    
    // MARK: - Sections

    private var yourOptionSection: some View {
        PreferencesSection("Your Option") {
            yourOption
        }
    }

    // MARK: - Preferences View
    
    private var yourOption: some View {
        Toggle("Your text", isOn: $settings.general.yourNewOption)
    }
}
```

Then add it to `var body: some View`

```swift
struct GeneralPreferencesView: View {

    // MARK: - View

    init() {}

    var body: some View {
        PreferencesContent {
            appearanceSection
            showIssuesSection
            fileExtensionsSection
            // REMOVEME: et cetera
            yourOptionSection
        }
    }
}
```

And now you're done!

## Implement new Section

> Tip: Rename YourSection to the section name that you want

To implement a new section first create a new folder inside the `Sections` folder and name it accordingly.

Inside the folder create a new SwiftUI view and name it "PreferencesYourSectionView.swift".

Then find `VenturaPreferences.swift` by searching in the filter field at the bottom of the file explorer, then create a new page for your view like so:

> Tip: The order that pages are arranged in the array is the same as in the settings window, the first array member will be the top item

```swift
private static let pages: [Page] = [
    .init(.appPreferencesSection, children: [
        .init(
            .generalPreferences,
            icon: .init(
                baseColor: Colors().gray,
                systemName: "gear",
                icon: .system("gear")
            )
        ),
        .init(
              .yourSection,
              icon: .init(
                baseColor: Colors().yourColor
                systemName: "// REMOVEME: Find an SF Symbol that is similar to the icon you imagined"
                icon: .system("// REMOVEME: Find an SF Symbol that is similar to the icon you imagined")
            )
        )
    ]
]
```

Then find the file `Page.swift` and add `YourSection` to the `enum Name` like this:

```swift
enum Name: String {
    case appPreferencesSection = "App Preferences"

    case generalPreferences = "General"
    case advancedPreferences = "Advanced"
    // REMOVEME: et cetera
    case yourSection = "YourSection"
}
```

Back in `YourSectionView.swift` implement your option like this:

```swift
import SwiftUI

struct YourSectionPreferencesView: View {
    var body: some View {
        yourToggleSection
    }

    @StateObject
    private var prefs: SettingsModel = .shared

    public init() {}
}

private extension YourSectionPreferencesView {
    
    // MARK: - Sections

    private var yourToggleSection: some View {
        yourToggle
    }

    // MARK: - Preferences Views

    private var yourToggle: some View {
        Toggle("Your option", isOn: $settings.general.yourNewOption)
    }
}
```

When you are done, add `YourSectionView` to `VenturaPreferences.swift`:

```swift
if selectedPage?.name != nil {
    // Can force un-wrap because we just checked if it was nil
    switch selectedPage!.name {
    case .generalPreferences:
        GeneralPreferencesView()
            .environmentObject(updater)
    case .themePreferences:
        ThemePreferencesView()
    // REMOVEME: et cetera
    case .yourSection:
        YourSectionPreferencesView()
```
