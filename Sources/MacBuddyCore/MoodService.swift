import Foundation

public struct MoodService: Sendable {
    public init() {}

    public func inferMood(from text: String) -> Mood {
        let words = text.lowercased()
        if words.contains("sleep") || words.contains("tired") || words.contains("exhausted") { return .tired }
        if words.contains("study") || words.contains("work") || words.contains("focus") || words.contains("exam") { return .focus }
        if words.contains("happy") || words.contains("great") || words.contains("excited") { return .happy }
        if words.contains("night") || words.contains("late") || words.contains("dark") { return .night }
        if words.contains("idea") || words.contains("create") || words.contains("inspired") { return .inspired }
        return .calm
    }

    public func wallpaperURL(for mood: Mood, mappings: [MoodWallpaperMapping]) throws -> URL {
        guard let mapping = mappings.first(where: { $0.mood == mood }) else {
            throw MacBuddyError.noWallpaperForMood(mood)
        }

        let url = URL(filePath: mapping.wallpaperPath)
        guard mapping.isDirectory else { return url }

        let files = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? []
        let image = files
            .filter { ["jpg", "jpeg", "png", "heic"].contains($0.pathExtension.lowercased()) }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .first
        return image ?? url
    }
}
