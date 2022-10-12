# ``AppPreferences/Theme``

## Overview

A ``AppPreferences/Theme`` is stored in a `theme_name.json` file in the `~/Library/Application Support/CodeEdit/themes/` directory. There are a
couple of bundled themes that will automatically be put there once the app starts.

Once a `JSON` file is loaded, the ``AppPreferences/Theme`` gets added to ``AppPreferences/ThemeModel/themes``.

They can either be ``AppPreferences/Theme/ThemeType/dark`` or ``AppPreferences/Theme/ThemeType/light``.

## JSON Structure

```json
{
  "author" : "CodeEdit",
  "name" : "codeedit-xcode-dark",
  "displayName" : "Xcode Dark",
  "description" : "Xcode dark theme.",
  "version" : "0.0.1",
  "license" : "MIT",
  "type" : "dark",
  "distributionURL" : "https:\/\/github.com\/CodeEditApp\/CodeEdit",
  "editor" : { ... },
  "terminal" : { ... }
}
```

| Key | Description |
| --- | ----------- |
| ``author`` | Your Name |
| ``name`` | A unique string representing the theme. _It's good practice to start it with your name or domain to make sure it is unique._ |
| ``displayName`` | The name that will appear in the UI |
| description / ``metadataDescription`` | A short description that will appear when hovering over the theme thumbnail |
| ``version`` | A version number |
| ``license`` | Which license your theme is published under |
| type / ``appearance`` | The type of the theme [**dark**, **light**] |
| ``distributionURL`` | A URL to your web presentation |
| ``editor`` | A collection of colors for the editor |
| ``terminal`` | A collection of colors for the terminal |

### Editor

```json
{
  "invisibles" : {
    "color" : "#424D5B"
  },
  "comments" : {
    "color" : "#73A74E"
  },
  "numbers" : {
    "color" : "#D0BF69"
  },
  "commands" : {
    "color" : "#67B7A4"
  },
  "lineHighlight" : {
    "color" : "#23252B"
  },
  "values" : {
    "color" : "#A167E6"
  },
  "background" : {
    "color" : "#1F1F24"
  },
  "keywords" : {
    "color" : "#FF7AB3"
  },
  "text" : {
    "color" : "#D9D9D9"
  },
  "insertionPoint" : {
    "color" : "#D9D9D9"
  },
  "strings" : {
    "color" : "#FC6A5D"
  },
  "selection" : {
    "color" : "#515B70"
  },
  "types" : {
    "color" : "#5DD8FF"
  },
  "variables" : {
    "color" : "#41A1C0"
  },
  "attributes" : {
    "color" : "#D0A8FF"
  },
  "characters" : {
    "color" : "#D0BF69"
  }
}
```

### Terminal

```json
{
  "white" : {
    "color" : "#d9d9d9"
  },
  "brightMagenta" : {
    "color" : "#af52de"
  },
  "brightRed" : {
    "color" : "#ff3b30"
  },
  "blue" : {
    "color" : "#007aff"
  },
  "red" : {
    "color" : "#ff3b30"
  },
  "green" : {
    "color" : "#28cd41"
  },
  "boldText" : {
    "color" : "#d9d9d9"
  },
  "brightGreen" : {
    "color" : "#28cd41"
  },
  "background" : {
    "color" : "#1f2024"
  },
  "cursor" : {
    "color" : "#d9d9d9"
  },
  "selection" : {
    "color" : "#515b70"
  },
  "magenta" : {
    "color" : "#af52de"
  },
  "black" : {
    "color" : "#1f2024"
  },
  "text" : {
    "color" : "#d9d9d9"
  },
  "brightWhite" : {
    "color" : "#ffffff"
  },
  "brightBlue" : {
    "color" : "#007aff"
  },
  "brightYellow" : {
    "color" : "#ffff00"
  },
  "cyan" : {
    "color" : "#59adc4"
  },
  "yellow" : {
    "color" : "#ffcc00"
  },
  "brightCyan" : {
    "color" : "#55bef0"
  },
   "brightBlack" : {
    "color" : "#8e8e93"
  }
}
```

## Topics

### General Info

- ``author``
- ``name``
- ``displayName``
- ``metadataDescription``
- ``version``
- ``license``
- ``appearance``
- ``distributionURL``
- ``ThemeType``

### Editor

- ``Theme/EditorColors``
- ``editor``
- ``Attributes``

### Terminal

- ``Theme/TerminalColors``
- ``terminal``
- ``Attributes``

### Highlight.JS Wrapper
- ``highlightrThemeString``
