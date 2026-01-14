import SwiftUI

// MARK: - Glass Effect Modifier

extension View {
    /// Aplica efeito glass (translúcido) com blur e bordas
    func glassEffect(
        tintColor: Color = .white.opacity(0.1),
        blurRadius: CGFloat = 10,
        borderColor: Color = .white.opacity(0.2),
        borderWidth: CGFloat = 1,
        cornerRadius: CGFloat = 20,
        shadowRadius: CGFloat = 10
    ) -> some View {
        self
            .background(
                ZStack {
                    // Background translúcido
                    tintColor

                    // Blur effect
                    TranslucentBlurView()
                }
            )
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: .black.opacity(0.1), radius: shadowRadius, x: 0, y: 5)
    }

    /// Aplica efeito glass com gradiente
    func glassEffectWithGradient(
        colors: [Color] = [.white.opacity(0.15), .white.opacity(0.05)],
        blurRadius: CGFloat = 10,
        borderColor: Color = .white.opacity(0.2),
        borderWidth: CGFloat = 1,
        cornerRadius: CGFloat = 20,
        shadowRadius: CGFloat = 10
    ) -> some View {
        self
            .background(
                ZStack {
                    // Gradiente translúcido
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // Blur effect
                    TranslucentBlurView()
                }
            )
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: .black.opacity(0.1), radius: shadowRadius, x: 0, y: 5)
    }
}

// MARK: - Translucent Blur View

struct TranslucentBlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemUltraThinMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    var gradient: [Color]
    var borderColor: Color
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Blur effect primeiro (fundo)
                    TranslucentBlurView(style: .systemUltraThinMaterial)

                    // Gradiente translúcido por cima
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .cornerRadius(cornerRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [borderColor, borderColor.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}

extension View {
    func glassCard(
        gradient: [Color] = [.white.opacity(0.2), .white.opacity(0.05)],
        borderColor: Color = .white.opacity(0.3),
        cornerRadius: CGFloat = 20
    ) -> some View {
        modifier(GlassCardModifier(
            gradient: gradient,
            borderColor: borderColor,
            cornerRadius: cornerRadius
        ))
    }

    /// Aplica background com gradiente azul estilo messenger
    func messengerGradientBackground() -> some View {
        self
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.6, blue: 0.95),  // Azul claro no topo
                        Color(red: 0.2, green: 0.35, blue: 0.65), // Azul médio
                        Color(red: 0.1, green: 0.2, blue: 0.45)   // Azul escuro na base
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
    }
}
