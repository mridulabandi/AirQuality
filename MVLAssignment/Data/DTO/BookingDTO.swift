//
//  BookingDTO.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

struct BookingPointDTO: Codable {
    let latitude: Double
    let longitude: Double
    let aqi: Int
    let name: String
}

struct BookingRequestDTO: Encodable {
    let a: BookingPointDTO
    let b: BookingPointDTO
}

struct BookingResponseDTO: Decodable {
    let id: String?
    let a: BookingPointDTO
    let b: BookingPointDTO
    let price: Double
    let createdAt: Date
}

extension BookingPoint {
    var dto: BookingPointDTO {
        BookingPointDTO(latitude: latitude, longitude: longitude, aqi: aqi, name: name)
    }
}

extension BookingResponseDTO {
    var domain: Booking {
        Booking(
            id: id,
            a: BookingPoint(latitude: a.latitude, longitude: a.longitude, aqi: a.aqi, name: a.name),
            b: BookingPoint(latitude: b.latitude, longitude: b.longitude, aqi: b.aqi, name: b.name),
            price: price,
            createdAt: createdAt
        )
    }
}

