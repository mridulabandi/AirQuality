//
//  MockBookingRepository.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

/// BookingRepository protocol, so swapping this for LiveBookingRepository
final class MockBookingRepository: BookingRepository {

    private var createdBookings: [Booking] = []
    private let calendar = Calendar.current

    private lazy var seedBookings: [Booking] = [
        Booking(
            id: "seed-1",
            a: BookingPoint(latitude: 36.564, longitude: 127.001, aqi: 30, name: "서울 A 위치"),
            b: BookingPoint(latitude: 36.567, longitude: 127.000, aqi: 40, name: "서울 B 위치"),
            price: 10000,
            createdAt: calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        ),
        Booking(
            id: "seed-2",
            a: BookingPoint(latitude: 36.577, longitude: 127.033, aqi: 50, name: "서울 C 위치"),
            b: BookingPoint(latitude: 36.567, longitude: 127.000, aqi: 60, name: "서울 D 위치"),
            price: 20000,
            createdAt: Date()
        )
    ]

    func createBooking(a: BookingPoint, b: BookingPoint) async throws -> Booking {
        // Simulate network latency so loading states are actually observable.
        try await Task.sleep(nanoseconds: 400_000_000)

        let price = Double(Int.random(in: 8_000...25_000))
        let booking = Booking(id: UUID().uuidString, a: a, b: b, price: price, createdAt: Date())
        createdBookings.append(booking)
        return booking
    }

    func fetchBookings(year: Int, month: Int) async throws -> [Booking] {
        try await Task.sleep(nanoseconds: 300_000_000)

        // Real filtering by year/month, not a static/full-list passthrough.
        return (seedBookings + createdBookings).filter { booking in
            let components = calendar.dateComponents([.year, .month], from: booking.createdAt)
            return components.year == year && components.month == month
        }
    }
}
