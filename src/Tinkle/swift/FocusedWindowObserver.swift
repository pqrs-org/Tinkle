import AXSwift
import AppKit

@MainActor
public final class FocusedWindowObserver {
  public typealias Callback = (
    _ frame: CGRect,
    _ runningApplication: NSRunningApplication
  ) -> Void

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
        Task { @MainActor in
          self.addObservedApplication(runningApplication)
        }
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
        Task { @MainActor in
          self.addObservedApplication(runningApplication)
        }
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
        Task { @MainActor in
          self.observedApplications.removeValue(forKey: runningApplication.processIdentifier)
        }
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

@MainActor
private final class ObservedApplication {
  private let application: Application?
  private var observer: Observer?
  private let runningApplication: NSRunningApplication
  private let callback: FocusedWindowObserver.Callback

  init(runningApplication: NSRunningApplication, callback: @escaping FocusedWindowObserver.Callback)
    throws
  {
    self.runningApplication = runningApplication
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
        callback(
          axRectToNativeRect(CGRect(origin: position!, size: size!)),
          runningApplication)
      }
    } catch {
      print("UIElement.attribute error: \(error)")
    }
  }

  func axRectToNativeRect(_ axRect: CGRect) -> CGRect {
    //
    // AX position (AP) and Native position (NP)
    //
    // - AX position:     Relative to the top-left of the main screen.
    // - Native position: Relative to the bottom-left of the main screen.
    //
    // ============================================================
    //
    //                   (AP:500,-800)
    //                     AP-----500---------+
    //                     |                  |
    //                    800   screens[1]    |
    //                     |                  |
    //  (AP:0,0)           |                  |
    //  AP-----500---------NP-----------------+
    //  |                  |(NP:500,500)
    // 500   screens[0]    |
    //  |                  |
    //  NP-----------------+
    //  (NP:0,0)
    //
    // ============================================================
    //
    // For example, AP(600,-200) == NP(600,700).
    //

    let screens = NSScreen.screens
    if screens.isEmpty {
      return CGRect.zero
    }

    let primaryScreen = screens[0]
    let axOriginMaxY = primaryScreen.frame.maxY

    return CGRect(
      x: axRect.origin.x,
      y: axOriginMaxY - axRect.maxY,
      width: axRect.width,
      height: axRect.height)
  }
}
