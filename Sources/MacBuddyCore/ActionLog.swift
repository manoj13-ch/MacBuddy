import Foundation

public final class ActionLog: @unchecked Sendable {
    private let limit: Int
    private var entries: [String]

    public init(limit: Int = 80, entries: [String] = []) {
        self.limit = limit
        self.entries = entries
    }

    public func append(_ message: String) {
        let stamp = ISO8601DateFormatter().string(from: Date())
        entries.append("[\(stamp)] \(message)")
        if entries.count > limit {
            entries.removeFirst(entries.count - limit)
        }
    }

    public func all() -> [String] {
        entries
    }
}
