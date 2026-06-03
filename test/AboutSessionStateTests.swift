import XCTest
@testable import HourlyAudioPlayer

final class AboutSessionStateTests: XCTestCase {

    func test_givenPongVisible_whenReset_thenShowsAboutPanel() {
        let session = AboutSessionState()
        for _ in 0..<5 { _ = session.registerIconTap(threshold: 6) }
        XCTAssertTrue(session.registerIconTap(threshold: 6))
        XCTAssertTrue(session.showPongGame)

        session.reset()

        XCTAssertFalse(session.showPongGame)
        XCTAssertEqual(session.iconClickCount, 0)
    }

    func test_givenPongVisible_whenReturnFromPong_thenHidesGame() {
        let session = AboutSessionState()
        for _ in 0..<5 { _ = session.registerIconTap(threshold: 6) }
        XCTAssertTrue(session.registerIconTap(threshold: 6))

        session.returnFromPong()

        XCTAssertFalse(session.showPongGame)
        XCTAssertEqual(session.iconClickCount, 0)
    }

    func test_givenFiveTaps_whenSixthTap_thenUnlocksPong() {
        let session = AboutSessionState()
        for _ in 0..<5 {
            XCTAssertFalse(session.registerIconTap())
        }

        XCTAssertTrue(session.registerIconTap())
        XCTAssertTrue(session.showPongGame)
    }
}
