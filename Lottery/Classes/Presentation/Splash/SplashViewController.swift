//
//  SplashViewController.swift
//  Soccer
//
//  Created by Андрей Чернышев on 05.07.2022.
//

import UIKit
import RxSwift
import RxCocoa

import UIKit
import RxSwift
import RxCocoa

final class SplashViewController: UIViewController {
    private lazy var mainView = SplashView()
    
    private lazy var viewModel = SplashViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var sdkInitialize = SplashReceiptValidationObserver()
    
    private lazy var didCompleteValidationTrigger = PublishRelay<Void>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.open(error: error)
        }
        
        let output = viewModel.configure(input: SplashViewModel.Input(
            didCompleteValidation: didCompleteValidationTrigger.asSignal()
        ))
        
        output.route
            .drive(Binder(self) { base, route in
                base.goNext(route: route)
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] error in
                self?.handleError(error)
            })
            .disposed(by: disposeBag)
        
        sdkInitialize.observe { [weak self] in
            self?.didCompleteValidationTrigger.accept(Void())
        }
    }
    
    private func handleError(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.didCompleteValidationTrigger.accept(Void())
        }
        alertController.addAction(retryAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: Make
extension SplashViewController {
    static func make() -> SplashViewController {
        SplashViewController()
    }
}

// MARK: Private
private extension SplashViewController {
    func goNext(route: SplashViewModel.Route) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.route(route)
        }
    }
    
    func route(_ route: SplashViewModel.Route) {
        switch route {
        case .onboarding:
            UIApplication.shared.keyWindow?.rootViewController = OnboardingViewController.make()
        case .main:
            let nc = NavigationController(rootViewController: MainViewController.make())
            nc.setNavigationBarHidden(true, animated: false)
        case .paygate:
            let vc = PaygateViewController.make { [weak self] in
                self?.route(.main)
            }
            present(vc, animated: true)
        }
    }
    
    func open(error: Error) -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self = self else {
                    return Disposables.create()
                }
                
                let vc = TryAgainViewController.make(error: error) {
                    observe.onNext(())
                    observe.onCompleted()
                }
                self.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
}
