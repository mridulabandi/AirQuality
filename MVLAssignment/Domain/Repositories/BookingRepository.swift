//
//  BookingRepository.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

protocol BookingRepository {
    /// POST /books — mocked, echoes A/B back with an arbitrary price attached.
    func createBooking(a: BookingPoint, b: BookingPoint) async throws -> Booking

    /// GET /books?year=&month= — mocked, returns the full list (no pagination).
    func fetchBookings(year: Int, month: Int) async throws -> [Booking]
}
