//
//  GeocodeResponseDTO.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

struct GeocodeResponseDTO: Decodable {
    struct LocalityInfoDTO: Decodable {
        struct AdministrativeDTO: Decodable {
            let name: String
            let order: Int?
            let adminLevel: Int?

            enum CodingKeys: String, CodingKey {
                case name, order
                case adminLevel = "adminLevel"
            }
        }
        let administrative: [AdministrativeDTO]
    }
    let localityInfo: LocalityInfoDTO
}

/// using the two name values with the highest order from
/// localityInfo → administrative and concatenate them.
enum AddressNameMapper {
    static func displayName(from dto: GeocodeResponseDTO) -> String {
        let sortedByOrderDesc = dto.localityInfo.administrative
            .sorted { ($0.order ?? 0) > ($1.order ?? 0) }
        let topTwo = sortedByOrderDesc.prefix(2).map(\.name)
        return topTwo.joined(separator: " ")
    }
}
