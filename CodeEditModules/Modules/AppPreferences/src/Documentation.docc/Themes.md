# ``AppPreferences/Theme``

## Overview

A ``AppPreferences/Theme`` is stored in a `theme_name.json` file in the `~/.codeedit/themes/` directory. When this
is empty, a bundled template theme will be created. 

Once a `JSON` file is loaded, the ``AppPreferences/Theme`` gets added to ``AppPreferences/ThemeModel/themes``.

They can either be ``AppPreferences/Theme/ThemeType/dark`` or ``AppPreferences/Theme/ThemeType/light``.

## JSON Structure

```json
{
  "author" : "CodeEdit",
  "license" : "MIT",
  "description" : "CodeEdit default dark theme.",
  "distributionURL" : "https:\/\/github.com\/CodeEditApp\/CodeEdit",
  "name" : "Default (Dark)",
  "version" : "0.0.1",
  "type" : "dark",
  "editor" : {
    "strings" : {
      "color" : "#f0907f"
    },
    "comments" : {
      "color" : "#97be71"
    },
    "numbers" : {
      "color" : "#d6c775"
    },
    "commands" : {
      "color" : "#c6a3f9"
    },
    "lineHighlight" : {
      "color" : "#303030"
    },
    "values" : {
      "color" : "#70c1e2"
    },
    "background" : {
      "color" : "#1e1e1e"
    },
    "keywords" : {
      "color" : "#ef8bb6"
    },
    "text" : {
      "color" : "#DDDDDD"
    },
    "insertionPoint" : {
      "color" : "#DDDDDD"
    },
    "selection" : {
      "color" : "#8b8b8b"
    },
    "types" : {
      "color" : "#93c7bc"
    },
    "variables" : {
      "color" : "#70c1e2"
    },
    "attributes" : {
      "color" : "#93c7bc"
    },
    "characters" : {
      "color" : "#93c7bc"
    },
    "invisibles" : {
      "color" : "#636363"
    }
  },
  "terminal" : {
    "text" : {
      "color" : "#ffffff"
    },
    "boldText" : {
      "color" : "#ffffff"
    },
    "cursor" : {
      "color" : "#ffffff"
    },
    "background" : {
      "color" : "#1e1e1e"
    },
    "selection" : {
      "color" : "#8b8b8b"
    },
    "black" : {
      "color" : "#000000"
    },
    "red" : {
      "color" : "#990000"
    },
    "green" : {
      "color" : "#00a600"
    },
    "yellow" : {
      "color" : "#999900"
    },
    "blue" : {
      "color" : "#0000b2"
    },
    "magenta" : {
      "color" : "#b200b2"
    },
    "cyan" : {
      "color" : "#00a6b2"
    },
    "white" : {
      "color" : "#bfbfbf"
    },
    "brightBlack" : {
      "color" : "#666666"
    },
    "brightRed" : {
      "color" : "#e50000"
    },
    "brightGreen" : {
      "color" : "#00d900"
    },
    "brightYellow" : {
      "color" : "#e5e500"
    },
    "brightBlue" : {
      "color" : "#0000ff"
    },
    "brightMagenta" : {
      "color" : "#e500e5"
    },
    "brightCyan" : {
      "color" : "#00e5e5"
    },
    "brightWhite" : {
      "color" : "#e5e5e5"
    }
  }
}
```

## Topics

### General Info

- ``author``
- ``license``
- ``metadataDescription``
- ``distributionURL``
- ``name``
- ``version``
- ``appearance``
- ``ThemeType``

### Editor

- ``Theme/EditorColors``
- ``editor``
- ``Attributes``

### Terminal

- ``Theme/TerminalColors``
- ``terminal``
- ``Attributes``
