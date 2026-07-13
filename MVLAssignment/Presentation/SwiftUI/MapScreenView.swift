import SwiftUI
import MapKit
import CoreLocation

/// Screen 1 — full-screen map, AQI badge top-right, A/B fields + V button
/// bottom, matching the wireframe: two stacked label rows on the left, one
/// large square action button on the right spanning both rows' height.
struct MapScreenView: View {
    @ObservedObject var viewModel: MapViewModel
    @ObservedObject var flowStore: BookingFlowStore
    let onNavigateToNickname: (SlotIdentifier) -> Void
    let onNavigateToCachedLocations: (SlotIdentifier) -> Void
    let onNavigateToBooking: () -> Void

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    @State private var currentCenter = Coordinate(latitude: 37.5665, longitude: 126.9780)
    private let locationManager = CLLocationManager()

    var body: some View {
        ZStack {
            Map(position: $cameraPosition)
                .ignoresSafeArea()
                .onMapCameraChange(frequency: .onEnd) { context in
                    let center = context.region.center
                    currentCenter = Coordinate(latitude: center.latitude, longitude: center.longitude)
                    viewModel.onMapCenterChanged(to: currentCenter)
                }

            // Fixed center marker overlay — map moves underneath it.
            Image("icon-pin")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24, alignment: .center)

            VStack {
                aqiBadge
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, DesignTokens.screenPadding)

                Spacer()
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomControls
        }
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
            viewModel.refreshStaleSlotsIfNeeded()
        }
    }

    private var aqiBadge: some View {
        HStack {
            Text("aqi")
                .foregroundColor(.black.opacity(0.7))
            Text("\(viewModel.centerAirQuality?.aqi ?? 0)")
                .fontWeight(.semibold)
        }
        .font(.system(size: 14))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
    }

    private var bottomControls: some View {
        HStack(spacing: 10) {
            VStack(spacing: 8) {
                slotField(slot: .a)
                slotField(slot: .b)
            }
            ActionSquareButton(title: viewModel.buttonState.title) {
                switch viewModel.buttonState {
                case .setA, .setB:
                    viewModel.onVButtonTapped(currentCenter: currentCenter)
                case .book:
                    onNavigateToBooking()
                }
            }
            .frame(width: 64, height: 136)
        }
        .padding(DesignTokens.screenPadding)
        .background(Color(white: 0.97))
    }

    private func slotField(slot: SlotIdentifier) -> some View {
        let text = (slot == .a ? viewModel.slotALabel : viewModel.slotBLabel)
        return Button {
            viewModel.slotIsSet(slot) ? onNavigateToNickname(slot) : onNavigateToCachedLocations(slot)
        } label: {
            HStack {
                Text(text ?? "")
                    .foregroundColor(.black)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 54)
            .background(DesignTokens.cardBackground)
            .overlay(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius).stroke(DesignTokens.rowDivider))
        }
    }
}
