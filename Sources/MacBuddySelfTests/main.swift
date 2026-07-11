import Foundation
import MacBuddyCore

@discardableResult
func expect(_ condition: @autoclosure () -> Bool, _ message: String) -> Bool {
    if !condition() {
        fputs("FAIL: \(message)\n", stderr)
        exit(1)
    }
    return true
}

func temporaryFolder() throws -> URL {
    let url = FileManager.default.temporaryDirectory.appending(path: "MacBuddyTests-\(UUID().uuidString)", directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}

func testDryRunPlansMatchingFilesWithoutMovingThem() throws {
    let root = try temporaryFolder()
    defer { try? FileManager.default.removeItem(at: root) }
    let source = root.appending(path: "Downloads", directoryHint: .isDirectory)
    let destination = root.appending(path: "Organized", directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    let file = source.appending(path: "notes.pdf")
    try Data("hello".utf8).write(to: file)

    let service = OrganizerService(now: { Date(timeIntervalSince1970: 1000) })
    let plan = try service.plan(sourceFolder: source, destinationRoot: destination, rules: OrganizerRule.safeDefaults, dryRun: true)

    expect(plan.count == 1, "expected one organizer plan item")
    expect(plan.first?.ruleName == "Documents", "expected Documents rule")
    expect(plan.first?.destination.lastPathComponent == "notes.pdf", "expected same filename")

    let messages = try service.execute(plan)
    expect(messages.first?.contains("Preview") == true, "expected dry-run preview message")
    expect(FileManager.default.fileExists(atPath: file.path), "dry-run should not move source file")
}

func testAgeRulesSkipFreshFiles() throws {
    let root = try temporaryFolder()
    defer { try? FileManager.default.removeItem(at: root) }
    let source = root.appending(path: "Desktop", directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
    let file = source.appending(path: "photo.png")
    try Data().write(to: file)
    let now = Date(timeIntervalSince1970: 10_000)
    try FileManager.default.setAttributes([.modificationDate: now], ofItemAtPath: file.path)

    let rule = OrganizerRule(name: "Old Images", extensions: ["png"], destinationFolder: "Images", minimumAgeDays: 2, category: .images)
    let service = OrganizerService(now: { now })
    let plan = try service.plan(sourceFolder: source, destinationRoot: root, rules: [rule], dryRun: true)

    expect(plan.isEmpty, "fresh files should not match age rule")
}

func testMoodMapping() throws {
    let service = MoodService()
    expect(service.inferMood(from: "I need to study for my exam") == .focus, "study text should infer focus")

    let mapping = MoodWallpaperMapping(mood: .happy, wallpaperPath: "/tmp/happy.jpg")
    let url = try service.wallpaperURL(for: .happy, mappings: [mapping])
    expect(url.path == "/tmp/happy.jpg", "direct wallpaper path should resolve")

    do {
        _ = try service.wallpaperURL(for: .night, mappings: [])
        expect(false, "missing mapping should throw")
    } catch MacBuddyError.noWallpaperForMood(.night) {
        expect(true, "missing mapping threw expected error")
    }
}

do {
    try testDryRunPlansMatchingFilesWithoutMovingThem()
    try testAgeRulesSkipFreshFiles()
    try testMoodMapping()
    print("MacBuddy self-tests passed.")
} catch {
    fputs("FAIL: \(error.localizedDescription)\n", stderr)
    exit(1)
}
