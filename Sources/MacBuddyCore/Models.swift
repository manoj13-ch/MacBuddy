import Foundation

public enum FileCategory: String, Codable, CaseIterable, Sendable {
    case images
    case videos
    case documents
    case audio
    case archives
    case code
    case other
}

public struct OrganizerRule: Codable, Equatable, Sendable, Identifiable {
    public var id: UUID
    public var name: String
    public var extensions: Set<String>
    public var destinationFolder: String
    public var minimumAgeDays: Int
    public var category: FileCategory

    public init(
        id: UUID = UUID(),
        name: String,
        extensions: Set<String>,
        destinationFolder: String,
        minimumAgeDays: Int = 0,
        category: FileCategory
    ) {
        self.id = id
        self.name = name
        self.extensions = Set(extensions.map { $0.lowercased() })
        self.destinationFolder = destinationFolder
        self.minimumAgeDays = minimumAgeDays
        self.category = category
    }
}

public struct OrganizerPlanItem: Equatable, Sendable, Identifiable {
    public var id: UUID
    public var source: URL
    public var destination: URL
    public var ruleName: String
    public var dryRun: Bool

    public init(id: UUID = UUID(), source: URL, destination: URL, ruleName: String, dryRun: Bool) {
        self.id = id
        self.source = source
        self.destination = destination
        self.ruleName = ruleName
        self.dryRun = dryRun
    }
}

public enum Mood: String, Codable, CaseIterable, Identifiable, Sendable {
    case calm
    case focus
    case happy
    case tired
    case night
    case inspired

    public var id: String { rawValue }
}

public struct MoodWallpaperMapping: Codable, Equatable, Sendable {
    public var mood: Mood
    public var wallpaperPath: String
    public var isDirectory: Bool

    public init(mood: Mood, wallpaperPath: String, isDirectory: Bool = false) {
        self.mood = mood
        self.wallpaperPath = wallpaperPath
        self.isDirectory = isDirectory
    }
}

public struct AppSettings: Codable, Equatable, Sendable {
    public var rules: [OrganizerRule]
    public var mappings: [MoodWallpaperMapping]
    public var organizeDownloads: Bool
    public var organizeDesktop: Bool
    public var enableMoodInference: Bool

    public init(
        rules: [OrganizerRule] = OrganizerRule.safeDefaults,
        mappings: [MoodWallpaperMapping] = [],
        organizeDownloads: Bool = true,
        organizeDesktop: Bool = false,
        enableMoodInference: Bool = true
    ) {
        self.rules = rules
        self.mappings = mappings
        self.organizeDownloads = organizeDownloads
        self.organizeDesktop = organizeDesktop
        self.enableMoodInference = enableMoodInference
    }
}

public extension OrganizerRule {
    static let safeDefaults: [OrganizerRule] = [
        OrganizerRule(name: "Images", extensions: ["jpg", "jpeg", "png", "gif", "heic", "webp"], destinationFolder: "Images", category: .images),
        OrganizerRule(name: "Documents", extensions: ["pdf", "doc", "docx", "txt", "rtf", "pages"], destinationFolder: "Documents", category: .documents),
        OrganizerRule(name: "Videos", extensions: ["mp4", "mov", "mkv", "avi"], destinationFolder: "Videos", category: .videos),
        OrganizerRule(name: "Archives", extensions: ["zip", "rar", "7z", "tar", "gz"], destinationFolder: "Archives", category: .archives),
        OrganizerRule(name: "Code", extensions: ["swift", "js", "ts", "java", "py", "html", "css"], destinationFolder: "Code", category: .code)
    ]
}
