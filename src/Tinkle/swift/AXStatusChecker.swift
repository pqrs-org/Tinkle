import AXSwift
import Foundation

class AXStatusChecker {
  private var relaunchRequired: Bool
  private var timer: Timer?

  init() {
    relaunchRequired = false

    timer = Timer.scheduledTimer(
      withTimeInterval: 3.0,
      repeats: true
    ) { (_: Timer) in
      if !UIElement.isProcessTrusted() {
        self.relaunchRequired = true
      } else {
        if self.relaunchRequired {
          Relauncher.relaunch()
        }
      }
    }

    timer!.fire()
  }
}
