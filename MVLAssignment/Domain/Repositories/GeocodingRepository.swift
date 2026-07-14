//
//  GeocodingRepository.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

protocol GeocodingRepository {
    /// Reverse-geocodes a coordinate into a display address name.
    func reverseGeocode(coordinate: Coordinate) async throws -> String
}
