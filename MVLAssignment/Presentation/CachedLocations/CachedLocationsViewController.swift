//
//  CachedLocationsViewController.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//


import UIKit
import Combine

final class CachedLocationsViewController: UIViewController {

    private let viewModel: CachedLocationsViewModel
    private let slot: SlotIdentifier
    private weak var coordinator: AppCoordinator?
    private var cancellables = Set<AnyCancellable>()

    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "CachedCell")
        return table
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No cached locations yet."
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(viewModel: CachedLocationsViewModel, slot: SlotIdentifier, coordinator: AppCoordinator) {
        self.viewModel = viewModel
        self.slot = slot
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cached Locations"
        view.backgroundColor = .systemBackground
        setUpLayout()
        tableView.dataSource = self
        tableView.delegate = self
        bindViewModel()
        viewModel.load()
    }

    private func setUpLayout() {
        [tableView, emptyLabel].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$cachedLocations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] locations in
                self?.emptyLabel.isHidden = !locations.isEmpty
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension CachedLocationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cachedLocations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CachedCell", for: indexPath)
        let cached = viewModel.cachedLocations[indexPath.row]
        cell.textLabel?.text = "\(cached.location.displayName) (AQI \(cached.airQuality.aqi))"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selected = viewModel.cachedLocations[indexPath.row]
        viewModel.select(selected, for: slot)
        // Screen 1 reactively updates its button state (setA/setB/book) via
        // its BookingFlowStore binding once we pop back.
        coordinator?.popToMap()
    }
}
