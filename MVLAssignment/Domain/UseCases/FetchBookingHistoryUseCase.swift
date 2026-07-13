//
//  FetchBookingHistoryUseCase.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

protocol FetchBookingHistoryUseCase {
    func execute(year: Int, month: Int) async throws -> [Booking]
}

struct DefaultFetchBookingHistoryUseCase: FetchBookingHistoryUseCase {
    let repository: BookingRepository

    func execute(year: Int, month: Int) async throws -> [Booking] {
        try await repository.fetchBookings(year: year, month: month)
    }
}
