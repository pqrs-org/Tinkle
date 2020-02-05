import Foundation
import Sparkle

public struct Updater {
    static func checkForUpdatesInBackground() {
        SUUpdater.shared()
    }
}
