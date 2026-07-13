//
//  FetchCachedLocationsUseCase.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

protocol FetchCachedLocationsUseCase {
    func execute() -> [CachedLocation]
}

struct DefaultFetchCachedLocationsUseCase: FetchCachedLocationsUseCase {
    let repository: LocationCacheRepository

    func execute() -> [CachedLocation] {
        repository.all()
    }
}
