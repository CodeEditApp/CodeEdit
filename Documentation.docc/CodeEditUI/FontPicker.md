# ``CodeEditUI/FontPicker``

## Overview

Opens a [`NSFontPanel`](https://developer.apple.com/documentation/appkit/nsfontpanel) and binds the `fontSize` and `fontName` paramters to the provided variables.

## Usage

```swift
@State var fontName: String = "SF-Mono"
@State var fontSize: Int = 13

FontPicker("Font Picker", name: $fontName, size: $fontSize)
```

## Preview

![FontPicker](FontPicker_View.png)
