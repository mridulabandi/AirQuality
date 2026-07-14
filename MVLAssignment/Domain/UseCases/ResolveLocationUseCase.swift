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
        // Cache lookup is a cheap in-memory read, so do it first to decide
        // whether we need one network call or two.
        if let cached = cacheRepository.lookup(coordinate: coordinate) {
            let airQuality = try await airQualityRepository.fetchAirQuality(at: coordinate)
            let refreshed = CachedLocation(location: cached.location, airQuality: airQuality)
            cacheRepository.save(refreshed)
            return refreshed
        }

        // AQI and reverse-geocoding are independent of each other — fire both
        // concurrently instead of sequentially to cut perceived latency
        // roughly in half on a cache miss.
        async let airQualityTask = airQualityRepository.fetchAirQuality(at: coordinate)
        async let addressNameTask = geocodingRepository.reverseGeocode(coordinate: coordinate)

        let (airQuality, addressName) = try await (airQualityTask, addressNameTask)

        let location = GeoLocation(coordinate: coordinate, addressName: addressName, nickname: nil)
        let result = CachedLocation(location: location, airQuality: airQuality)
        cacheRepository.save(result)
        return result
    }
}

