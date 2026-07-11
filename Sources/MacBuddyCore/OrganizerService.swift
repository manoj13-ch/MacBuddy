import Foundation

public enum MacBuddyError: Error, LocalizedError, Sendable {
    case folderMissing(URL)
    case destinationUnavailable(URL)
    case noWallpaperForMood(Mood)
    case scriptFailed(String)

    public var errorDescription: String? {
        switch self {
        case .folderMissing(let url): "Folder not found: \(url.path)"
        case .destinationUnavailable(let url): "Could not create destination: \(url.path)"
        case .noWallpaperForMood(let mood): "No wallpaper configured for \(mood.rawValue)."
        case .scriptFailed(let message): message
        }
    }
}

public struct OrganizerService {
    public var fileManager: FileManager
    public var calendar: Calendar
    public var now: @Sendable () -> Date

    public init(fileManager: FileManager = .default, calendar: Calendar = .current, now: @escaping @Sendable () -> Date = Date.init) {
        self.fileManager = fileManager
        self.calendar = calendar
        self.now = now
    }

    public func plan(sourceFolder: URL, destinationRoot: URL, rules: [OrganizerRule], dryRun: Bool) throws -> [OrganizerPlanItem] {
        guard fileManager.fileExists(atPath: sourceFolder.path) else {
            throw MacBuddyError.folderMissing(sourceFolder)
        }

        let files = try fileManager.contentsOfDirectory(
            at: sourceFolder,
            includingPropertiesForKeys: [.contentModificationDateKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        return try files.compactMap { file in
            let values = try file.resourceValues(forKeys: [.contentModificationDateKey, .isDirectoryKey])
            guard values.isDirectory != true else { return nil }
            guard let rule = matchingRule(for: file, modifiedAt: values.contentModificationDate, rules: rules) else { return nil }
            let destinationFolder = destinationRoot.appending(path: rule.destinationFolder, directoryHint: .isDirectory)
            let destination = destinationFolder.appending(path: uniqueName(for: file, in: destinationFolder), directoryHint: .notDirectory)
            return OrganizerPlanItem(source: file, destination: destination, ruleName: rule.name, dryRun: dryRun)
        }
    }

    public func execute(_ items: [OrganizerPlanItem]) throws -> [String] {
        try items.map { item in
            if item.dryRun {
                return "Preview: \(item.source.lastPathComponent) -> \(item.destination.path)"
            }
            let folder = item.destination.deletingLastPathComponent()
            try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            try fileManager.moveItem(at: item.source, to: item.destination)
            return "Moved: \(item.source.lastPathComponent) -> \(item.destination.path)"
        }
    }

    private func matchingRule(for file: URL, modifiedAt: Date?, rules: [OrganizerRule]) -> OrganizerRule? {
        let ext = file.pathExtension.lowercased()
        return rules.first { rule in
            guard rule.extensions.contains(ext) else { return false }
            guard rule.minimumAgeDays > 0 else { return true }
            guard let modifiedAt else { return false }
            let cutoff = calendar.date(byAdding: .day, value: -rule.minimumAgeDays, to: now()) ?? now()
            return modifiedAt <= cutoff
        }
    }

    private func uniqueName(for file: URL, in folder: URL) -> String {
        let base = file.deletingPathExtension().lastPathComponent
        let ext = file.pathExtension
        var candidate = file.lastPathComponent
        var index = 2
        while fileManager.fileExists(atPath: folder.appending(path: candidate).path) {
            candidate = ext.isEmpty ? "\(base)-\(index)" : "\(base)-\(index).\(ext)"
            index += 1
        }
        return candidate
    }
}
