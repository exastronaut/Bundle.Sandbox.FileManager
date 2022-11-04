//
//  MainTabBarScreen.swift
//  Bundle.Sandbox.FileManager
//
//  Created by Artem Sviridov on 02.11.2022.
//


import UIKit

class MainTabBarScreen: UITabBarController {


    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.isHidden = true
    }

}

private extension MainTabBarScreen {

    func setupTabBar() {
        let galleryScreen = makeNavigationController(
            viewController: GalleryScreen(),
            itemName: "Gallery",
            itemImage: "folder"
        )
        let settingsScreen = makeNavigationController(
            viewController: SettingsScreen(),
            itemName: "Settings",
            itemImage: "gear"
        )

        viewControllers = [galleryScreen, settingsScreen]
    }

    private func makeNavigationController(viewController: UIViewController,
                                          itemName: String,
                                          itemImage: String) -> UINavigationController {

        let item = UITabBarItem(
            title: itemName,
            image: UIImage(systemName: itemImage),
            tag: 0
        )
        let navigationController = UINavigationController(rootViewController: viewController)

        navigationController.tabBarItem = item
        return navigationController
    }


}
