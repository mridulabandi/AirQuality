//
//  AQIResponseDTO.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

struct AQIResponseDTO: Decodable {
    struct DataDTO: Decodable {
        let aqi: Int
    }
    let status: String
    let data: DataDTO
}

