import AXSwift
import AppKit

public final class FocusedWindowObserver {
  public typealias Callback = (_ frame: CGRect) -> Void

  private let callback: Callback
  private var observedApplications: [pid_t: ObservedApplication] = [:]

  init(callback: @escaping Callback) {
    self.callback = callback

    let sharedWorkspace = NSWorkspace.shared
    let notificationCenter = sharedWorkspace.notificationCenter

    //
    // NSWorkspace.didActivateApplicationNotification
    //

    notificationCenter.addObserver(
      forName: NSWorkspace.didActivateApplicationNotification,
      object: sharedWorkspace,
      queue: OperationQueue.main
    ) { note in
      guard let userInfo = note.userInfo else {
        print("Missing notification info on NSWorkspace.didActivateApplicationNotification")
        return
      }

      if let runningApplication = userInfo[NSWorkspace.applicationUserInfoKey]
        as? NSRunningApplication
      {
        self.addObservedApplication(runningApplication)
      }
    }

    //
    // NSWorkspace.didLaunchApplicationNotification
    //

    // We have to observe didLaunchApplicationNotification even didActivateApplicationNotification is observed.
    // Application.createObserver will be failed at application is just launched since
    // the didActivateApplicationNotification is posted before Application.createObserver is ready.
    // The didLaunchApplicationNotification is posted at properly timing,
    // so we can observe the application with it.

    notificationCenter.addObserver(
      forName: NSWorkspace.didLaunchApplicationNotification,
      object: sharedWorkspace,
      queue: OperationQueue.main
    ) { note in
      guard let userInfo = note.userInfo else {
        print("Missing notification info on NSWorkspace.didLaunchApplicationNotification")
        return
      }

      if let runningApplication = userInfo[NSWorkspace.applicationUserInfoKey]
        as? NSRunningApplication
      {
        self.addObservedApplication(runningApplication)
      }
    }

    //
    // NSWorkspace.didTerminateApplicationNotification
    //

    notificationCenter.addObserver(
      forName: NSWorkspace.didTerminateApplicationNotification,
      object: sharedWorkspace,
      queue: OperationQueue.main
    ) { note in
      guard let userInfo = note.userInfo else {
        print("Missing notification info on NSWorkspace.didTerminateApplicationNotification")
        return
      }

      //
      // Update observedApplications
      //

      if let runningApplication = userInfo[NSWorkspace.applicationUserInfoKey]
        as? NSRunningApplication
      {
        self.observedApplications.removeValue(forKey: runningApplication.processIdentifier)
      }
    }
  }

  private func addObservedApplication(_ runningApplication: NSRunningApplication) {
    do {
      if observedApplications.index(forKey: runningApplication.processIdentifier) == nil {
        // ObservedApplication constructor might throw an exception if the application is just launched.
        // Thus, we append observedApplication only when ObservedApplication is created without error
        // in order to retry ObservedApplication creation at next didActivateApplicationNotification or
        // didLaunchApplicationNotification.

        let observedApplication = try ObservedApplication(
          runningApplication: runningApplication,
          callback: callback)
        observedApplications[runningApplication.processIdentifier] = observedApplication
        print("ObservedApplication is created for \(runningApplication.processIdentifier)")
      }

      observedApplications[runningApplication.processIdentifier]!.emit()
    } catch {
      print("ObservedApplication error: \(error)")
    }
  }
}

private final class ObservedApplication {
  private let application: Application?
  private var observer: Observer?
  private let callback: FocusedWindowObserver.Callback

  init(runningApplication: NSRunningApplication, callback: @escaping FocusedWindowObserver.Callback)
    throws
  {
    self.callback = callback

    application = Application(runningApplication)
    observer = application?.createObserver { (_, _, event: AXNotification, _) in
      if event == .focusedWindowChanged {
        Task { @MainActor in
          self.emit()
        }
      }
    }

    try observer?.addNotification(.focusedWindowChanged, forElement: application!)
  }

  func emit() {
    do {
      let window: UIElement? = try application?.attribute(kAXFocusedWindowAttribute)
      let position: CGPoint? = try window?.attribute(kAXPositionAttribute)
      let size: CGSize? = try window?.attribute(kAXSizeAttribute)

      if position != nil, size != nil {
        callback(axRectToNativeRect(CGRect(origin: position!, size: size!)))
      }
    } catch {
      print("UIElement.attribute error: \(error)")
    }
  }

  func axRectToNativeRect(_ axRect: CGRect) -> CGRect {
    //
    // AX position
    //
    // screen #0   0,0 ---------------------
    //              |
    //              |
    //              |    (500,500)
    //              |
    //              |
    // screen #1   0,1280 ------------------
    //              |
    //              |
    //              |    (500,1780)
    //              |
    //              |

    //
    // Native position
    //
    //              |
    //              |
    //              |    (500,500)
    //              |
    //              |
    // screen #0   0,0 ---------------------
    //              |
    //              |
    //              |    (500,-500)
    //              |
    //              |
    // screen #1   0,-1280 ------------------
    //

    let screens = NSScreen.screens
    if screens.isEmpty {
      return CGRect.zero
    }

    for screen in screens {
      let screenAXPosition = CGPoint(
        x: screen.frame.minX,
        y: screens[0].frame.height - screen.frame.maxY)
      let screenAXRect = CGRect(origin: screenAXPosition, size: screen.frame.size)
      // print("screenAXRect \(screenAXRect) \(screen.frame)")

      if screenAXRect.contains(axRect.origin) {
        return CGRect(
          x: axRect.origin.x,
          y: screen.frame.maxY - axRect.height - (axRect.minY - screenAXPosition.y),
          width: axRect.width,
          height: axRect.height)
      }
    }

    return axRect
  }
}
