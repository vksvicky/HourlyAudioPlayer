import SwiftUI

struct PongGameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    var onBackToAbout: (() -> Void)?
    @State private var ballPosition = CGPoint(x: 160, y: 200)
    @State private var ballVelocity = CGVector(dx: 3, dy: 2)
    @State private var playerPaddleY: CGFloat = 200
    @State private var aiPaddleY: CGFloat = 200
    @State private var playerScore = 0
    @State private var aiScore = 0
    @State private var gameRunning = false
    @State private var gameOver = false
    @State private var winner = ""
    @State private var showInstructions = true
    @State private var keyboardMonitor: Any?
    @State private var isUpKeyPressed = false
    @State private var isDownKeyPressed = false

    private let gameWidth: CGFloat = 320
    private let gameHeight: CGFloat = 380
    private let paddleWidth: CGFloat = 10
    private let paddleHeight: CGFloat = 60
    private let ballSize: CGFloat = 8
    private let paddleSpeed: CGFloat = 10
    @State private var aiSpeed: CGFloat = 5
    private let targetScore = 5

    var body: some View {
        VStack(spacing: 0) {
            // Title and close
            HStack {
                Text("Pong")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button(action: {
                    dismiss()
                }, label: {
                    Text("×")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.red)
                })
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)

            // Score display
            HStack {
                Text("You: \(playerScore)")
                    .font(.headline)
                Spacer()
                Text("AI: \(aiScore)")
                    .font(.headline)
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            
            // Game area with overlays (always rendered to avoid layout shift)
            ZStack {
                    // Background
                    Rectangle()
                        .fill(Color(NSColor.controlBackgroundColor))
                        .frame(width: gameWidth, height: gameHeight - 80)

                    // Center line
                    Rectangle()
                        .fill(Color(NSColor.separatorColor))
                        .frame(width: 2, height: gameHeight - 80)
                        .opacity(0.3)

                    // Ball
                    Circle()
                        .fill(Color(NSColor.controlTextColor))
                        .frame(width: ballSize, height: ballSize)
                        .position(ballPosition)

                    // Player paddle (right side)
                    Rectangle()
                        .fill(Color(NSColor.controlTextColor))
                        .frame(width: paddleWidth, height: paddleHeight)
                        .position(x: gameWidth - 20, y: playerPaddleY)

                    // AI paddle (left side)
                    Rectangle()
                        .fill(Color(NSColor.controlTextColor))
                        .frame(width: paddleWidth, height: paddleHeight)
                        .position(x: 20, y: aiPaddleY)
                    
                    // Instructions Overlay
                    if showInstructions {
                        VStack(spacing: 12) {
                            Text("🎮 Pong Instructions")
                                .font(.title3)
                                .fontWeight(.bold)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("• Use ↑ and ↓ arrow keys to move your paddle")
                                Text("• First to 5 points wins!")
                                Text("• Click 'Start Game' to begin")
                            }
                            .font(.body)

                            Button("Start Game") {
                                showInstructions = false
                                startGame()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                        .padding(20)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(12)
                        .shadow(radius: 6)
                    }

                    // Game Over Overlay (centered with single action)
                    if gameOver {
                        VStack(spacing: 16) {
                            Text(winner)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(NSColor.controlTextColor))

                            Button {
                                resetGame()
                            } label: {
                                Text("Play Again")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .controlSize(.large)
                        }
                        .padding(24)
                        .background(Color(NSColor.controlBackgroundColor).opacity(0.9))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    }

                    // Pause button overlay at bottom (no layout shift)
                    VStack {
                        Spacer()
                        if gameRunning {
                            Button("Pause") { gameRunning = false }
                                .buttonStyle(.bordered)
                                .padding(.bottom, 6)
                        }
                    }
                }
                .frame(width: gameWidth, height: gameHeight - 80)
                .clipped()
            

            Spacer()
                }
                .frame(width: gameWidth, height: gameHeight)
                .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            resetGame()
            setupKeyboardMonitoring()
        }
        .onDisappear {
            stopKeyboardMonitoring()
        }
    }

    private func startGame() {
        gameRunning = true
        gameOver = false
        showInstructions = false
        randomizeAISpeed()
        ballPosition = CGPoint(x: gameWidth/2, y: gameHeight/2)
        ballVelocity = CGVector(dx: Bool.random() ? 3 : -3, dy: CGFloat.random(in: -2...2))

        // Start game timer
        Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { timer in
            if !gameRunning {
                timer.invalidate()
                return
            }

            updateGame()
        }
    }

    private func updateGame() {
        // Update ball position
        ballPosition.x += ballVelocity.dx
        ballPosition.y += ballVelocity.dy

        // Ball collision with top/bottom walls
        if ballPosition.y <= ballSize/2 || ballPosition.y >= gameHeight - 80 - ballSize/2 {
            ballVelocity.dy *= -1
        }

        // Ball collision with paddles
        let ballRect = CGRect(x: ballPosition.x - ballSize/2, y: ballPosition.y - ballSize/2,
                             width: ballSize, height: ballSize)
        let playerPaddleRect = CGRect(x: gameWidth - 20 - paddleWidth/2, y: playerPaddleY - paddleHeight/2,
                                     width: paddleWidth, height: paddleHeight)
        let aiPaddleRect = CGRect(x: 20 - paddleWidth/2, y: aiPaddleY - paddleHeight/2,
                                 width: paddleWidth, height: paddleHeight)

        if ballRect.intersects(playerPaddleRect) && ballVelocity.dx > 0 {
            ballVelocity.dx *= -1
            // Add some spin based on where the ball hits the paddle
            let hitPoint = (ballPosition.y - playerPaddleY) / (paddleHeight/2)
            ballVelocity.dy += hitPoint * 2
        }

        if ballRect.intersects(aiPaddleRect) && ballVelocity.dx < 0 {
            ballVelocity.dx *= -1
            // Add some spin based on where the ball hits the paddle
            let hitPoint = (ballPosition.y - aiPaddleY) / (paddleHeight/2)
            ballVelocity.dy += hitPoint * 2
        }

        // Score points
        if ballPosition.x < 0 {
            playerScore += 1
            resetBall()
        } else if ballPosition.x > gameWidth {
            aiScore += 1
            resetBall()
        }

        // Check for game over
        if playerScore >= targetScore {
            gameOver = true
            gameRunning = false
            winner = "You Win! 🎉"
        } else if aiScore >= targetScore {
            gameOver = true
            gameRunning = false
            winner = "AI Wins! 🤖"
        }

        // AI paddle movement
        if ballVelocity.dx < 0 { // Ball moving towards AI
            let targetY = ballPosition.y
            if aiPaddleY < targetY - 10 {
                aiPaddleY += aiSpeed
            } else if aiPaddleY > targetY + 10 {
                aiPaddleY -= aiSpeed
            }
        } else {
            // Move towards center when ball is moving away
            let centerY = gameHeight / 2
            if aiPaddleY < centerY - 5 {
                aiPaddleY += aiSpeed * 0.5
            } else if aiPaddleY > centerY + 5 {
                aiPaddleY -= aiSpeed * 0.5
            }
        }

        // Keep AI paddle in bounds
        aiPaddleY = max(paddleHeight/2, min(gameHeight - 80 - paddleHeight/2, aiPaddleY))
        
        // Smooth player paddle movement
        if isUpKeyPressed {
            playerPaddleY = max(paddleHeight/2, playerPaddleY - paddleSpeed)
        }
        if isDownKeyPressed {
            playerPaddleY = min(gameHeight - 80 - paddleHeight/2, playerPaddleY + paddleSpeed)
        }
    }

    private func resetBall() {
        ballPosition = CGPoint(x: gameWidth/2, y: gameHeight/2)
        ballVelocity = CGVector(dx: Bool.random() ? 3 : -3, dy: CGFloat.random(in: -2...2))
    }

    private func resetGame() {
        gameRunning = false
        gameOver = false
        playerScore = 0
        aiScore = 0
        ballPosition = CGPoint(x: gameWidth/2, y: gameHeight/2)
        playerPaddleY = gameHeight / 2
        aiPaddleY = gameHeight / 2
        winner = ""
        showInstructions = true
        randomizeAISpeed()
    }
    
    private func setupKeyboardMonitoring() {
        // Monitor key down events
        let keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if gameRunning && !gameOver {
                switch event.keyCode {
                case 126: // Up arrow
                    isUpKeyPressed = true
                    return nil // Consume the event
                case 125: // Down arrow
                    isDownKeyPressed = true
                    return nil // Consume the event
                default:
                    break
                }
            }
            return event
        }
        
        // Monitor key up events
        let keyUpMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { event in
            if gameRunning && !gameOver {
                switch event.keyCode {
                case 126: // Up arrow
                    isUpKeyPressed = false
                    return nil // Consume the event
                case 125: // Down arrow
                    isDownKeyPressed = false
                    return nil // Consume the event
                default:
                    break
                }
            }
            return event
        }
        
        // Store both monitors (we'll need to clean them up later)
        keyboardMonitor = [keyDownMonitor, keyUpMonitor]
    }
    
    private func stopKeyboardMonitoring() {
        if let monitors = keyboardMonitor as? [Any] {
            for monitor in monitors {
                NSEvent.removeMonitor(monitor)
            }
            keyboardMonitor = nil
        }
    }
    
    private func randomizeAISpeed() {
        // Random AI speed between 4 and 8 (challenging but fair)
        aiSpeed = CGFloat.random(in: 4...8)
    }
}

#Preview {
    PongGameView()
}
