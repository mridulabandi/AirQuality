//
//  MapViewModel.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//


import Foundation
import Combine

/// MVVM ViewModel for Screen 1. Owns no UIKit/MapSDK types — the ViewController
/// feeds it coordinates from map-drag callbacks and reads back published state.
final class MapViewModel: ObservableObject {
    private let resolveLocationUseCase: ResolveLocationUseCase
    private let fetchAirQualityUseCase: FetchAirQualityUseCase
    let flowStore: BookingFlowStore

    // MARK: Outputs (bind these in the ViewController)
    @Published private(set) var centerAirQuality: AirQuality?
    @Published private(set) var isResolvingSlot: Bool = false
    @Published private(set) var errorMessage: String?

    /// Debounce work item for map-drag AQI refresh.
    private var debounceTask: Task<Void, Never>?

    var buttonState: VButtonState { flowStore.buttonState }
    var slotALabel: String? { flowStore.location(for: .a)?.location.displayName }
    var slotBLabel: String? { flowStore.location(for: .b)?.location.displayName }

    init(resolveLocationUseCase: ResolveLocationUseCase,
         fetchAirQualityUseCase: FetchAirQualityUseCase,
         flowStore: BookingFlowStore) {
        self.resolveLocationUseCase = resolveLocationUseCase
        self.fetchAirQualityUseCase = fetchAirQualityUseCase
        self.flowStore = flowStore
    }

    /// Called on every map region-change, already debounced by the caller
    /// via `onMapCenterChanged`. Kept separate from the debounce timer itself
    /// so the ViewModel stays UIKit/CoreLocation agnostic.
    func refreshAirQuality(at coordinate: Coordinate) {
        Task { @MainActor in
            do {
                self.centerAirQuality = try await fetchAirQualityUseCase.execute(coordinate: coordinate)
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    /// Debounces rapid drag events (300ms settle) before firing a network call.
    func onMapCenterChanged(to coordinate: Coordinate) {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            refreshAirQuality(at: coordinate)
        }
    }

    /// V Button tap: resolves whichever slot is next (A, then B). No-ops once
    /// both are set — at that point the ViewController should be triggering
    /// the booking flow instead of calling this.
    func onVButtonTapped(currentCenter: Coordinate) {
        let nextSlot: SlotIdentifier
        switch flowStore.buttonState {
        case .setA: nextSlot = .a
        case .setB: nextSlot = .b
        case .book: return
        }

        isResolvingSlot = true
        Task { @MainActor in
            defer { isResolvingSlot = false }
            do {
                let resolved = try await resolveLocationUseCase.execute(coordinate: currentCenter)
                flowStore.setSlot(nextSlot, to: resolved)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    /// Screen 1 label tap routing: if the slot is unset, caller navigates to
    /// Screen 5 (cached picker); if set, caller navigates to Screen 2.
    func slotIsSet(_ slot: SlotIdentifier) -> Bool {
        flowStore.location(for: slot) != nil
    }

    /// Bonus requirement: when Screen 1 is reached via a Screen 4 history-row
    /// tap, both slots arrive pre-filled with AQI captured at booking time.
    /// That AQI may be stale, so re-fetch it for both slots on appear.
    func refreshStaleSlotsIfNeeded() {
        for slot: SlotIdentifier in [.a, .b] {
            guard let cached = flowStore.location(for: slot) else { continue }
            Task { @MainActor in
                do {
                    let refreshedAQI = try await fetchAirQualityUseCase.execute(coordinate: cached.location.coordinate)
                    let updated = CachedLocation(location: cached.location, airQuality: refreshedAQI)
                    flowStore.setSlot(slot, to: updated)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
