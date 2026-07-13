//
//  MapViewController.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import UIKit
import CoreLocation
import MapKit
import Combine

/// Screen 1. Programmatic UIKit layout. The ViewModel stays independent of the
/// map SDK by exchanging only domain coordinates.
final class MapViewController: UIViewController {

    private let viewModel: MapViewModel
    private weak var coordinator: AppCoordinator?
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = CLLocationManager()

    // MARK: UI
    private let mapView: MKMapView = {
        let view = MKMapView(frame: .zero)
        let coordinate = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        view.setRegion(MKCoordinateRegion(center: coordinate,
                                           latitudinalMeters: 1_000,
                                           longitudinalMeters: 1_000),
                       animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let centerMarkerImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "mappin"))
        iv.tintColor = .systemRed
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let aqiBadge: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let slotAButton = MapViewController.makeLabelButton()
    private let slotBButton = MapViewController.makeLabelButton()

    private let vButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init(viewModel: MapViewModel, coordinator: AppCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()
        setUpMap()
        bindViewModel()
        setUpActions()
        requestLocationPermissionAndCenter()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshLabelsAndButton()
        viewModel.refreshStaleSlotsIfNeeded()
    }

    // MARK: Layout

    private func setUpLayout() {
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
        view.addSubview(centerMarkerImageView)
        view.addSubview(aqiBadge)

        bottomStack.addArrangedSubview(slotAButton)
        bottomStack.addArrangedSubview(slotBButton)
        bottomStack.addArrangedSubview(vButton)
        view.addSubview(bottomStack)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            centerMarkerImageView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            centerMarkerImageView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor, constant: -12),
            centerMarkerImageView.widthAnchor.constraint(equalToConstant: 32),
            centerMarkerImageView.heightAnchor.constraint(equalToConstant: 32),

            aqiBadge.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            aqiBadge.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            aqiBadge.heightAnchor.constraint(equalToConstant: 32),
            aqiBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),

            bottomStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            vButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private static func makeLabelButton() -> UIButton {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(.label, for: .normal)
        button.setTitle(" ", for: .normal)
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return button
    }

    // MARK: Map

    private func setUpMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
    }

    private func requestLocationPermissionAndCenter() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    // MARK: Bindings

    private func bindViewModel() {
        viewModel.$centerAirQuality
            .receive(on: DispatchQueue.main)
            .sink { [weak self] airQuality in
                guard let airQuality else { return }
                self?.aqiBadge.text = "  AQI: \(airQuality.aqi)  "
            }
            .store(in: &cancellables)

        viewModel.$isResolvingSlot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.vButton.isEnabled = !isLoading
                self?.vButton.alpha = isLoading ? 0.6 : 1.0
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.presentError(message)
            }
            .store(in: &cancellables)

        viewModel.flowStore.$slotA
            .combineLatest(viewModel.flowStore.$slotB)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.refreshLabelsAndButton()
            }
            .store(in: &cancellables)
    }

    private func refreshLabelsAndButton() {
        updateSlotButton(slotAButton, title: viewModel.slotALabel, placeholder: "A: not set")
        updateSlotButton(slotBButton, title: viewModel.slotBLabel, placeholder: "B: not set")
        vButton.setTitle(viewModel.buttonState.title, for: .normal)
    }

    private func updateSlotButton(_ button: UIButton, title: String?, placeholder: String) {
        button.isHidden = false
        button.setTitle(title ?? placeholder, for: .normal)
    }

    // MARK: Actions

    private func setUpActions() {
        slotAButton.addTarget(self, action: #selector(slotATapped), for: .touchUpInside)
        slotBButton.addTarget(self, action: #selector(slotBTapped), for: .touchUpInside)
        vButton.addTarget(self, action: #selector(vButtonTapped), for: .touchUpInside)
    }

    @objc private func slotATapped() { handleSlotTap(.a) }
    @objc private func slotBTapped() { handleSlotTap(.b) }

    private func handleSlotTap(_ slot: SlotIdentifier) {
        if viewModel.slotIsSet(slot) {
            coordinator?.showNicknameScreen(for: slot)
        } else {
            // Bonus Screen 5 flow.
            coordinator?.showCachedLocationsScreen(for: slot)
        }
    }

    @objc private func vButtonTapped() {
        let center = mapView.centerCoordinate
        switch viewModel.buttonState {
        case .setA, .setB:
            viewModel.onVButtonTapped(currentCenter: Coordinate(latitude: center.latitude, longitude: center.longitude))
        case .book:
            coordinator?.showBookingResultScreen()
        }
    }

    private func presentError(_ message: String) {
        let alert = UIAlertController(title: "Something went wrong", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        let coordinate = Coordinate(latitude: center.latitude, longitude: center.longitude)
        viewModel.onMapCenterChanged(to: coordinate)
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 1_000,
                                        longitudinalMeters: 1_000)
        mapView.setRegion(region, animated: true)
        viewModel.refreshAirQuality(at: Coordinate(latitude: location.coordinate.latitude,
                                                   longitude: location.coordinate.longitude))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Spec: denial handling not required. Keep the default region.
    }
}

