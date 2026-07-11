import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let model = AppModel()
    private var statusItem: NSStatusItem?
    private var preferencesWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "MacBuddy"
        item.menu = makeMenu()
        statusItem = item
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Organize Downloads Preview", action: #selector(organizeDownloadsPreview), keyEquivalent: "d"))
        menu.addItem(NSMenuItem(title: "Organize Downloads Now", action: #selector(organizeDownloadsNow), keyEquivalent: "D"))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Apply Mood Wallpaper", action: #selector(applyWallpaper), keyEquivalent: "w"))
        menu.addItem(NSMenuItem(title: "Toggle Dark/Light", action: #selector(toggleAppearance), keyEquivalent: "a"))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit MacBuddy", action: #selector(quit), keyEquivalent: "q"))
        for item in menu.items {
            item.target = self
        }
        return menu
    }

    @objc private func organizeDownloadsPreview() { model.organizeDownloads(dryRun: true) }
    @objc private func organizeDownloadsNow() { model.organizeDownloads(dryRun: false) }
    @objc private func applyWallpaper() { model.applyWallpaper() }
    @objc private func toggleAppearance() { model.toggleAppearance() }
    @objc private func quit() { NSApp.terminate(nil) }

    @objc private func openPreferences() {
        model.diagnosticsVisible = NSEvent.modifierFlags.contains(.option)
        if preferencesWindow == nil {
            let view = PreferencesView(model: model)
            let window = NSWindow(contentViewController: NSHostingController(rootView: view))
            window.title = "MacBuddy Preferences"
            window.setContentSize(NSSize(width: 720, height: 560))
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            preferencesWindow = window
        }
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
