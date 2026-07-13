import SwiftUI

/// Screen 2 — nickname assignment for a single slot (A or B), matching the
/// wireframe: bold "A  location name" header, "aqi   0" row, nickname field,
/// gold action button at the bottom.
struct NicknameScreenView: View {
    @ObservedObject var viewModel: NicknameViewModel
    let onDone: () -> Void

    @State private var nickname: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(slotLetter)
                    .font(.system(size: 17, weight: .bold))
                Text(viewModel.addressName)
                    .font(.system(size: 17, weight: .bold))
            }
            .padding(.top, 20)

            InfoRow(label: "aqi", value: "\(viewModel.capturedAQI)")

            Divider().background(DesignTokens.rowDivider)

            Spacer()

            TextField("nickname", text: $nickname)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(DesignTokens.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius).stroke(DesignTokens.rowDivider))
                .onChange(of: nickname) { _, newValue in
                    nickname = viewModel.sanitizedInput(newValue)
                }

            ActionSquareButton(title: "V") {
                viewModel.save(nickname: nickname)
                onDone()
            }
            .frame(height: 50)
            .padding(.top, 12)
        }
        .padding(DesignTokens.screenPadding)
        .onAppear { nickname = viewModel.currentNickname }
    }

    private var slotLetter: String {
        viewModel.slot == .a ? "A" : "B"
    }
}
