//
//  Coordinator.swift
//  SwiftUtils
//
//  Created by Bastien Lebrun on 22/05/2022.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get }
    var navigationController: UINavigationController { get }

    func start()
}

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    let navigationController = UINavigationController()

    func start() {
        let rootViewController = ViewControllerManager.controller
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.pushViewController(rootViewController, animated: false)
    }
}


/*

scene delegate

new var mainCoordinator optional

 func scene willConnectTo()

 guard let windowScene = (scene as? UIWindowScene) else { return }

 window = UIWindow(frame: UIScreen.main.bounds)
 mainCoordinator = MainCoordinator()
 mainCoordinator?.start()
 window?.rootViewController = mainCoordinator?.navigationController
 window?.makeKeyAndVisible()

 */
