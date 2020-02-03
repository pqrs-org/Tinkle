import Foundation

public struct OpenAtLogin {
    public static var enabled: Bool {
        get {
            guard let url = URL(string: Bundle.main.bundlePath) else {
                return false
            }
            return OpenAtLoginObjc.enabled(url)
        }
        set {
            let bundlePath = Bundle.main.bundlePath

            // Skip if the current app is not the distributed file.

            if bundlePath.hasSuffix("/Build/Products/Debug/Tinkle.app") || /* from Xcode */
                bundlePath.hasSuffix("/Build/Products/Release/Tinkle.app") || /* from Xcode */
                bundlePath.hasSuffix("/build/Release/Tinkle.app") { /* from command line */
                print("Skip setting LaunchAtLogin.enabled for dev")
                return
            }

            guard let url = URL(string: Bundle.main.bundlePath) else {
                return
            }

            if newValue {
                OpenAtLoginObjc.enable(url)
            } else {
                OpenAtLoginObjc.disable(url)
            }
        }
    }
}
