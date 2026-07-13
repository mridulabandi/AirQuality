//
//  LocationCacheRepository.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

protocol LocationCacheRepository {
    func save(_ cached: CachedLocation)
    func all() -> [CachedLocation]
    func lookup(coordinate: Coordinate) -> CachedLocation?
}

