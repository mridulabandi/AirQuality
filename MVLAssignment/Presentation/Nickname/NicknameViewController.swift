//
//  NicknameViewController.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//


import UIKit

final class NicknameViewController: UIViewController {

    private let viewModel: NicknameViewModel
    private weak var coordinator: AppCoordinator?

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nicknameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Nickname (optional, max 20 chars)"
        field.borderStyle = .roundedRect
        field.clearButtonMode = .whileEditing
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(viewModel: NicknameViewModel, coordinator: AppCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Location Detail"
        view.backgroundColor = .systemBackground
        setUpLayout()
        addressLabel.text = viewModel.addressName
        nicknameField.text = viewModel.currentNickname
        updateCharacterCount()
        nicknameField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
    }

    private func setUpLayout() {
        [addressLabel, nicknameField, characterCountLabel, saveButton, skipButton].forEach {
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            addressLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            nicknameField.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 24),
            nicknameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nicknameField.heightAnchor.constraint(equalToConstant: 44),

            characterCountLabel.topAnchor.constraint(equalTo: nicknameField.bottomAnchor, constant: 4),
            characterCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            saveButton.topAnchor.constraint(equalTo: characterCountLabel.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 48),

            skipButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 12),
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func textChanged() {
        nicknameField.text = viewModel.sanitizedInput(nicknameField.text ?? "")
        updateCharacterCount()
    }

    private func updateCharacterCount() {
        let count = nicknameField.text?.count ?? 0
        characterCountLabel.text = "\(count)/20"
    }

    @objc private func saveTapped() {
        viewModel.save(nickname: nicknameField.text ?? "")
        coordinator?.popToMap()
    }

    @objc private func skipTapped() {
        viewModel.save(nickname: "")
        coordinator?.popToMap()
    }
}
