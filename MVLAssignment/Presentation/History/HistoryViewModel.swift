//
//  HistoryViewModel.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//


import Foundation
import Combine

final class HistoryViewModel: ObservableObject {
    private let fetchBookingHistoryUseCase: FetchBookingHistoryUseCase

    @Published private(set) var bookings: [Booking] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    var totalCount: Int { bookings.count }
    var totalPrice: Double { bookings.reduce(0) { $0 + $1.price } }

    init(fetchBookingHistoryUseCase: FetchBookingHistoryUseCase) {
        self.fetchBookingHistoryUseCase = fetchBookingHistoryUseCase
    }

    @MainActor
    func loadCurrentMonth() async {
        isLoading = true
        defer { isLoading = false }
        let now = Calendar.current.dateComponents([.year, .month], from: Date())
        do {
            bookings = try await fetchBookingHistoryUseCase.execute(
                year: now.year ?? 2020,
                month: now.month ?? 1
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func booking(at index: Int) -> Booking {
        bookings[index]
    }
}
