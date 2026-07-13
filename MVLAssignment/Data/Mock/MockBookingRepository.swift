//
//  MockBookingRepository.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation
final class MockBookingRepository: BookingRepository {
    /// In-memory store so Screen 4 history reflects bookings made during the
    /// same app session, in addition to the seeded sample data below.
    private var createdBookings: [Booking] = []

    private let seedBookings: [Booking] = [
        Booking(
            id: "seed-1",
            a: BookingPoint(latitude: 36.564, longitude: 127.001, aqi: 30, name: "서울 A 위치"),
            b: BookingPoint(latitude: 36.567, longitude: 127.000, aqi: 40, name: "서울 B 위치"),
            price: 10000
        ),
        Booking(
            id: "seed-2",
            a: BookingPoint(latitude: 36.577, longitude: 127.033, aqi: 50, name: "서울 C 위치"),
            b: BookingPoint(latitude: 36.567, longitude: 127.000, aqi: 60, name: "서울 D 위치"),
            price: 20000
        )
    ]

    func createBooking(a: BookingPoint, b: BookingPoint) async throws -> Booking {
        // Simulate network latency so loading states are actually observable.
        try await Task.sleep(nanoseconds: 400_000_000)

        let price = Double(Int.random(in: 8_000...25_000))
        let booking = Booking(id: UUID().uuidString, a: a, b: b, price: price)
        createdBookings.append(booking)
        return booking
    }

    func fetchBookings(year: Int, month: Int) async throws -> [Booking] {
        try await Task.sleep(nanoseconds: 300_000_000)
        // Mock ignores year/month filtering and returns everything, per the
        // assignment's "mock the response as all Book items in the list" note.
        return seedBookings + createdBookings
    }
}

