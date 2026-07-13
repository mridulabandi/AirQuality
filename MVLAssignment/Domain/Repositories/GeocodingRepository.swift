//
//  GeocodingRepository.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

protocol GeocodingRepository {
    /// Reverse-geocodes a coordinate into a display address name.
    /// Per spec: concatenate the two highest-order `localityInfo.administrative`
    /// entries (see AddressNameMapper).
    func reverseGeocode(coordinate: Coordinate) async throws -> String
}
