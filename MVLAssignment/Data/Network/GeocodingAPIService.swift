//
//  GeocodingAPIService.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Alamofire
import Foundation

protocol GeocodingAPIServicing {
    func reverseGeocode(latitude: Double, longitude: Double) async throws -> GeocodeResponseDTO
}

final class GeocodingAPIService: GeocodingAPIServicing {
    private let session: Alamofire.Session
    private let decoder: JSONDecoder

    init(session: Alamofire.Session = .default, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func reverseGeocode(latitude: Double, longitude: Double) async throws -> GeocodeResponseDTO {
        let endpoint = "\(APIConstants.bigDataCloudBaseURL)/reverse-geocode-client"
        let parameters: Parameters = [
            "latitude": latitude,
            "longitude": longitude,
            "localityLanguage": "en"
        ]

        let data = try await session.request(endpoint, parameters: parameters)
            .validate(statusCode: 200..<300)
            .serializingData()
            .value

        do {
            return try decoder.decode(GeocodeResponseDTO.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}

