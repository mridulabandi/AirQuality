//
//  FetchAirQualityUseCase.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

protocol FetchAirQualityUseCase {
    func execute(coordinate: Coordinate) async throws -> AirQuality
}

struct DefaultFetchAirQualityUseCase: FetchAirQualityUseCase {
    let repository: AirQualityRepository

    func execute(coordinate: Coordinate) async throws -> AirQuality {
        try await repository.fetchAirQuality(at: coordinate)
    }
}

