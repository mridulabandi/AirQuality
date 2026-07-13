//
//  MapFlowContainerView.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import SwiftUI
import UIKit

/// Bridges the UIKit-based screen flow (MapViewController, AppCoordinator, etc.)
/// into a SwiftUI App lifecycle project. Set this as the root view in
/// WindowGroup instead of the auto-generated ContentView.
struct MapFlowContainerView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UINavigationController {
        let navController = UINavigationController()
        let appCoordinator = AppCoordinator(navigationController: navController)
        context.coordinator.appCoordinator = appCoordinator
        appCoordinator.start()
        return navController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No-op: the UIKit flow manages its own state via BookingFlowStore.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    /// Keeps a strong reference to AppCoordinator so it isn't deallocated —
    /// UIViewControllerRepresentable doesn't retain it for you.
    final class Coordinator {
        var appCoordinator: AppCoordinator?
    }
}
