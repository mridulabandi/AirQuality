//
//  CreateBookingUseCase.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

protocol CreateBookingUseCase {
    func execute(a: BookingPoint, b: BookingPoint) async throws -> Booking
}

struct DefaultCreateBookingUseCase: CreateBookingUseCase {
    let repository: BookingRepository

    func execute(a: BookingPoint, b: BookingPoint) async throws -> Booking {
        try await repository.createBooking(a: a, b: b)
    }
}
