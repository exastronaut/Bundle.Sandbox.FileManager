//
//  SettingsScreen.swift
//  Bundle.Sandbox.FileManager
//
//  Created by Artem Sviridov on 30.10.2022.
//

import UIKit

final class SettingsScreen: UIViewController {

    private let settingsService = SettingsService()
    private var sortParameter = Sort.alphabetical

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 50
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        return tableView
    }()

    private lazy var switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.addTarget(self, action: #selector(switchButtonAction), for: .touchUpInside)
        return switchButton
    }()

    override func loadView() {
        super.loadView()

        customizeView()
        addSubviews()
        makeConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        checkSortParameter()
    }

}

private extension SettingsScreen {

    @objc
    func switchButtonAction() {
        settingsService.saveSortParameter(switchButton.isOn)
        changeSortParameter()
        changeSortCell()
    }

    func checkSortParameter() {
        guard let haveSortParameter = settingsService.getSortParameter() else { return }

        switchButton.isOn = haveSortParameter
        changeSortParameter()
    }

    func changeSortParameter() {
        sortParameter = switchButton.isOn ? .alphabetical : .reverse
    }

    func changeSortCell() {
        tableView.performBatchUpdates {
            let indexPath = IndexPath(row: .zero, section: .zero)
            let cell = tableView.cellForRow(at: indexPath)
            var content = cell?.defaultContentConfiguration()
            content?.text = sortParameter.rawValue
            cell?.contentConfiguration = content
        }
    }

    func customizeView() {
        view.backgroundColor = .systemBackground
        navigationItem.title = Constants.title
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func addSubviews() {
        view.addSubview(tableView)
    }

    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

}

extension SettingsScreen: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Constants.parametersCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()

        if indexPath.row == .zero {
            cell.accessoryView = switchButton
            cell.selectionStyle = .none
            content.text = sortParameter.rawValue
            cell.contentConfiguration = content
        } else {
            cell.accessoryType = .disclosureIndicator
            content.text = Constants.changePassword
            cell.contentConfiguration = content
        }

        return cell
    }

}

extension SettingsScreen: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let changePasswordScreen = ChangePasswordScreen()
            let navigationController = UINavigationController(rootViewController: changePasswordScreen)
            present(navigationController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

//MARK: - Constants

private extension SettingsScreen {

    enum Sort: String {
        case alphabetical = "Sort (alphabetical)"
        case reverse = "Sort (reverse)"
    }

    enum Constants {
        static let changePassword = "Change password"
        static let title = "Settings"
        static let parametersCount = 2
    }

}
