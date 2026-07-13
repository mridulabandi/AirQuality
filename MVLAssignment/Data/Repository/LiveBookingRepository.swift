//
//  LiveBookingRepository.swift
//  MVLAssignment
//
//  Real BookingRepository implementation, used once an actual /books backend
//  exists. Not exercised by the mocked assignment flow today, but its
//  existence — behind the exact same protocol MockBookingRepository
//  implements — is what makes the mock/real swap in AppDIContainer a real
//  one-line change instead of a theoretical one.
//

import Alamofire
import Foundation

final class LiveBookingRepository: BookingRepository {
    private let baseURL: String
    private let session: Alamofire.Session
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        baseURL: String,
        session: Alamofire.Session = .default,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
    }

    func createBooking(a: BookingPoint, b: BookingPoint) async throws -> Booking {
        let endpoint = "\(baseURL)/books"
        let request = BookingRequestDTO(a: a.dto, b: b.dto)
        let jsonEncoder = JSONParameterEncoder(encoder: encoder)

        let data = try await session.request(
            endpoint,
            method: .post,
            parameters: request,
            encoder: jsonEncoder
        )
        .validate(statusCode: 200..<300)
        .serializingData()
        .value

        do {
            return try decoder.decode(BookingResponseDTO.self, from: data).domain
        } catch {
            throw APIError.decodingFailed
        }
    }

    func fetchBookings(year: Int, month: Int) async throws -> [Booking] {
        let endpoint = "\(baseURL)/books"
        let parameters: Parameters = [
            "year": year,
            "month": month
        ]

        let data = try await session.request(endpoint, parameters: parameters)
            .validate(statusCode: 200..<300)
            .serializingData()
            .value

        do {
            return try decoder.decode([BookingResponseDTO].self, from: data).map { $0.domain }
        } catch {
            throw APIError.decodingFailed
        }
    }
}
