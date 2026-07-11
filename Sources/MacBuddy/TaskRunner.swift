import AppKit
import Foundation

struct TaskRunner {
    func openDownloads() {
        NSWorkspace.shared.open(FileManager.default.homeDirectoryForCurrentUser.appending(path: "Downloads"))
    }

    func openDesktop() {
        NSWorkspace.shared.open(FileManager.default.homeDirectoryForCurrentUser.appending(path: "Desktop"))
    }

    func toggleAppearance() {
        let script = """
        tell application "System Events"
          tell appearance preferences
            set dark mode to not dark mode
          end tell
        end tell
        """
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }

    func cleanSafeTemporaryFiles() -> String {
        let temp = FileManager.default.temporaryDirectory
        let files = (try? FileManager.default.contentsOfDirectory(at: temp, includingPropertiesForKeys: [.contentModificationDateKey])) ?? []
        var removed = 0
        for file in files {
            guard let values = try? file.resourceValues(forKeys: [.contentModificationDateKey]),
                  let modified = values.contentModificationDate,
                  modified < Date().addingTimeInterval(-86_400) else { continue }
            try? FileManager.default.removeItem(at: file)
            removed += 1
        }
        return "Cleaned \(removed) old temp items."
    }
}
