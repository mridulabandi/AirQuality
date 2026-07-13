//
//  AirQualityRepositoryImpl.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

final class AirQualityRepositoryImpl: AirQualityRepository {
    private let apiService: AirQualityAPIServicing

    init(apiService: AirQualityAPIServicing) {
        self.apiService = apiService
    }

    func fetchAirQuality(at coordinate: Coordinate) async throws -> AirQuality {
        let dto = try await apiService.fetchAQI(latitude: coordinate.latitude, longitude: coordinate.longitude)
        guard dto.status == "ok" else { throw APIError.server("AQI status: \(dto.status)") }
        return AirQuality(aqi: dto.data.aqi, coordinate: coordinate)
    }
}
