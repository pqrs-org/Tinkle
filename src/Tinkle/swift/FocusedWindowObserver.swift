import AppKit
import AXSwift

public final class FocusedWindowObserver {
    public typealias Callback = (_ frame: CGRect) -> Void

    private var observedApplications: [pid_t: ObservedApplication] = [:]
    private var activeApplicationProcessIdentifier: pid_t = 0

    init(callback: @escaping Callback) {
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
            let runningApplication = userInfo[NSWorkspace.applicationUserInfoKey] as! NSRunningApplication

            //
            // Update activeApplicationProcessIdentifier
            //

            self.activeApplicationProcessIdentifier = runningApplication.processIdentifier

            //
            // Update applicationObservers
            //

            if self.observedApplications.index(forKey: runningApplication.processIdentifier) == nil {
                let observedApplication = ObservedApplication(runningApplication: runningApplication,
                                                              callback: callback)
                self.observedApplications[runningApplication.processIdentifier] = observedApplication
                print("ObservedApplication is created for \(runningApplication.processIdentifier)")
            }

            self.observedApplications[runningApplication.processIdentifier]!.emit()
        }

        //
        // NSWorkspace.didDeactivateApplicationNotification
        //

        notificationCenter.addObserver(
            forName: NSWorkspace.didDeactivateApplicationNotification,
            object: sharedWorkspace,
            queue: OperationQueue.main
        ) { note in
            guard let userInfo = note.userInfo else {
                print("Missing notification info on NSWorkspace.didActivateApplicationNotification")
                return
            }
            let runningApplication = userInfo[NSWorkspace.applicationUserInfoKey] as! NSRunningApplication

            //
            // Update activeApplicationProcessIdentifier
            //

            if self.activeApplicationProcessIdentifier == runningApplication.processIdentifier {
                self.activeApplicationProcessIdentifier = 0
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
            let runningApplication = userInfo[NSWorkspace.applicationUserInfoKey] as! NSRunningApplication

            //
            // Update applicationObservers
            //

            self.observedApplications.removeValue(forKey: runningApplication.processIdentifier)
        }
    }
}

private final class ObservedApplication {
    private let application: Application?
    private var observer: Observer?
    private let callback: FocusedWindowObserver.Callback

    init(runningApplication: NSRunningApplication, callback: @escaping FocusedWindowObserver.Callback) {
        self.callback = callback

        application = Application(runningApplication)
        observer = application?.createObserver { (_: Observer,
                                                  _: UIElement,
                                                  event: AXNotification,
                                                  _: [String: AnyObject]?) in
            if event == .focusedWindowChanged {
                self.emit()
            }
        }

        do {
            try observer?.addNotification(.focusedWindowChanged, forElement: application!)
        } catch {
            print("Observer.addNotification error: \(error)")
        }
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

        for (index, screen) in screens.enumerated() {
            var screenAXPosition = CGPoint(x: screen.frame.minX, y: 0)
            if index > 0 {
                if screen.frame.minY < 0 {
                    screenAXPosition.y = screens[0].frame.height + screen.frame.maxY
                } else {
                    screenAXPosition.y = screens[0].frame.height - screen.frame.maxY
                }
            }

            let screenAXRect = CGRect(origin: screenAXPosition, size: screen.frame.size)
            // print("screenAXRect \(index) \(screenAXRect) \(screen.frame)")

            if screenAXRect.contains(axRect.origin) {
                return CGRect(x: axRect.origin.x,
                              y: screen.frame.maxY - axRect.height - (axRect.minY - screenAXPosition.y),
                              width: axRect.width,
                              height: axRect.height)
            }
        }

        return axRect
    }
}
