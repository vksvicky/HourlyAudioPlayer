import SwiftUI

struct AboutWindow: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 14) {
            // Close button in top-right corner
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                })
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding(.top, -10)
            .padding(.trailing, -10)
            // App Icon
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 64, height: 64)
                .shadow(radius: 2)
            
            // App Name
            Text("Hourly Audio Player")
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundColor(.primary)
            
            // Version Information
            Text("Version 1.0.0 (Build 1)")
                .font(.system(size: 14, weight: .regular, design: .default))
                .foregroundColor(.primary)
            
            // Copyright Information
            VStack(spacing: 4) {
                Text("Copyright © 2025 CycleRunCode.")
                Text("All rights reserved.")
            }
            .font(.system(size: 12, weight: .regular, design: .default))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            
            // Contact Information
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                    Link("https://cycleruncode.club", destination: URL(string: "https://cycleruncode.club")!)
                        .foregroundColor(.blue)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "envelope")
                        .foregroundColor(.blue)
                    Link("support@cycleruncode.club", destination: URL(string: "mailto:support@cycleruncode.club")!)
                        .foregroundColor(.blue)
                }
            }
            .font(.system(size: 12, weight: .regular, design: .default))
            .padding(.top, 8)
        }
        .padding(30)
        .frame(width: 320, height: 380)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    AboutWindow()
}
