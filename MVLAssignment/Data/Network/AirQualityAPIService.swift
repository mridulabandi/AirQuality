//
//  AirQualityAPIService.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Alamofire
import Foundation

protocol AirQualityAPIServicing {
    func fetchAQI(latitude: Double, longitude: Double) async throws -> AQIResponseDTO
}

final class AirQualityAPIService: AirQualityAPIServicing {
    private let session: Alamofire.Session
    private let decoder: JSONDecoder

    init(session: Alamofire.Session = .default, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetchAQI(latitude: Double, longitude: Double) async throws -> AQIResponseDTO {
        let endpoint = "\(APIConstants.aqicnBaseURL)/feed/geo:\(latitude);\(longitude)/"
        let parameters: Parameters = [
            "token": APIConstants.aqicnToken
        ]

        let data = try await session.request(endpoint, parameters: parameters)
            .validate(statusCode: 200..<300)
            .serializingData()
            .value

        do {
            return try decoder.decode(AQIResponseDTO.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}

