//
//  MainViewCoordinator.swift
//  Lottery
//
//  Created by Андрей Чернышев on 23.05.2024.
//

import UIKit

final class MainViewCoordinator {
    weak var parentVC: MainViewController?
    
    lazy var drawsVC = NavigationController(rootViewController: drawsController)
    lazy var luckyNumbersVC = NavigationController(rootViewController: luckyNumbersController)
    lazy var myTicketsVC = NavigationController(rootViewController: myTicketsController)
    
    private lazy var drawsController = DrawsViewController() // TODO: заменить на актуальный
    private lazy var luckyNumbersController = UIViewController() // TODO: заменить на актуальный
    private lazy var myTicketsController = TicketsViewController() // TODO: заменить на актуальный
    
    private var previousVC: UIViewController?
    
    init(parentVC: MainViewController) {
        self.parentVC = parentVC
    }
    
    func change(tab: TabView.Tab) {
        parentVC?.mainView.tabView.selectedTab = tab
        
        switch tab {
        case .draws:
            changeVC(on: drawsVC)
        case .luckyNumbers:
            changeVC(on: luckyNumbersVC)
        case .myTickets:
            changeVC(on: myTicketsVC)
        }
    }
}

// MARK: Private
private extension MainViewCoordinator {
    func changeVC(on vc: UIViewController) {
        if let previousVC = self.previousVC {
            previousVC.willMove(toParent: nil)
            previousVC.view.removeFromSuperview()
            previousVC.removeFromParent()
        }
    
        self.previousVC = vc
        
        guard let parentVC = self.parentVC else {
            return
        }
    
        parentVC.addChild(vc)
        vc.view.frame = parentVC.mainView.container.bounds
        parentVC.mainView.container.addSubview(vc.view)
        vc.willMove(toParent: parentVC)
    }
}
