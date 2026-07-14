//
//  Coordinate.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

struct Coordinate: Equatable, Hashable {
    let latitude: Double
    let longitude: Double

    var cacheKey: String {
        let lat = (latitude * 1000).rounded(.towardZero) / 1000
        let lng = (longitude * 1000).rounded(.towardZero) / 1000
        return String(format: "%.3f_%.3f", lat, lng)
    }
}
