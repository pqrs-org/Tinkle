import Foundation
import Sparkle

struct Updater {
    static func checkForUpdatesInBackground() {
        let url = feedURL(false)
        print("checkForUpdates \(url)")
        SUUpdater.shared().feedURL = url
        SUUpdater.shared()?.checkForUpdatesInBackground()
    }

    static func checkForUpdatesStableOnly() {
        let url = feedURL(false)
        print("checkForUpdates \(url)")
        SUUpdater.shared().feedURL = url
        SUUpdater.shared()?.checkForUpdates(self)
    }

    static func checkForUpdatesWithBetaVersion() {
        let url = feedURL(true)
        print("checkForUpdates \(url)")
        SUUpdater.shared().feedURL = url
        SUUpdater.shared()?.checkForUpdates(self)
    }

    private static func feedURL(_ includingBetaVersions: Bool) -> URL {
        if includingBetaVersions {
            return URL(string: "https://appcast.pqrs.org/tinkle-appcast-devel.xml")!
        }
        return URL(string: "https://appcast.pqrs.org/tinkle-appcast.xml")!
    }
}
