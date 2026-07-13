//
//  BookingResultViewController.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//


import UIKit
import Combine

final class BookingResultViewController: UIViewController {

    private let viewModel: BookingResultViewModel
    private weak var coordinator: AppCoordinator?
    private var cancellables = Set<AnyCancellable>()

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let summaryStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let aLabel = BookingResultViewController.makeInfoLabel()
    private let bLabel = BookingResultViewController.makeInfoLabel()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let historyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Monthly History", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(viewModel: BookingResultViewModel, coordinator: AppCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Booking"
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        setUpLayout()
        bindViewModel()
        historyButton.addTarget(self, action: #selector(historyTapped), for: .touchUpInside)

        Task { await viewModel.createBooking() }
    }

    private func setUpLayout() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        summaryStack.addArrangedSubview(aLabel)
        summaryStack.addArrangedSubview(bLabel)
        summaryStack.addArrangedSubview(priceLabel)

        [activityIndicator, summaryStack, historyButton].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            summaryStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            summaryStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            summaryStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            historyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            historyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            historyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            historyButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Back navigation returns to Screen 1's initial state per spec.
        let backItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem = backItem
    }

    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
                self?.summaryStack.isHidden = isLoading
            }
            .store(in: &cancellables)

        viewModel.$booking
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] booking in
                self?.aLabel.text = "A: \(booking.a.name)\nAQI \(booking.a.aqi)"
                self?.bLabel.text = "B: \(booking.b.name)\nAQI \(booking.b.aqi)"
                self?.priceLabel.text = String(format: "Price: %.0f", booking.price)
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                let alert = UIAlertController(title: "Booking failed", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: &cancellables)
    }

    private static func makeInfoLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    @objc private func historyTapped() {
        coordinator?.showHistoryScreen()
    }

    @objc private func backTapped() {
        // Spec: "the user may go back to return to the initial state of the first screen."
        coordinator?.returnToInitialMapState()
    }
}
