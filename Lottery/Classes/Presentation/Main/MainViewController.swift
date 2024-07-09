//
//  MainViewController.swift
//  Printer
//
//  Created by Андрей Чернышев on 24.04.2024.
//

import UIKit
import RxSwift

final class MainViewController: UIViewController {
    lazy var mainView = MainView()
    
    private lazy var disposeBag = DisposeBag()
    
    lazy var coordinator = MainViewCoordinator(parentVC: self)
    
    private let requestReview: Bool
    
    private init(requestReview: Bool) {
        self.requestReview = requestReview
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }  

//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        .lightContent
//    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rx.methodInvoked(#selector(UIViewController.viewDidLayoutSubviews))
            .take(1)
            .map { _ in TabView.Tab.draws }
            .bind(to: Binder(self) { base, tab in
                base.update(selectedTab: tab)
            })
            .disposed(by: disposeBag)
        
        requestReviewIfNeeded()
        addActionsToTabs()
    }
    
}

// MARK: Make
extension MainViewController {
    static func make(requestReview: Bool = false) -> MainViewController {
        MainViewController(requestReview: requestReview)
    }
}

// MARK: Private
private extension MainViewController {
    func requestReviewIfNeeded() {
        guard requestReview else {
            return
        }

        RequestReview.request()
    }
    
    func addActionsToTabs() {
        Observable
            .merge([
                mainView.tabView.drawsItem
                    .rx.tap.map { TabView.Tab.draws },
                
                mainView.tabView.luckyNumbersItem
                    .rx.tap.map { TabView.Tab.luckyNumbers },
                
                mainView.tabView.myTicketsItem
                    .rx.tap.map { TabView.Tab.myTickets }
            ])
            .bind(to: Binder(self) { base, tab in
                base.update(selectedTab: tab)
            })
            .disposed(by: disposeBag)
    }
    
    func update(selectedTab: TabView.Tab) {
        coordinator.change(tab: selectedTab)
    }
}
