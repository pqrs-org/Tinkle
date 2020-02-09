import AXSwift
import Foundation

class AXStatusChecker {
    private let timer: Timer

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0,
                                     repeats: true)
        { (_: Timer) in
            print("hello")
        }
    }
}
