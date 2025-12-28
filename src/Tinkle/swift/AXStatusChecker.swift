import AXSwift
import Foundation

@MainActor
class AXStatusChecker {
  private var relaunchRequired: Bool = false
  private var timer: Timer?

  init() {
    if !UIElement.isProcessTrusted(withPrompt: true) {
      timer = Timer.scheduledTimer(
        withTimeInterval: 3.0,
        repeats: true
      ) { (_: Timer) in
        if !UIElement.isProcessTrusted() {
          Task { @MainActor in
            self.relaunchRequired = true
          }
        } else {
          Task { @MainActor in
            if self.relaunchRequired {
              Relauncher.relaunch()
            }
          }
        }
      }

      timer!.fire()
    }
  }
}
