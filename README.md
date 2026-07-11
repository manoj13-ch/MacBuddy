# MacBuddy

MacBuddy is an offline macOS menu bar helper built with SwiftUI and AppKit. It keeps common desktop chores local: organizing folders, switching wallpapers by mood, running safe maintenance tasks, and opening useful macOS locations quickly.

## Features

- Menu bar app with a Preferences window.
- Folder organizer with file-type rules, age rules, dry-run preview, action logging, and safe defaults.
- Mood wallpaper switching with manual mood selection, wallpaper directories, and simple offline keyword inference.
- Basic task runner for organizing files, opening common folders, toggling appearance, and cleaning safe temporary cache files.
- Widget limitation notes with a Shortcuts-based workaround.
- Local settings persistence through `UserDefaults`.
- Unit tests for organizer planning and mood wallpaper mapping.

## Privacy

MacBuddy has no cloud dependency and does not send files, mood text, logs, paths, or settings to any server. Mood inference is a local keyword matcher.

## Build And Run

Open this folder in Xcode with File > Open, then choose the `MacBuddy` package and run the `MacBuddy` executable target.

From Terminal:

```sh
swift run MacBuddy
```

Run local self-tests:

```sh
swift run MacBuddySelfTests
```

Note: this machine currently has Apple Command Line Tools active, not full Xcode. The installed Command Line Tools build can compile the app, but its testing frameworks are incomplete, so MacBuddy includes a dependency-free `MacBuddySelfTests` target for organizer and mood mapping checks. Packaging, notarization, and standard XCTest conversion require opening the project on a Mac with full Xcode installed.

## Permissions

MacBuddy degrades gracefully when a permission is missing. The organizer needs normal file access to the folders you choose. Wallpaper changes use macOS scripting and may ask for Automation permission. Opening folders uses Finder.

## Widgets Limitation

macOS does not allow third-party apps to edit other apps' widgets automatically. The supported workaround is to create Apple Shortcuts that open Widget settings, change Focus modes, or launch widget-related workflows, then trigger those shortcuts from MacBuddy.

## Signing And Notarization Notes

1. In Xcode, set a bundle identifier such as `com.yourname.MacBuddy`.
2. Select your Apple Developer Team.
3. Enable Hardened Runtime for distribution builds.
4. Archive the app, distribute with Developer ID, and notarize through Xcode Organizer or `notarytool`.

## Roadmap

- Import/export organizer rule presets.
- Menu bar quick status for latest organizer run.
- Shortcuts integration UI for user-created workflows.
- Optional Launch at Login helper.
- Sandboxed app target when moving from SwiftPM prototype to a full Xcode project.

## Troubleshooting

- If wallpaper switching fails, open System Settings > Privacy & Security > Automation and allow MacBuddy to control System Events or Finder if prompted.
- If organization does not move a file, check the action log; dry-run previews never modify files.
- If Xcode cannot run the package, confirm full Xcode is installed and selected with `xcode-select`.
