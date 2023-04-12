# Getting Started

There are a few things to consider when using the ``Settings``.

## Reading/Writing Values

The Preferences can be accessed from everywhere in the app like this:

```swift
import Settings

@AppSettings var settings
```

Since it is a `@StateObject` we can be sure to always get up-to-date information and we can easily bind to the individual properties like this:

```swift
Toggle("Enable some Feature", value: $settings.someFeature.isEnabled)
```

## Creating a New Preference

When implementing a new feature, we might have some options in regards to this new feature we want to show the user in the apps Preferences Window.

### Find a Section

The preferences window is structured in different sections. Figure out in which section your new option should appear in.

If the section is already populated with other options (e.g. ``Settings/GeneralPreferences``), just add your new option like this:

```swift
struct GeneralPreferences: Codable {

  // ...

  // This will be your new option. Be sure to provide a default value
  public var yourNewOption: Bool = true

  public init() {}

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    // ...

    // Try to decode the value from json.
    self.yourNewOption = try container.decodeIfPresent(
      Bool.self, 
      forKey: .yourNewOption
    ) ?? true // If the key is not present in the json, set the default value
  }
}
```

### Create a Section

In some cases in early development the section you decided on where to put your option in might not yet have been implemented. In this
case you can create a new `struct` inside ``Settings`` like this:

```swift
public extension YourNewSection: Codable {

  // This will be your new option. Be sure to provide a default value
  public var yourNewOption: Bool = true

  public init() {}

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    // Try to decode the value from json.
    self.yourNewOption = try container.decodeIfPresent(
      Bool.self, 
      forKey: .yourNewOption
    ) ?? true // If the key is not present in the json, set the default value
  }
}
```

Now let's add the new section to ``Settings`` like this:

```swift
public struct Settings: Codable {
  // ...

  // Add your new section above the `public init() {}`
  public var yourNewSection: YourNewSection = .init()

  // ...
}
```

## Topics

### Up Next

- <doc:Create-a-View>

### Main Components

- ``Settings``
- ``SettingsModel``
