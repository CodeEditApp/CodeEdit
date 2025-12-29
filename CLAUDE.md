# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CodeEdit is a native macOS code editor written in Swift and SwiftUI. It targets macOS 13+ and supports both Intel and Apple Silicon architectures. The project aims to be a lightweight yet feature-rich alternative to Xcode.

## Build Commands

```bash
# Build the app (output: ./build/Build/Products/Debug/CodeEdit.app)
xcodebuild -scheme CodeEdit -derivedDataPath ./build -skipPackagePluginValidation build

# Run the built app
open ./build/Build/Products/Debug/CodeEdit.app

# Run tests
xcodebuild -scheme CodeEdit -derivedDataPath ./build -destination "platform=OS X,arch=arm64" -skipPackagePluginValidation test

# Run SwiftLint
swiftlint --reporter xcode

# Auto-fix SwiftLint violations
swiftlint --fix
```

**Important**: Always use `-skipPackagePluginValidation` flag with xcodebuild commands.

## Architecture

### Directory Structure

- **CodeEdit/** - Main application target
  - **Features/** - 28 feature modules (About, Editor, LSP, NavigatorArea, Search, Settings, SourceControl, TerminalEmulator, etc.)
  - **Utils/** - Utility modules (DependencyInjection, Extensions, KeyChain, ShellClient)
  - **ShellIntegration/** - Shell integration scripts
  - **Localization/** - Translation files
- **CodeEditTests/** - Unit and integration tests
- **CodeEditUITests/** - XCUITest automation tests
- **OpenWithCodeEdit/** - macOS "Open With" extension
- **DefaultThemes/** - Theme files (.cetheme format)
- **Configs/** - Build configurations (Debug, Beta, Alpha, Pre, Release)

### Key Architectural Patterns

- **Service Container** - Dependency injection via `DependencyInjection/` for singleton services
- **Feature Modules** - Each feature in `Features/` is self-contained with its own views, models, and logic
- **SwiftUI Environment** - Settings and state distributed via SwiftUI environment values
- **Focused Values** - Focus state management for editor interactions

### Entry Points

- `CodeEditApp.swift` - App root (@main)
- `AppDelegate.swift` - App lifecycle
- `WorkspaceView.swift` - Main editor UI
- `CodeEditDocumentController.swift` - Document management

## Key Dependencies

**CodeEdit Libraries** (custom packages):
- CodeEditSourceEditor - Editor view components
- CodeEditTextView - Text editing
- CodeEditLanguages - 100+ language definitions
- CodeEditKit - Core utilities

**Core Technologies**:
- SwiftTreeSitter - Tree-sitter bindings for syntax parsing
- LanguageServerProtocol / LanguageClient - LSP support
- SwiftTerm - Terminal emulator
- GRDB - SQLite persistence
- Sparkle - Auto-updates

## Testing

Tests use XCTest framework with a test plan at `CodeEditTestPlan.xctestplan`.

For UI tests:
- Use `App.launchWithTempDir()` for creating temporary test files
- Use `Query` enum for common XCUI element queries
- Avoid `App.launchWithCodeEditWorkspace` (may be flaky)

## Code Style

SwiftLint enforces code style (`.swiftlint.yml`):
- **Use spaces for indentation, not tabs**
- Document public APIs (missing_docs rule enabled)
- Follow Apple's modifier order
- Resolve all violations before PR (except TODO warnings)

## CI/CD

GitHub Actions workflows:
- `tests.yml` - Runs test suite
- `lint.yml` - SwiftLint checks (must pass before merge)
- `pre-release.yml` - Builds, signs, notarizes, creates DMG

Build configurations: Debug, Beta, Alpha, Pre, Release (XCConfig files in `Configs/`)

## Development Notes

- Currently not accepting localization PRs (team preparing for future support)
- Project uses self-hosted macOS runners for CI builds
- Discord community has weekly meetups Saturdays at 3pm UTC
