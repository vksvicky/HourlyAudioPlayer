import Foundation

/// Pause/resume and control-bar visibility rules for Pong (unit-tested).
struct PongGameControlState: Equatable {
    var gameRunning = false
    var isPaused = false
    var gameOver = false
    var showInstructions = true

    var showsPauseButton: Bool {
        gameRunning && !isPaused && !gameOver
    }

    var showsResumeButton: Bool {
        gameRunning && isPaused && !gameOver
    }

    var showsPauseOrResumeButton: Bool {
        showsPauseButton || showsResumeButton
    }

    var shouldAdvanceSimulation: Bool {
        gameRunning && !isPaused && !gameOver
    }

    mutating func startMatch() {
        gameRunning = true
        isPaused = false
        gameOver = false
        showInstructions = false
    }

    mutating func pause() {
        guard gameRunning, !gameOver else { return }
        isPaused = true
    }

    mutating func resume() {
        guard gameRunning, !gameOver else { return }
        isPaused = false
    }

    mutating func endMatch() {
        gameRunning = false
        isPaused = false
        gameOver = true
    }

    mutating func resetToInstructions() {
        gameRunning = false
        isPaused = false
        gameOver = false
        showInstructions = true
    }
}
