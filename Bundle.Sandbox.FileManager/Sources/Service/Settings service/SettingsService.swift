//
//  SettingsService.swift
//  Bundle.Sandbox.FileManager
//
//  Created by Artem Sviridov on 04.11.2022.
//

import Foundation

struct SettingsService {

    private let sortKey = "Sort"

}

extension SettingsService {

    func saveSortParameter(_ flag: Bool) {
        UserDefaults.standard.set(flag, forKey: sortKey)
    }

    func getSortParameter() -> Bool? {
        UserDefaults.standard.value(forKey: sortKey) as? Bool
    }

}
