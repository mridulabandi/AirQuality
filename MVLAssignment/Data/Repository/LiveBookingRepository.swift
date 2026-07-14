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
    private let session: Session
    private let decoder: JSONDecoder

    init(baseURL: String, session: Session = .default) {
        self.baseURL = baseURL
        self.session = session
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func createBooking(a: BookingPoint, b: BookingPoint) async throws -> Booking {
        let url = "\(baseURL)/books"
        let body = BookingRequestDTO(a: a.dto, b: b.dto)

        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .post, parameters: body, encoder: JSONParameterEncoder.default)
                .validate()
                .responseDecodable(of: BookingResponseDTO.self, decoder: decoder) { response in
                    switch response.result {
                    case .success(let dto):
                        continuation.resume(returning: dto.domain)
                    case .failure:
                        continuation.resume(throwing: APIError.invalidResponse)
                    }
                }
        }
    }

    func fetchBookings(year: Int, month: Int) async throws -> [Booking] {
        let url = "\(baseURL)/books"
        let parameters: [String: Int] = ["year": year, "month": month]

        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .get, parameters: parameters)
                .validate()
                .responseDecodable(of: [BookingResponseDTO].self, decoder: decoder) { response in
                    switch response.result {
                    case .success(let dtos):
                        continuation.resume(returning: dtos.map { $0.domain })
                    case .failure:
                        continuation.resume(throwing: APIError.invalidResponse)
                    }
                }
        }
    }
}
