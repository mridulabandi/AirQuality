import SwiftUI

struct AppFlowView: View {
    private let container = AppDIContainer.shared
    @StateObject private var flowStore = BookingFlowStore()
    @State private var path: [Route] = []

    enum Route: Hashable {
        case nickname(SlotIdentifier)
        case cachedLocations(SlotIdentifier)
        case booking
        case history
    }

    var body: some View {
        NavigationStack(path: $path) {
            MapScreenView(
                viewModel: container.makeMapViewModel(flowStore: flowStore),
                flowStore: flowStore,
                onNavigateToNickname: { path.append(.nickname($0)) },
                onNavigateToCachedLocations: { path.append(.cachedLocations($0)) },
                onNavigateToBooking: { path.append(.booking) }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .nickname(let slot):
                    NicknameScreenView(
                        viewModel: container.makeNicknameViewModel(slot: slot, flowStore: flowStore),
                        onDone: { path.removeLast() }
                    )
                case .cachedLocations(let slot):
                    CachedLocationsScreenView(
                        viewModel: container.makeCachedLocationsViewModel(flowStore: flowStore),
                        slot: slot,
                        onSelect: { path.removeLast() }
                    )
                case .booking:
                    BookingSummaryScreenView(
                        viewModel: container.makeBookingResultViewModel(flowStore: flowStore),
                        onViewHistory: { path.append(.history) }
                    )
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Back") {
                                flowStore.reset()
                                path.removeAll()
                            }
                        }
                    }
                case .history:
                    HistoryScreenView(
                        viewModel: container.makeHistoryViewModel(),
                        onSelectBooking: { booking in
                            let aLocation = GeoLocation(
                                coordinate: Coordinate(latitude: booking.a.latitude, longitude: booking.a.longitude),
                                addressName: booking.a.name, nickname: nil
                            )
                            let bLocation = GeoLocation(
                                coordinate: Coordinate(latitude: booking.b.latitude, longitude: booking.b.longitude),
                                addressName: booking.b.name, nickname: nil
                            )
                            flowStore.prefill(
                                a: CachedLocation(location: aLocation, airQuality: AirQuality(aqi: booking.a.aqi, coordinate: aLocation.coordinate)),
                                b: CachedLocation(location: bLocation, airQuality: AirQuality(aqi: booking.b.aqi, coordinate: bLocation.coordinate))
                            )
                            path.removeAll()
                        }
                    )
                }
            }
        }
    }
}
