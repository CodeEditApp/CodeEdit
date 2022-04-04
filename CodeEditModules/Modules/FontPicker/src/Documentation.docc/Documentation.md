# ``FontPicker/FontPicker``

A package that implements a font picker for SwiftUI.

## Usage

```swift

@State
private var fontName: String = "SF-MonoMedium"

@State
private var fontSize: Int = 11

FontPicker("Some label", name: $fontName, size: $fontSize)

```
