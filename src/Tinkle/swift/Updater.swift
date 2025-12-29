import AppKit
import Foundation
import OSLog

#if USE_SPARKLE
  import Sparkle
#endif

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier ?? "unknown",
  category: String(describing: Updater.self))

@MainActor
final class Updater: ObservableObject {
  static let shared = Updater()

  #if USE_SPARKLE
    private let updaterController: SPUStandardUpdaterController
    private let delegate = SparkleDelegate()
  #endif

  @Published var canCheckForUpdates = false

  init() {
    #if USE_SPARKLE
      updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: delegate,
        userDriverDelegate: delegate,
      )

      updaterController.updater.clearFeedURLFromUserDefaults()

      updaterController.updater.publisher(for: \.canCheckForUpdates)
        .assign(to: &$canCheckForUpdates)
    #endif
  }

  func checkForUpdatesInBackground() {
    #if USE_SPARKLE
      delegate.includingBetaVersions = false
      updaterController.updater.checkForUpdatesInBackground()
    #endif
  }

  func checkForUpdatesStableOnly() {
    #if USE_SPARKLE
      delegate.includingBetaVersions = false
      updaterController.checkForUpdates(nil)
    #endif
  }

  func checkForUpdatesWithBetaVersion() {
    #if USE_SPARKLE
      delegate.includingBetaVersions = true
      updaterController.checkForUpdates(nil)
    #endif
  }

  #if USE_SPARKLE
    private class SparkleDelegate: NSObject, SPUUpdaterDelegate,
      SPUStandardUserDriverDelegate
    {
      var includingBetaVersions = false

      func standardUserDriverWillShowModalAlert() {
        // While a modal alert is shown, the effect processing stops,
        // so the effect would remain visible in a frozen state.
        // Therefore, hide the effect before showing the modal alert.
        NotificationCenter.default.post(name: effectWindowShouldHide, object: nil)
      }

      func feedURLString(for updater: SPUUpdater) -> String? {
        var url = "https://appcast.pqrs.org/tinkle-appcast.xml"
        if includingBetaVersions {
          url = "https://appcast.pqrs.org/tinkle-appcast-devel.xml"
        }

        logger.info("feedURLString \(url)")

        return url
      }
    }
  #endif
}
