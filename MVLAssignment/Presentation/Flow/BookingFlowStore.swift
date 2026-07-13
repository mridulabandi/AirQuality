//
//  BookingFlowStore.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//
import Foundation
import Combine

enum SlotIdentifier {
    case a
    case b
}

/// Single source of truth for the A/B slots as the user moves across
/// Screens 1–5. This is what makes "reset to initial state on return to
/// Screen 1" and "history row tap pre-fills Screen 1" simple: every screen
/// reads/writes the same store instead of passing state through segues.
///
/// Kept as a plain ObservableObject (Combine) rather than a full TCA store —
/// the assignment allows either; this is enough for a 5-screen flow's needs
/// without pulling in extra bonus-scope infrastructure.
final class BookingFlowStore: ObservableObject {

    @Published private(set) var slotA: CachedLocation?
    @Published private(set) var slotB: CachedLocation?

    /// Drives the V Button label: .setA -> .setB -> .book
    var buttonState: VButtonState {
        switch (slotA, slotB) {
        case (nil, _): return .setA
        case (.some, nil): return .setB
        case (.some, .some): return .book
        }
    }

    func setSlot(_ slot: SlotIdentifier, to location: CachedLocation) {
        switch slot {
        case .a: slotA = location
        case .b: slotB = location
        }
    }

    func setNickname(_ nickname: String?, for slot: SlotIdentifier) {
        switch slot {
        case .a:
            guard var current = slotA else { return }
            current = CachedLocation(
                location: GeoLocation(coordinate: current.location.coordinate,
                                       addressName: current.location.addressName,
                                       nickname: nickname),
                airQuality: current.airQuality
            )
            slotA = current
        case .b:
            guard var current = slotB else { return }
            current = CachedLocation(
                location: GeoLocation(coordinate: current.location.coordinate,
                                       addressName: current.location.addressName,
                                       nickname: nickname),
                airQuality: current.airQuality
            )
            slotB = current
        }
    }

    func location(for slot: SlotIdentifier) -> CachedLocation? {
        switch slot {
        case .a: return slotA
        case .b: return slotB
        }
    }

    /// Screen 3 "back" and general "return to Screen 1" reset requirement.
    func reset() {
        slotA = nil
        slotB = nil
    }

    /// Screen 4 row tap: pre-fill both slots directly (V Button should show
    /// "Book" immediately; AQI is refreshed separately by the caller since it
    /// may be stale).
    func prefill(a: CachedLocation, b: CachedLocation) {
        slotA = a
        slotB = b
    }
}

enum VButtonState {
    case setA
    case setB
    case book

    var title: String {
        switch self {
        case .setA: return "Set A"
        case .setB: return "Set B"
        case .book: return "Book"
        }
    }
}

