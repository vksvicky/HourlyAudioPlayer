import XCTest
@testable import HourlyAudioPlayer

final class PongGameControlStateTests: XCTestCase {

    func test_givenRunningGame_whenPause_thenMatchStillRunningAndResumeVisible() {
        var state = PongGameControlState()
        state.startMatch()

        state.pause()

        XCTAssertTrue(state.gameRunning, "Pause must not end the match (regression: pause hid all controls)")
        XCTAssertTrue(state.isPaused)
        XCTAssertFalse(state.showsPauseButton)
        XCTAssertTrue(state.showsResumeButton)
        XCTAssertFalse(state.shouldAdvanceSimulation)
    }

    func test_givenPausedGame_whenResume_thenSimulationResumes() {
        var state = PongGameControlState()
        state.startMatch()
        state.pause()

        state.resume()

        XCTAssertFalse(state.isPaused)
        XCTAssertTrue(state.showsPauseButton)
        XCTAssertTrue(state.shouldAdvanceSimulation)
    }

    func test_givenGameOver_whenPause_thenIgnored() {
        var state = PongGameControlState()
        state.startMatch()
        state.endMatch()

        state.pause()

        XCTAssertFalse(state.isPaused)
        XCTAssertFalse(state.showsResumeButton)
    }

    func test_givenInstructions_whenStartMatch_thenPauseAvailable() {
        var state = PongGameControlState()
        XCTAssertTrue(state.showInstructions)

        state.startMatch()

        XCTAssertTrue(state.showsPauseButton)
        XCTAssertFalse(state.showInstructions)
    }
}
