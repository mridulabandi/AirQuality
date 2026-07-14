import SwiftUI


enum DesignTokens {
    static let actionGold = Color(red: 0.93, green: 0.75, blue: 0.25)
    static let cardBackground = Color.white
    static let rowDivider = Color(white: 0.88)
    static let secondaryText = Color(white: 0.45)

    static let cornerRadius: CGFloat = 10
    static let screenPadding: CGFloat = 16
}

struct ActionSquareButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(DesignTokens.actionGold)
        .cornerRadius(DesignTokens.cornerRadius)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(DesignTokens.secondaryText)
            Spacer()
            Text(value)
                .foregroundColor(valueColor)
        }
        .font(.system(size: 15))
        .padding(.vertical, 6)
    }
}


extension View {
    func errorAlert(message: String?) -> some View {
        modifier(ErrorAlertModifier(message: message))
    }
}

private struct ErrorAlertModifier: ViewModifier {
    let message: String?
    @State private var localMessage: String?

    func body(content: Content) -> some View {
        content
            .onChange(of: message) { _, newValue in
                if let newValue { localMessage = newValue }
            }
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { localMessage != nil },
                    set: { if !$0 { localMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) { localMessage = nil }
            } message: {
                Text(localMessage ?? "")
            }
    }
}
