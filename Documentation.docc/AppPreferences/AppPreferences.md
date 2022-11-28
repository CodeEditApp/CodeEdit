# ``AppPreferences``

This package manages **Preferences** of the app.

## Overview

The main task is to get the preferences from `~/Library/Application Support/CodeEdit/preferences.json` and load them into an ``AppPreferences/AppPreferences`` model.
Once a value changes the changes are written to the `preferences.json` file.

It also contains all preferences section views and necessary sub-models.

## Topics

### Getting Started

- <doc:Getting-Started>
- <doc:Create-a-View>

### Preferences Model

- ``AppPreferences/AppPreferences``
- ``AppPreferences/AppPreferencesModel``

### Preferences Section Views

- ``AppPreferences/GeneralPreferencesView``
- ``AppPreferences/ThemePreferencesView``
- ``AppPreferences/TextEditingPreferencesView``
- ``AppPreferences/TerminalPreferencesView``
- ``AppPreferences/LocationsPreferencesView``
- ``AppPreferences/PreferencesPlaceholderView``

### Section Content Views

- ``AppPreferences/PreferencesContent``
- ``AppPreferences/PreferencesSection``

### Theme Preferences Model

- ``AppPreferences/Theme``
- ``AppPreferences/ThemeModel``
