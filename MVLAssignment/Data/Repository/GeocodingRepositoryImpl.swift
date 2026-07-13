//
//  GeocodingRepositoryImpl.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

final class GeocodingRepositoryImpl: GeocodingRepository {
    private let apiService: GeocodingAPIServicing

    init(apiService: GeocodingAPIServicing) {
        self.apiService = apiService
    }

    func reverseGeocode(coordinate: Coordinate) async throws -> String {
        let dto = try await apiService.reverseGeocode(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return AddressNameMapper.displayName(from: dto)
    }
}
