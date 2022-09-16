//
//  ViewControllerManager.swift
//  SwiftUtils
//
//  Created by Bastien Lebrun on 22/05/2022.
//

import UIKit
/*
edit current scheme > duplicate scheme
 project > info > duplicate debug > debug mock
 manage scheme > build & choosen steps > debug mock
 project > build settings > other flags > add mock in debug mock


 */
enum ServiceConfiguration {
    case mock
    case webService
}

struct Constants {
    #if MOCK
    static let serviceConfiguration: ServiceConfiguration = .mock
    #else
    static let serviceConfiguration: ServiceConfiguration = .webService
    #endif
}

struct ViewControllerManager {

    static var controller: SampleViewController {
        let service: SampleServicing
        switch Constants.serviceConfiguration {
        case .mock:
            service = SampleMockService()
        case .webService:
            service = SampleService()
        }

        let viewModel = SampleViewModel(service: service)
        let viewController = SampleViewController() // Instantiate xib or storyboard or code controller here
        viewController.viewModel = viewModel
        return viewController
    }

}

// Sample

protocol SampleServicing {
    func getSomething()
}
class SampleService: SampleServicing {

    func getSomething() {

    }
}
class SampleMockService: SampleServicing {

    func getSomething() {

    }
}

class SampleViewModel {

    let service: SampleServicing

    init(service: SampleServicing) {
        self.service = service
    }
}

class SampleViewController: UIViewController {

    let viewModel: SampleViewModel!

    func navigateToViewController() {

    }

}
