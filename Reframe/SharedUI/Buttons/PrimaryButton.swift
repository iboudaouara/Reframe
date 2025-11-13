import SwiftUI

struct PrimaryButton: View {
    let title: LocalizedStringKey
    let action: () -> Void

    init(title: LocalizedStringKey, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: {
            print("PrimaryButton tapped: \(title)")
            action()
        }) {
            buttonContent
        }
    }

    private var buttonContent: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Group {
                    Color.black
                }
            )
            .overlay(
                Capsule().stroke(Color.white, lineWidth: 1)
            )
            .clipShape(Capsule())
            .frame(maxWidth: 160)
    }
}

struct AppButton: View {
    enum Style {
        case primary
        case secondary
    }

    let title: LocalizedStringKey
    let style: Style
    let action: () -> Void

    init(_ title: LocalizedStringKey, style: Style = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: {
            print("AppButton tapped: \(title) [\(style)]")
            action()
        }) {
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity)
            .padding()
            .background(background)
            .overlay(
                Capsule().stroke(border, lineWidth: 1)
            )
            .clipShape(Capsule())
            .frame(maxWidth: 160)
    }

    private var foreground: Color {
        switch style {
        case .primary: return .white
        case .secondary: return .black
        }
    }

    private var background: Color {
        switch style {
        case .primary: return .black
        case .secondary: return .white
        }
    }

    private var border: Color {
        switch style {
        case .primary: return .white
        case .secondary: return .black
        }
    }
}

#Preview {
    HStack {
        AppButton("Login", style: .primary, action: {})
        AppButton("Sign Up", style: .secondary, action: {})
    }
}
