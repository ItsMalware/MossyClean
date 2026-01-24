import SwiftUI

struct Theme {
    static let primaryBackground = Color(hex: "0A0A0A")     // Ultra-Deep Slate
    static let secondaryBackground = Color(hex: "1C1C1C")   // Carbon Fiber
    static let accentColor = Color(hex: "98A66E")           // Vivid Moss
    static let warnColor = Color(hex: "D27D2D")             // Polished Copper
    static let textColor = Color(hex: "F2F2F2")             // Pure Steel
    static let subtleTextColor = Color(hex: "8E8E93")       // Slate Gray
    
    struct IndustrialBorder: ViewModifier {
        var cornerRadius: CGFloat = 12
        var opacity: Double = 0.3
        
        func body(content: Content) -> some View {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [Theme.accentColor.opacity(opacity), Theme.textColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Theme.primaryBackground.opacity(0.5), lineWidth: 0.5)
                        .padding(0.5)
                )
        }
    }
    
    struct GlassBackground: ViewModifier {
        func body(content: Content) -> some View {
            content
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .modifier(Theme.IndustrialBorder())
        }
    }
    
    struct MeshGradient: View {
        @State private var animate = false
        
        var body: some View {
            ZStack {
                Theme.primaryBackground.edgesIgnoringSafeArea(.all)
                
                // Living Industrial Mesh
                ZStack {
                    Circle()
                        .fill(Theme.accentColor.opacity(0.12))
                        .frame(width: 600, height: 600)
                        .offset(x: animate ? -100 : 100, y: animate ? -100 : 100)
                        .blur(radius: 100)
                    
                    Circle()
                        .fill(Theme.warnColor.opacity(0.05))
                        .frame(width: 400, height: 400)
                        .offset(x: animate ? 150 : -150, y: animate ? 50 : -50)
                        .blur(radius: 80)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
                        animate.toggle()
                    }
                }
            }
        }
    }
    
    struct MossyGrowth: View {
        var body: some View {
            ZStack {
                // Background "organic" glow
                Theme.accentColor.opacity(0.15)
                    .frame(height: 120)
                    .blur(radius: 40)
                    .offset(y: 40)
                
                HStack(spacing: -12) {
                    ForEach(0..<10) { i in
                        Image(systemName: i % 2 == 0 ? "leaf.fill" : "tent.fill")
                            .font(.system(size: CGFloat(18 + (i % 3 * 6))))
                            .foregroundColor(Theme.accentColor.opacity(0.7 - Double(i) * 0.04))
                            .rotationEffect(.degrees(Double(i) * 12 - 50))
                            .offset(y: CGFloat(sin(Double(i) * 1.5) * 8) + 15)
                            .blur(radius: 0.3)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .offset(y: 10) // Reduced offset to stay within 150px height
        }
    }
    
    struct MascotEffect: ViewModifier {
        @State private var isFloating = false
        
        func body(content: Content) -> some View {
            content
                .offset(y: isFloating ? -4 : 4)
                .animation(Animation.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isFloating)
                .onAppear { isFloating = true }
        }
    }
    
    // Pro Max Micro-Interaction Modifiers
    struct HapticPulse: ViewModifier {
        var isActive: Bool
        func body(content: Content) -> some View {
            content
                .scaleEffect(isActive ? 0.98 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isActive)
        }
    }
}

// Inter-inspired Typography Extensions
extension Font {
    static let industrialLargeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let industrialTitle = Font.system(size: 24, weight: .semibold, design: .rounded)
    static let industrialHeadline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let industrialBody = Font.system(size: 15, weight: .regular, design: .default)
    static let industrialMono = Font.system(size: 12, weight: .medium, design: .monospaced)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
