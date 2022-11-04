//
//  PasswordService.swift
//  Bundle.Sandbox.FileManager
//
//  Created by Artem Sviridov on 30.10.2022.
//

import Foundation

struct PasswordService {

    func setPassword(with credentials: Credentials) {
        guard let password = credentials.password, let passData = password.data(using: .utf8) else {
            print("Невозможно получить данные типа Data из пароля.")
            return
        }

        let attributes = [
            kSecClass: kSecClassGenericPassword,
            kSecValueData: passData,
            kSecAttrAccount: credentials.username,
            kSecAttrService: credentials.serviceName,
        ] as CFDictionary

        let status = SecItemAdd(attributes, nil)

        guard status == errSecSuccess else {
            print("Невозможно добавить пароль, ошибка номер: \(status).")
            return
        }
    }

    func getPassword(for credentials: Credentials) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: credentials.serviceName,
            kSecAttrAccount: credentials.username,
            kSecReturnData: true
        ] as CFDictionary

        var extractedData: AnyObject?

        let status = SecItemCopyMatching(query, &extractedData)

        guard status != errSecItemNotFound else {
            print("Пароль не найден в Keychain.")
            return nil
        }

        guard status == errSecSuccess else {
            print("Невозможно получить пароль, ошибка номер: \(status).")
            return nil
        }

        guard let passData = extractedData as? Data,
              let password = String(data: passData, encoding: .utf8) else {
            print("Невозможно преобразовать Data в пароль.")
            return nil
        }

        return password
    }

    func havePassword(for credentials: Credentials) -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: credentials.serviceName,
            kSecAttrAccount: credentials.username
        ] as CFDictionary

        let status = SecItemCopyMatching(query, nil)

        guard status != errSecItemNotFound else {
            print("Пароль не найден в Keychain.")
            return false
        }

        return true
    }

    func updatePassword(for credentials: Credentials) {
        guard let password = credentials.password, let passData = password.data(using: .utf8) else {
            print("Невозможно получить Data из пароля.")
            return
        }

        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: credentials.serviceName,
            kSecAttrAccount: credentials.username
        ] as CFDictionary

        let attributesToUpdate = [
            kSecValueData: passData,
        ] as CFDictionary

        let status = SecItemUpdate(query, attributesToUpdate)

        guard status == errSecSuccess else {
            print("Невозможно обновить пароль, ошибка номер: \(status).")
            return
        }
    }

    func deletePassword(for credentials: Credentials) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: credentials.serviceName,
            kSecAttrAccount: credentials.username
        ] as CFDictionary

        let status = SecItemDelete(query)

        guard status == errSecSuccess else {
            print("Невозможно удалить пароль, ошибка номер: \(status).")
            return
        }
    }

}

