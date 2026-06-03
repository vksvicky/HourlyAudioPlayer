import Combine
import Foundation

/// About easter-egg presentation state (unit-tested; reset when About window reopens).
final class AboutSessionState: ObservableObject, Equatable {
    @Published var iconClickCount = 0
    @Published var showPongGame = false

    static func == (lhs: AboutSessionState, rhs: AboutSessionState) -> Bool {
        lhs.iconClickCount == rhs.iconClickCount && lhs.showPongGame == rhs.showPongGame
    }

    func reset() {
        iconClickCount = 0
        showPongGame = false
    }

    func registerIconTap(threshold: Int = 6) -> Bool {
        iconClickCount += 1
        if iconClickCount >= threshold {
            showPongGame = true
            return true
        }
        return false
    }

    func returnFromPong() {
        showPongGame = false
        iconClickCount = 0
    }
}
