//
//  AirQualityRepository.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

protocol AirQualityRepository {
    /// Fetches AQI for a coordinate. Always hits the network — AQI is time-sensitive
    /// even for a coordinate that's been geocoded before.
    func fetchAirQuality(at coordinate: Coordinate) async throws -> AirQuality
}

