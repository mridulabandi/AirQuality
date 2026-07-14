//
//  Booking.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

// A or B slot as sent to / received from the /books API.
struct BookingPoint: Equatable, Codable {
    let latitude: Double
    let longitude: Double
    let aqi: Int
    let name: String

    init(location: GeoLocation, airQuality: AirQuality) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.aqi = airQuality.aqi
        self.name = location.displayName
    }

    init(latitude: Double, longitude: Double, aqi: Int, name: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.aqi = aqi
        self.name = name
    }
}

struct Booking: Equatable, Codable {
    let id: String?
    let a: BookingPoint
    let b: BookingPoint
    let price: Double
    let createdAt: Date  
}
