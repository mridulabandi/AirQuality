import SwiftUI

/// Screen 4 — monthly history. Matches the wireframe: "Total Count" /
/// "Total Price" side-by-side header, then a list of A/B row pairs.
struct HistoryScreenView: View {
    @ObservedObject var viewModel: HistoryViewModel
    let onSelectBooking: (Booking) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Count").font(.system(size: 13)).foregroundColor(DesignTokens.secondaryText)
                    Text("\(viewModel.totalCount)").font(.system(size: 17, weight: .semibold))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Total Price").font(.system(size: 13)).foregroundColor(DesignTokens.secondaryText)
                    Text(String(format: "%.0f", viewModel.totalPrice)).font(.system(size: 17, weight: .semibold))
                }
            }
            .padding(DesignTokens.screenPadding)

            Divider().background(DesignTokens.rowDivider)

            List(Array(viewModel.bookings.enumerated()), id: \.offset) { _, booking in
                Button {
                    onSelectBooking(booking)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text("A").font(.system(size: 14, weight: .bold))
                            Text(booking.a.name).font(.system(size: 14))
                        }
                        HStack(spacing: 8) {
                            Text("B").font(.system(size: 14, weight: .bold))
                            Text(booking.b.name).font(.system(size: 14))
                        }
                    }
                    .foregroundColor(.black)
                    .padding(.vertical, 6)
                }
            }
            .listStyle(.plain)
        }
        .task { await viewModel.loadCurrentMonth() }
        .errorAlert(message: viewModel.errorMessage)
    }
}
