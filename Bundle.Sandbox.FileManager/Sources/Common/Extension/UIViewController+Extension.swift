//
//  UIViewController+Extension.swift
//  Bundle.Sandbox.FileManager
//
//  Created by Artem Sviridov on 30.10.2022.
//

import UIKit

extension UIViewController {

    func showAlert(title: String,
                   message: String,
                   actions: [UIAlertAction]? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        if actions == nil {
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
        } else {
            actions?.forEach { alert.addAction($0) }
        }

        present(alert, animated: true)
    }

}
