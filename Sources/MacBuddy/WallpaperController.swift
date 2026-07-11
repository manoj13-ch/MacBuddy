import Foundation
import MacBuddyCore

struct WallpaperController {
    func apply(_ url: URL) throws {
        let script = """
        tell application "System Events"
          tell every desktop
            set picture to "\(url.path)"
          end tell
        end tell
        """
        var error: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&error)
        if let error {
            throw MacBuddyError.scriptFailed(error.description)
        }
    }
}
