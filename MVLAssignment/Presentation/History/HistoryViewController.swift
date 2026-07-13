//
//  HistoryViewController.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//


import UIKit
import Combine

final class HistoryViewController: UIViewController {

    private let viewModel: HistoryViewModel
    private weak var coordinator: AppCoordinator?
    private var cancellables = Set<AnyCancellable>()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "BookingCell")
        return table
    }()

    init(viewModel: HistoryViewModel, coordinator: AppCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Monthly History"
        view.backgroundColor = .systemBackground
        setUpLayout()
        tableView.dataSource = self
        tableView.delegate = self
        bindViewModel()
        Task { await viewModel.loadCurrentMonth() }
    }

    private func setUpLayout() {
        [summaryLabel, tableView].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            summaryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            summaryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            summaryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$bookings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.summaryLabel.text = String(
                    format: "Total records: %d   Total price: %.0f",
                    self.viewModel.totalCount, self.viewModel.totalPrice
                )
                self.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                let alert = UIAlertController(title: "Couldn't load history", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: &cancellables)
    }
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.totalCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath)
        let booking = viewModel.booking(at: indexPath.row)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(booking.a.name) → \(booking.b.name)\nPrice: \(Int(booking.price))"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // Bonus: row tap -> Screen 1 pre-filled, V Button = "Book" immediately,
    // AQI re-fetched since it may be stale.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let booking = viewModel.booking(at: indexPath.row)

        let aLocation = GeoLocation(
            coordinate: Coordinate(latitude: booking.a.latitude, longitude: booking.a.longitude),
            addressName: booking.a.name,
            nickname: nil
        )
        let bLocation = GeoLocation(
            coordinate: Coordinate(latitude: booking.b.latitude, longitude: booking.b.longitude),
            addressName: booking.b.name,
            nickname: nil
        )
        // AQI values here are the ones captured at booking time; the flow
        // store/coordinator flags these as stale and Screen 1 refreshes them
        // via its normal onMapCenterChanged / refreshAirQuality path.
        let aCached = CachedLocation(location: aLocation, airQuality: AirQuality(aqi: booking.a.aqi, coordinate: aLocation.coordinate))
        let bCached = CachedLocation(location: bLocation, airQuality: AirQuality(aqi: booking.b.aqi, coordinate: bLocation.coordinate))

        coordinator?.prefillAndReturnToMap(a: aCached, b: bCached)
    }
}
