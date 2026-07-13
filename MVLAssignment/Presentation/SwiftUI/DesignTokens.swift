import SwiftUI

/// Shared visual tokens pulled from the Figma wireframe screenshot, kept in
/// one place so all 5 screens stay visually consistent. Adjust these if the
/// real Figma file specifies exact hex values / fonts beyond what the
/// wireframe shows.
enum DesignTokens {
    static let actionGold = Color(red: 0.93, green: 0.75, blue: 0.25)
    static let cardBackground = Color.white
    static let rowDivider = Color(white: 0.88)
    static let secondaryText = Color(white: 0.45)

    static let cornerRadius: CGFloat = 10
    static let screenPadding: CGFloat = 16
}

/// The "V Button" component from the wireframe: a fixed-size gold square with
/// bold centered text, used identically across Screens 1, 2, and 3.
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

/// A left-label / right-value row, e.g. "aqi   80" or "nickname   home".
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
