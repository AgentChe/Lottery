//
//  SplashViewModel.swift
//  Lottery
//
//  Created by Андрей Чернышев on 23.05.2024.
//

import RxSwift
import RxCocoa
import OtterScaleiOS

final class SplashViewModel {
    enum Route {
        case onboarding, main, paygate
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var sessionManager = SessionManager()
    private lazy var profileManager = ProfileManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension SplashViewModel {
    struct Input {
        let didCompleteValidation: Signal<Void>
    }
    
    struct Output {
        let route: Driver<Route>
        let error: Driver<Error>
    }
    
    func configure(input: Input) -> Output {
        let didCompleteLogin = makeLogin(didCompleteValidation: input.didCompleteValidation)
        let didSyncLibrary = makeSyncLibrary(didCompleteLogin: didCompleteLogin)
        
        let route = makeRoute(didSyncLibrary: didSyncLibrary)
        let error = didSyncLibrary
            .asObservable()
            .materialize()
            .filter { event in
                if case .error = event {
                    return true
                }
                return false
            }
            .map { event in
                switch event {
                case .error(let error):
                    return error
                default:
                    return nil
                }
            }
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(route: route, error: error)
    }
}

// MARK: Private
private extension SplashViewModel {
    func makeRoute(didSyncLibrary: Signal<Void>) -> Driver<Route> {
        didSyncLibrary
            .compactMap { [weak self] void -> Route? in
                guard let self else { return nil }
                
                guard OnboardingViewController.wasViewed() else {
                    return .onboarding
                }
                
                let hasActiveSubscriptions = self.sessionManager.hasActiveSubscriptions()
                return hasActiveSubscriptions ? .main : .paygate
            }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeSyncLibrary(didCompleteLogin: Signal<Void>) -> Signal<Void> {
        didCompleteLogin
            .flatMapLatest { void -> Signal<Void> in
                return Observable<Void>.create { observer in
                    DataManager.shared.preloadData { error in
                        if let error = error {
                            observer.onError(error)
                        } else {
                            observer.onNext(())
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
                .asSignal(onErrorSignalWith: .never())
            }
    }
    
    func makeLogin(didCompleteValidation: Signal<Void>) -> Signal<Void> {
        didCompleteValidation
            .flatMapLatest { [weak self] void -> Signal<Void> in
                guard let self else { return .never() }
                
                let otterScaleID = OtterScale.shared.getInternalID()
                
                func source() -> Single<Void> {
                    Single<Void>.create { single in
                        if let cachedToken = self.sessionManager.getSession()?.userToken {
                            if cachedToken != otterScaleID {
                                self.profileManager.syncTokens(
                                    oldToken: cachedToken,
                                    newToken: otterScaleID
                                ) { result in
                                    let error = result.error() ?? ContentError(.notContent)
                                    single(result.isSuccess ? .success(Void()) : .failure(error))
                                }
                            } else {
                                single(.success(Void()))
                            }
                        } else {
                            self.profileManager.login(userToken: otterScaleID) { result in
                                let error = result.error() ?? ContentError(.notContent)
                                single(result.isSuccess ? .success(Void()) : .failure(error))
                            }
                        }
                        
                        return Disposables.create()
                    }
                    .do(onSuccess: { [weak self] in
                        let session = Session(userToken: otterScaleID)
                        self?.sessionManager.store(session: session)
                    })
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(
                        source: { source() },
                        trigger: { trigger(error: $0) }
                    )
                    .asSignal(onErrorSignalWith: .never())
            }
    }
}

// MARK: Additional
private extension LoginResult {
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .error:
            return false
        }
    }
    
    func error() -> Error? {
        switch self {
        case .success:
            return nil
        case .error(let error):
            return error
        }
    }
}
