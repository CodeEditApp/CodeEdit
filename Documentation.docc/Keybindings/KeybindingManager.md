# ``KeybindingManager``

This module created in order to put all keybindings into single place in code, so it'd be easy to interact, reuse and change keybindings without going through every class and changing code to use other shortcut. It uses `default_keybindings.json` file to store initial set of keybindings. After app launched all keybindings loaded into memory and can be referenced via ``KeybindingManager/named(with:)`` function.

## Initial setup

In order to get it working you just need to add `Keybindings` as dependency to your module just like
```
.target(
    name: "WelcomeModule",
    dependencies: [
        ...other dependencies
        "Keybindings",
    ])
```

Keybinding module exists as singleton, so you always can reference Keybindings using `KeybindingManager.shared`

## Topics


### Fetching shortcut

In order to fetch keybinding you need to call following function with string name ``Keybindings/KeybindingManager/named(with:)`` returning you ``KeyboardShortcutWrapper`` which contains ``KeyboardShortcutWrapper/keyboardShortcut`` which can be passed directly to  ``keyboardShortcut``. So the end code would look like `.keyboardShortcut(KeyboardShortcutWrapper.shared.named(with: "copy").keyboardShortcut`

If shortcut wasnt found by name, it will return fallback shortcut which has following keybinding `Shift + ?`

### Adding new shortcut

To add new shortcut you need first to add new row to `default_keybindings.json` file. Make sure you follow other keybindings format. Also check that there's no other keybindings with same ID,
because we use it to identify keybindings later. Once added - you can refer to `Fetching Shortcut` section. It is possible to add new shortcut in runtime via ``KeybindingManager/addNewShortcut(shortcut:name:)``
