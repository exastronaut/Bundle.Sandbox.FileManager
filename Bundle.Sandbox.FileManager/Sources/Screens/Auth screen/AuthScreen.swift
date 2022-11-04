//
//  AuthScreen.swift
//  Bundle.Sandbox.FileManager
//
//  Created by Artem Sviridov on 30.10.2022.
//

import UIKit

final class AuthScreen: UIViewController {

    private let passwordService = PasswordService()
    private var userCredentials = Credentials(username: Constants.username, password: nil)
    private var state: State {
        didSet {
            setupTitleForButton()
        }
    }
    private var numberOfAttempts: NumberOfAttempts = .first

    //MARK: - UI

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 16)
        textField.placeholder = Constants.placeholder
        textField.textColor = .darkText
        textField.autocapitalizationType = .none
        textField.layer.backgroundColor = UIColor.systemGray6.cgColor
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 10
        textField.ident(size: 10)
        textField.delegate = self
        textField.isSecureTextEntry = true
        return textField
    }()

    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.darkText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(actionButton), for: .touchUpInside)
        return button
    }()

    //MARK: - Initialization

    init(state: State = .didNotCreateAPasswordEarlier) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Override functions

    override func loadView() {
        super.loadView()

        customizeView()
        addSubviews()
        makeConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        state = passwordService.havePassword(for: userCredentials) ? .hasASavedPassword : .didNotCreateAPasswordEarlier
    }

}

//MARK: - Private functions

private extension AuthScreen {

    @objc
    func actionButton() {
        guard let password = textField.text, password.count >= Constants.minCount else {
            showAlert(title: .minFourCharactersTitle, message: .minFourCharactersMessage)
            textField.text = .emptyline
            return
        }

        if state == .didNotCreateAPasswordEarlier || state == .repeatPassword {
            switch numberOfAttempts {
            case .first:
                userCredentials.password = password
                passwordService.setPassword(with: userCredentials)
                numberOfAttempts = .second
                state = .repeatPassword
            case .second:
                if let getPassword = passwordService.getPassword(for: userCredentials), getPassword == password {
                    state = .hasASavedPassword
                    showNextScreen()
                } else {
                    showAlert(title: .passwordsDoNotMatchTitle, message: .tryAgainMessage)
                    numberOfAttempts = .first
                    passwordService.deletePassword(for: userCredentials)
                    state = .didNotCreateAPasswordEarlier
                }
            }
        } else if let getPassword = passwordService.getPassword(for: userCredentials), getPassword == password {
            showNextScreen()
        } else {
            showAlert(title: .passwordNotFoundTitle, message: .tryAgainMessage)
        }
        textField.text = .emptyline
    }

    func showNextScreen() {
        navigationController?.pushViewController(MainTabBarScreen(), animated: true)
    }

    func customizeView() {
        view.backgroundColor = .systemBackground
    }

    func addSubviews() {
        view.addSubview(textField)
        view.addSubview(button)
    }

    func makeConstraints() {
        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 48),

            button.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            button.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            button.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    func setupTitleForButton() {
        switch state {
        case .didNotCreateAPasswordEarlier:
            button.setTitle(Constants.createPassword, for: .normal)
        case .hasASavedPassword:
            button.setTitle(Constants.enterPassword, for: .normal)
        case .repeatPassword:
            button.setTitle(Constants.repeatPassword, for: .normal)
        }
    }

}

//MARK: - UITextFieldDelegate

extension AuthScreen: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }

}

//MARK: - State + NumberOfAttempts

extension AuthScreen {

    enum State {
        case hasASavedPassword
        case didNotCreateAPasswordEarlier
        case repeatPassword
    }

    enum NumberOfAttempts {
        case first
        case second
    }

}

//MARK: - Constants

private extension AuthScreen {

    enum Constants {
        static let placeholder = "Password"
        static let createPassword = "Create a password"
        static let enterPassword = "Enter the password"
        static let repeatPassword = "Repeat password"
        static let minCount = 4
        static let username = "username"
    }

}
