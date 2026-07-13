//
//  ResolveLocationUseCase.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

protocol ResolveLocationUseCase {
    func execute(coordinate: Coordinate) async throws -> CachedLocation
}

struct DefaultResolveLocationUseCase: ResolveLocationUseCase {
    let geocodingRepository: GeocodingRepository
    let airQualityRepository: AirQualityRepository
    let cacheRepository: LocationCacheRepository

    func execute(coordinate: Coordinate) async throws -> CachedLocation {
        let airQuality = try await airQualityRepository.fetchAirQuality(at: coordinate)

        if let cached = cacheRepository.lookup(coordinate: coordinate) {
            let refreshed = CachedLocation(location: cached.location, airQuality: airQuality)
            cacheRepository.save(refreshed)
            return refreshed
        }

        let addressName = try await geocodingRepository.reverseGeocode(coordinate: coordinate)
        let location = GeoLocation(coordinate: coordinate, addressName: addressName, nickname: nil)
        let result = CachedLocation(location: location, airQuality: airQuality)
        cacheRepository.save(result)
        return result
    }
}

