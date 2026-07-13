//
//  CachedLocationsViewModel.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//


import Foundation
import Combine

final class CachedLocationsViewModel: ObservableObject {
    private let fetchCachedLocationsUseCase: FetchCachedLocationsUseCase
    private let flowStore: BookingFlowStore

    @Published private(set) var cachedLocations: [CachedLocation] = []

    init(fetchCachedLocationsUseCase: FetchCachedLocationsUseCase, flowStore: BookingFlowStore) {
        self.fetchCachedLocationsUseCase = fetchCachedLocationsUseCase
        self.flowStore = flowStore
    }

    func load() {
        cachedLocations = fetchCachedLocationsUseCase.execute()
    }

    /// Assigns the picked location to whichever slot was empty and reports
    /// back the resulting button state so Screen 1 updates immediately.
    func select(_ location: CachedLocation, for slot: SlotIdentifier) {
        flowStore.setSlot(slot, to: location)
    }
}
