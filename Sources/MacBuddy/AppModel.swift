import Foundation
import MacBuddyCore

@MainActor
final class AppModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var selectedMood: Mood = .calm
    @Published var moodText = ""
    @Published var logLines: [String] = []
    @Published var status = "Ready"
    @Published var sparkleMode = false
    @Published var diagnosticsVisible = false

    private let store = SettingsStore()
    private let log = ActionLog()
    private let organizer = OrganizerService()
    private let moodService = MoodService()
    private let wallpaper = WallpaperController()
    private let tasks = TaskRunner()

    init() {
        settings = store.load()
        log.append("MacBuddy started offline.")
        logLines = log.all()
    }

    func save() {
        store.save(settings)
        append("Settings saved.")
    }

    func inferMood() {
        selectedMood = moodService.inferMood(from: moodText)
        sparkleMode = moodText.lowercased().contains("macbuddy sparkle mode")
        append("Mood inferred as \(selectedMood.rawValue).")
    }

    func applyWallpaper() {
        Task {
            do {
                let url = try moodService.wallpaperURL(for: selectedMood, mappings: settings.mappings)
                try wallpaper.apply(url)
                append("Wallpaper applied for \(selectedMood.rawValue).")
            } catch {
                append("Wallpaper skipped: \(error.localizedDescription)")
            }
        }
    }

    func organizeDownloads(dryRun: Bool = true) {
        runOrganizer(source: "Downloads", dryRun: dryRun)
    }

    func organizeDesktop(dryRun: Bool = true) {
        runOrganizer(source: "Desktop", dryRun: dryRun)
    }

    func openDownloads() { tasks.openDownloads() }
    func openDesktop() { tasks.openDesktop() }

    func toggleAppearance() {
        tasks.toggleAppearance()
        append("Appearance toggle requested.")
    }

    func cleanTemp() {
        append(tasks.cleanSafeTemporaryFiles())
    }

    private func runOrganizer(source: String, dryRun: Bool) {
        let sourceURL = FileManager.default.homeDirectoryForCurrentUser.appending(path: source, directoryHint: .isDirectory)
        let destination = sourceURL.appending(path: "MacBuddy Organized", directoryHint: .isDirectory)
        let rules = settings.rules
        Task.detached { [sourceURL, destination, rules, source, dryRun] in
            let organizer = OrganizerService()
            do {
                let plan = try organizer.plan(sourceFolder: sourceURL, destinationRoot: destination, rules: rules, dryRun: dryRun)
                let messages = try organizer.execute(plan)
                await MainActor.run {
                    messages.isEmpty ? self.append("No matching files in \(source).") : messages.forEach(self.append)
                }
            } catch {
                await MainActor.run { self.append("Organizer error: \(error.localizedDescription)") }
            }
        }
    }

    private func append(_ line: String) {
        status = line
        log.append(line)
        logLines = log.all()
    }
}
