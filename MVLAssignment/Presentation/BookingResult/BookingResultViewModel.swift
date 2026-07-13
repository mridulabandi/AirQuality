//
//  BookingResultViewModel.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//


import Foundation
import Combine

final class BookingResultViewModel: ObservableObject {
    private let createBookingUseCase: CreateBookingUseCase
    private let flowStore: BookingFlowStore

    @Published private(set) var booking: Booking?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    init(createBookingUseCase: CreateBookingUseCase, flowStore: BookingFlowStore) {
        self.createBookingUseCase = createBookingUseCase
        self.flowStore = flowStore
    }

    @MainActor
    func createBooking() async {
        guard let slotA = flowStore.location(for: .a), let slotB = flowStore.location(for: .b) else {
            errorMessage = "Both A and B must be set before booking."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let a = BookingPoint(location: slotA.location, airQuality: slotA.airQuality)
            let b = BookingPoint(location: slotB.location, airQuality: slotB.airQuality)
            booking = try await createBookingUseCase.execute(a: a, b: b)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
