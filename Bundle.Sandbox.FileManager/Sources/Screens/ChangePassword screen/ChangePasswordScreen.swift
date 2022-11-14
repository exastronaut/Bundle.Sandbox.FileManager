//
//  ChangePasswordScreen.swift
//  Bundle.Sandbox.FileManager
//
//  Created by Artem Sviridov on 04.11.2022.
//

import UIKit

final class ChangePasswordScreen: UIViewController {

    private let passwordService = PasswordService()
    private var userCredentials = Credentials(username: Constants.username, password: nil)

    //MARK: - UI

    private lazy var newPasswordTextField = makePasswordTextField(with: Constants.newPassword)
    private lazy var repeatPasswordTextField = makePasswordTextField(with: Constants.repeatPassword)

    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.updatePassword, for: .normal)
        button.setTitleColor(.darkText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(actionButton), for: .touchUpInside)
        return button
    }()

    private lazy var doneButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        return button
    }()

    //MARK: - Override functions

    override func loadView() {
        super.loadView()

        customizeView()
        addSubviews()
        makeConstraints()
    }

}

private extension ChangePasswordScreen {

    @objc
    func actionButton() {
        guard let newPassword = newPasswordTextField.text, let repeatPassword = repeatPasswordTextField.text,
              !newPassword.isEmpty || !repeatPassword.isEmpty
        else {
            showAlert(title: .emptyFieldsTitle, message: .emptyFieldsMessage)
            return
        }

        if newPassword.count >= Constants.minCount {
            if newPassword == repeatPassword {
                guard let oldPassword = passwordService.getPassword(for: userCredentials),
                      oldPassword != newPassword
                else {
                    showAlert(title: .passwordAlreadyExistsTitle, message: .tryAgainMessage)
                    return
                }
                userCredentials.password = newPassword
                passwordService.updatePassword(for: userCredentials)
                dismiss(animated: true)
            } else {
                showAlert(title: .passwordsDoNotMatchTitle, message: .tryAgainMessage)
            }
        } else {
            showAlert(title: .minFourCharactersTitle, message: .minFourCharactersMessage)
        }
    }

    @objc
    func doneAction() {
        dismiss(animated: true)
    }

    func customizeView() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = doneButtonItem
    }

    func addSubviews() {
        view.addSubview(newPasswordTextField)
        view.addSubview(repeatPasswordTextField)
        view.addSubview(button)
    }

    func makeConstraints() {
        NSLayoutConstraint.activate([
            newPasswordTextField.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -8),
            newPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            newPasswordTextField.heightAnchor.constraint(equalToConstant: 48),

            repeatPasswordTextField.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 8),
            repeatPasswordTextField.leadingAnchor.constraint(equalTo: newPasswordTextField.leadingAnchor),
            repeatPasswordTextField.trailingAnchor.constraint(equalTo: newPasswordTextField.trailingAnchor),
            repeatPasswordTextField.heightAnchor.constraint(equalToConstant: 48),

            button.topAnchor.constraint(equalTo: repeatPasswordTextField.bottomAnchor, constant: 24),
            button.leadingAnchor.constraint(equalTo: repeatPasswordTextField.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: repeatPasswordTextField.trailingAnchor),
            button.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    func makePasswordTextField(with placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 16)
        textField.placeholder = placeholder
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
    }

}

//MARK: - UITextFieldDelegate

extension ChangePasswordScreen: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }

}

//MARK: - Constants

private extension ChangePasswordScreen {

    enum Constants {
        static let updatePassword = "Update the password"
        static let newPassword = "New password"
        static let repeatPassword = "Repeat password"
        static let username = "username"
        static let minCount = 4
    }

}
