// Copyright DApps Platform Inc. All rights reserved.

import Foundation


final class CoinMarketCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    let navigationController: NavigationController
    
    lazy var rootViewController: CoinMarketTableViewController = {
        let controller = CoinMarketTableViewController()
        controller.modalPresentationStyle = .pageSheet
        return controller
    }()
    
    init(
        navigationController: NavigationController = NavigationController()
        ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
    }
    func start() {
        navigationController.viewControllers = [rootViewController]
    }
}
