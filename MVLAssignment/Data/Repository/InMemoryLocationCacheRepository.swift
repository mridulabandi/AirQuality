//
//  InMemoryLocationCacheRepository.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

final class InMemoryLocationCacheRepository: LocationCacheRepository {
    private var storage: [String: CachedLocation] = [:]
    private let queue = DispatchQueue(label: "com.mvl.locationcache")

    func save(_ cached: CachedLocation) {
        queue.sync { storage[cached.location.coordinate.cacheKey] = cached }
    }

    func all() -> [CachedLocation] {
        queue.sync { Array(storage.values) }
    }

    func lookup(coordinate: Coordinate) -> CachedLocation? {
        queue.sync { storage[coordinate.cacheKey] }
    }
}
