//
//  Coordinate.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

/// Plain coordinate value type used throughout the Domain layer.
/// Kept independent of MapKit/GoogleMaps types so Domain has no UI/SDK dependency.
struct Coordinate: Equatable, Hashable {
    let latitude: Double
    let longitude: Double

    /// Cache key rule: two coordinates are the "same location" if lat & lng
    /// match up to the 3rd decimal place.
    var cacheKey: String {
        let lat = (latitude * 1000).rounded() / 1000
        let lng = (longitude * 1000).rounded() / 1000
        return String(format: "%.3f_%.3f", lat, lng)
    }
}
