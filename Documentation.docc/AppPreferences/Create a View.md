# Create a View

Now that you followed the <doc:Getting-Started> guide it's time to create a view.

## Add setting to existing Section

In our example we added `ourNewOption` in ``Settings/GeneralSettings``.

Now let's take a look at the ``GeneralSettingsView``.

```swift
import SwiftUI

struct GeneralSettingsView: View {
    @AppSettings(\.general)
    var settings

    var body: some View {
        SettingsForm {
            Section {
                appearance
                fileIconStyle
                navigatorTabBarPosition
                inspectorTabBarPosition
                ...
            }
        }
    }
}
```

As you can see ``SettingsModel`` is already setup and ready to use.

To add your option toggle below the other options just add something like this:

```swift
private extension GeneralSettingsView {
    // MARK: - Settings View
    
    private var yourOption: some View {
        Toggle("Your text", isOn: $general.yourNewOption)
    }
}
```

Then add it to `var body: some View`

```swift
struct GeneralSettingsView: View {
    var body: some View {
        SettingsForm {
            Section {
                appearanceSection
                showIssuesSection
                fileExtensionsSection
                // REMOVEME: et cetera
                yourOptionSection
            }
        }
    }
}
```

And now you're done!

## Implement a new section

> Tip: Rename YourSection to the section name that you want

To implement a new section first create a new folder inside the `Pages` folder and name it accordingly.

Inside the folder create a new SwiftUI view and name it "YourSectionSettingsView.swift".

Then create a new folder inside called `Models` and inside of it create a file named "YourSectionSettings.swift"


> Tip: The order that pages are arranged in the array is the same as in the settings window, the first array member will be the top item
```

Then find the file `SettingsPage.swift` and add `YourSection` to the `enum Name` like this:

```swift
enum Name: String {
    case general = "General"
    case advanced = "Advanced"
    // et cetera
    case yourSection = "YourSection"
}
```

Back in `YourSectionView.swift` implement your option like this:

```swift
import SwiftUI

struct YourSectionSettingsView: View {
    @AppSettings(\.yourSection)
    var yourSection

    var body: some View {
        SettingsForm {
            Section {
                yourToggleSection
            }
        }
    }
}

private extension YourSectionSettingsView {
    // MARK: - Settings Views

    private var yourToggle: some View {
        Toggle("Your option", isOn: $yourSection.yourNewOption)
    }
}
```

There are 3 more steps, almost done.

Open `ModelNameToSettingName.swift` and add your translated search result:

```swift
let translator: [String: String] = [
    // MARK: - General Settings
    "appAppearance": NSLocalizedString("Appearance", comment: ""),
    "fileIconStyle": NSLocalizedString("File Icon Style", comment: ""),
    // etc
    // MARK: - Your Section
    "yourOption": NSLocalizedString("Your Option", comment: "Your translation comment")
]
```

Now, open `SettingsView.swift` and add your section to the `populatePages()` method:

```swift
/// Creates all the neccessary pages
private func populatePages() -> [SettingsPage] {
    var pages = [SettingsPage]()
    let settingsData = SettingsData()

    let generalSettings = SettingsPage(.general, baseColor: .gray, icon: .system("gear"))
    pages = createPageAndSettings(settingsData.general, parent: generalSettings, prePages: pages)

    let accountsSettings = SettingsPage(.accounts, baseColor: .blue, icon: .system("at"))
    pages = createPageAndSettings(settingsData.accounts, parent: accountsSettings, prePages: pages)

    // etc
    let yourSectionSettings = SettingsPage(.yourSection, baseColor: /* add color here */, icon: /* add icon */)
    pages = createPageAndSettings(settingsData.yourSection, parent: yourSectionSettings, prePages: pages)

    return pages
}
```


When you are done, add `YourSectionSettingsView` to `SettingsView.swift`:

```swift
Group {
    switch selectedPage {
    case .general:
        GeneralSettingsView().environmentObject(updater)
    case .yourSection:
        YourSectionSettingsView()
    default:
        Text("Implementation Needed").frame(alignment: .center)
    }
}
```
