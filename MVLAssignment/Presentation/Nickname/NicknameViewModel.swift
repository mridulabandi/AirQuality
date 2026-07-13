//
//  NicknameViewModel.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//


import Foundation
import Combine

final class NicknameViewModel: ObservableObject {
    let slot: SlotIdentifier
    private let flowStore: BookingFlowStore
    private let maxNicknameLength = 20

    var addressName: String {
        flowStore.location(for: slot)?.location.addressName ?? ""
    }

    var currentNickname: String {
        flowStore.location(for: slot)?.location.nickname ?? ""
    }

    var capturedAQI: Int {
        flowStore.location(for: slot)?.airQuality.aqi ?? 0
    }

    init(slot: SlotIdentifier, flowStore: BookingFlowStore) {
        self.slot = slot
        self.flowStore = flowStore
    }

    /// Enforces the 20-char max as the user types.
    func sanitizedInput(_ text: String) -> String {
        String(text.prefix(maxNicknameLength))
    }

    /// Save or Skip both funnel here — nickname is optional, so an empty
    /// string is treated the same as "skip" (falls back to address name via
    /// GeoLocation.displayName).
    func save(nickname: String) {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        flowStore.setNickname(trimmed.isEmpty ? nil : trimmed, for: slot)
    }
}
