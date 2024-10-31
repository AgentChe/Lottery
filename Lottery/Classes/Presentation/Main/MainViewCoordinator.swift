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
    lazy var generatorVC = NavigationController(rootViewController: generatorController)
    
    private lazy var drawsController = DrawsViewController()
    private lazy var generatorController = GeneratorViewController()
    
    private var previousVC: UIViewController?
    
    init(parentVC: MainViewController) {
        self.parentVC = parentVC
    }
    
    func change(tab: TabView.Tab) {
        parentVC?.mainView.tabView.selectedTab = tab
        
        switch tab {
        case .draws:
            changeVC(on: drawsVC)
        case .generator:
            changeVC(on: generatorVC)
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
        vc.didMove(toParent: parentVC)
    }
}



