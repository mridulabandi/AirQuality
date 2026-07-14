import SwiftUI

struct BookingSummaryScreenView: View {
    @ObservedObject var viewModel: BookingResultViewModel
    let onViewHistory: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let booking = viewModel.booking {
                locationBlock(letter: "A", name: booking.a.name, aqi: booking.a.aqi)
                Divider().background(DesignTokens.rowDivider).padding(.vertical, 12)
                locationBlock(letter: "B", name: booking.b.name, aqi: booking.b.aqi)

                Spacer()

                InfoRow(label: "price", value: String(format: "%.0f", booking.price))
                    .font(.system(size: 16, weight: .semibold))
            } else {
                Spacer()
            }

            ActionSquareButton(title: "V") {
                onViewHistory()
            }
            .frame(height: 50)
            .padding(.top, 16)
        }
        .padding(DesignTokens.screenPadding)
        .task { await viewModel.createBooking() }
        .errorAlert(message: viewModel.errorMessage)
    }

    private func locationBlock(letter: String, name: String, aqi: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text(letter).font(.system(size: 17, weight: .bold))
                Text(name).font(.system(size: 17, weight: .bold))
            }
            InfoRow(label: "aqi", value: "\(aqi)")
        }
    }
}
