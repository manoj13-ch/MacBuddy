import MacBuddyCore
import SwiftUI

struct PreferencesView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        TabView {
            organizer
                .tabItem { Label("Organizer", systemImage: "folder.badge.gearshape") }
            mood
                .tabItem { Label("Mood", systemImage: "photo.on.rectangle") }
            tasks
                .tabItem { Label("Tasks", systemImage: "bolt") }
            log
                .tabItem { Label("Log", systemImage: "list.bullet.rectangle") }
        }
        .padding()
        .frame(minWidth: 680, minHeight: 520)
    }

    private var organizer: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(model.sparkleMode ? "MacBuddy Preferences *" : "Folder Organizer")
                .font(.title2)
            Toggle("Include Downloads", isOn: $model.settings.organizeDownloads)
            Toggle("Include Desktop", isOn: $model.settings.organizeDesktop)
            HStack {
                Button("Preview Downloads") { model.organizeDownloads(dryRun: true) }
                Button("Organize Downloads") { model.organizeDownloads(dryRun: false) }
                Button("Preview Desktop") { model.organizeDesktop(dryRun: true) }
            }
            List(model.settings.rules) { rule in
                VStack(alignment: .leading) {
                    Text(rule.name).font(.headline)
                    Text(".\(rule.extensions.sorted().joined(separator: ", .")) -> \(rule.destinationFolder)")
                        .foregroundStyle(.secondary)
                }
            }
            Button("Save Settings") { model.save() }
        }
    }

    private var mood: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Mood Wallpaper").font(.title2)
            Picker("Mood", selection: $model.selectedMood) {
                ForEach(Mood.allCases) { mood in
                    Text(mood.rawValue.capitalized).tag(mood)
                }
            }
            TextField("Type a mood sentence for offline inference", text: $model.moodText)
            HStack {
                Button("Infer Mood") { model.inferMood() }
                Button("Apply Wallpaper") { model.applyWallpaper() }
            }
            Text("Mappings are stored locally. Add paths in the settings file or extend this view for custom pickers.")
                .foregroundStyle(.secondary)
        }
    }

    private var tasks: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Basic Tasks").font(.title2)
            HStack {
                Button("Open Downloads") { model.openDownloads() }
                Button("Open Desktop") { model.openDesktop() }
                Button("Toggle Dark/Light") { model.toggleAppearance() }
                Button("Clean Temp") { model.cleanTemp() }
            }
            Text("Widgets: use Apple Shortcuts for widget-related workflows because macOS blocks direct third-party widget editing.")
                .foregroundStyle(.secondary)
            if model.diagnosticsVisible {
                Text("Diagnostics: offline mode active, settings stored in UserDefaults.")
                    .font(.caption)
                    .foregroundStyle(.purple)
            }
        }
    }

    private var log: some View {
        VStack(alignment: .leading) {
            Text(model.status).font(.headline)
            List(model.logLines, id: \.self) { line in
                Text(line).font(.system(.caption, design: .monospaced))
            }
        }
    }
}
