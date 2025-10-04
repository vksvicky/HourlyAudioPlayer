import SwiftUI
import AppKit

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            applyTheme()
        }
    }
    
    private init() {
        // Load saved theme preference or default to light theme
        if let savedTheme = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool {
            self.isDarkMode = savedTheme
        } else {
            // Default to light theme
            self.isDarkMode = false
        }
        applyTheme()
    }
    
    private func applyTheme() {
        // Apply the theme to the app
        if isDarkMode {
            NSApp.appearance = NSAppearance(named: .darkAqua)
        } else {
            NSApp.appearance = NSAppearance(named: .aqua)
        }
        
        // Force all windows to refresh their appearance
        DispatchQueue.main.async {
            for window in NSApp.windows {
                window.appearance = NSApp.appearance
                // Force the window to redraw
                window.invalidateShadow()
                window.displayIfNeeded()
            }
        }
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
    
    func forceRefresh() {
        applyTheme()
    }
    
    var themeIcon: String {
        return isDarkMode ? "moon.fill" : "sun.max.fill"
    }
    
    var themeName: String {
        return isDarkMode ? "Dark" : "Light"
    }
}
