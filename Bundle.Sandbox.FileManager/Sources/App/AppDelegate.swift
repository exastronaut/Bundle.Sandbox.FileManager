//
//  AppDelegate.swift
//  Bundle.Sandbox.FileManager
//
//  Created by Артем Свиридов on 09.10.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: GalleryScreen())
        window?.makeKeyAndVisible()

        return true
    }

}

