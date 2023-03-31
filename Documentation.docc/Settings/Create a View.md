# Create a View

Now that you followed the <doc:Getting-Started> guide it's time to create a view.

## Add Option to existing Section

In our example we added `ourNewOption` in ``AppSettings/GeneralSettings``.

Now let's take a look at the ``GeneralSettingsView``.

```swift
import SwiftUI

struct GeneralSettingsView: View {

    // MARK: - View

    init() {}

    var body: some View {
        SettingsContent {
            appearanceSection
            showIssuesSection
            fileExtensionsSection
        }
    }

    @StateObject
    private var prefs: AppSettingsModel = .shared
}
```

As you can see ``AppSettingsModel`` is already setup and ready to use.

To add your option toggle below the other options just add something like this:

```swift
private extension GeneralSettingsView {
    
    // MARK: - Sections

    private var yourOptionSection: some View {
        SettingsSection("Your Option") {
            yourOption
        }
    }

    // MARK: - Settings View
    
    private var yourOption: some View {
        Toggle("Your text", isOn: $prefs.settings.general.yourNewOption)
    }
}
```

Then add it to `var body: some View`

```swift
struct GeneralSettingsView: View {

    // MARK: - View

    init() {}

    var body: some View {
        SettingsContent {
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

Inside the folder create a new SwiftUI view and name it "SettingsYourSectionView.swift".

Then find `Settings.swift` by searching in the filter field at the bottom of the file explorer, then create a new page for your view like so:

> Tip: The order that pages are arranged in the array is the same as in the settings window, the first array member will be the top item

```swift
private static let pages: [Page] = [
    .init(.settingsSection, children: [
        .init(
            .generalSettings,
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
    case settingsSection = "App Settings"

    case generalSettings = "General"
    case advancedSettings = "Advanced"
    // REMOVEME: et cetera
    case yourSection = "YourSection"
}
```

Back in `YourSectionView.swift` implement your option like this:

```swift
import SwiftUI

struct YourSectionSettingsView: View {
    var body: some View {
        yourToggleSection
    }

    @StateObject
    private var prefs: AppSettingsModel = .shared

    public init() {}
}

private extension YourSectionSettingsView {
    
    // MARK: - Sections

    private var yourToggleSection: some View {
        yourToggle
    }

    // MARK: - Settings Views

    private var yourToggle: some View {
        Toggle("Your option", isOn: $prefs.settings.general.yourNewOption)
    }
}
```

When you are done, add `YourSectionView` to `Settings.swift`:

```swift
if selectedPage?.name != nil {
    // Can force un-wrap because we just checked if it was nil
    switch selectedPage!.name {
    case .generalSettings:
        GeneralSettingsView()
            .environmentObject(updater)
    case .themeSettings:
        ThemeSettingsView()
    // REMOVEME: et cetera
    case .yourSection:
        YourSectionSettingsView()
```
