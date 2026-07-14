//
//  GeoLocation.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

struct GeoLocation: Equatable, Hashable {
    let coordinate: Coordinate
    let addressName: String
    var nickname: String?

    var displayName: String {
        if let nickname, !nickname.isEmpty { return nickname }
        return addressName
    }

    static func == (lhs: GeoLocation, rhs: GeoLocation) -> Bool {
        lhs.coordinate == rhs.coordinate && lhs.addressName == rhs.addressName
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(coordinate)
    }
}

struct CachedLocation: Equatable, Hashable {
    let location: GeoLocation
    let airQuality: AirQuality

    static func == (lhs: CachedLocation, rhs: CachedLocation) -> Bool {
        lhs.location == rhs.location
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(location)
    }
}

