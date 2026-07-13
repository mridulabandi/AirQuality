//
//  AppCoordinator.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//


import UIKit

/// Owns the single BookingFlowStore instance for the whole A/B/Book flow and
/// wires each screen's ViewModel to it. A fresh AppCoordinator (and therefore a
/// fresh flowStore) is created each time the flow restarts from Screen 1.
final class AppCoordinator {
    private let navigationController: UINavigationController
    private let container: AppDIContainer
    private var flowStore: BookingFlowStore

    init(navigationController: UINavigationController, container: AppDIContainer = .shared) {
        self.navigationController = navigationController
        self.container = container
        self.flowStore = BookingFlowStore()
    }

    func start() {
        showMapScreen()
    }

    func showMapScreen() {
        let viewModel = container.makeMapViewModel(flowStore: flowStore)
        let vc = MapViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([vc], animated: false)
    }

    func showNicknameScreen(for slot: SlotIdentifier) {
        let viewModel = container.makeNicknameViewModel(slot: slot, flowStore: flowStore)
        let vc = NicknameViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showCachedLocationsScreen(for slot: SlotIdentifier) {
        let viewModel = container.makeCachedLocationsViewModel(flowStore: flowStore)
        let vc = CachedLocationsViewController(viewModel: viewModel, slot: slot, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showBookingResultScreen() {
        let viewModel = container.makeBookingResultViewModel(flowStore: flowStore)
        let vc = BookingResultViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showHistoryScreen() {
        let viewModel = container.makeHistoryViewModel()
        let vc = HistoryViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    /// Screen 3 back / Screen 1 re-entry: reset flow state and pop to root.
    func returnToInitialMapState() {
        flowStore.reset()
        navigationController.popToRootViewController(animated: true)
    }

    /// Screen 4 row tap: pre-fill both slots and jump straight back to Screen 1.
    func prefillAndReturnToMap(a: CachedLocation, b: CachedLocation) {
        flowStore.prefill(a: a, b: b)
        navigationController.popToRootViewController(animated: true)
    }

    func popToMap() {
        navigationController.popToRootViewController(animated: true)
    }
}
