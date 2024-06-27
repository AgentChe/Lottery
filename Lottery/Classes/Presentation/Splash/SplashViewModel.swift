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
    
    private lazy var contentManager = ContentManager()
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
    }
    
    func configure(input: Input) -> Output {
        let didCompleteLogin = makeLogin(didCompleteValidation: input.didCompleteValidation)
        let didSyncLibrary = makeSyncLibrary(didCompleteLogin: didCompleteLogin)
        
        let route = makeRoute(didSyncLibrary: didSyncLibrary)
        
        return Output(route: route)
    }
}

// MARK: Private
private extension SplashViewModel {
    func makeRoute(didSyncLibrary: Signal<Void>) -> Driver<Route> {
        didSyncLibrary
            .compactMap { [weak self] _ -> Route? in
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
            .flatMapLatest { [weak self] _ -> Signal<Void> in
                guard let self = self else { return .never() }
                
                func source() -> Single<Void> {
                    Single.zip([
                        self.makeStates(),
                        self.makeLotteries()
                    ])
                    .mapToVoid()
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
    
    func makeLogin(didCompleteValidation: Signal<Void>) -> Signal<Void> {
        didCompleteValidation
            .flatMapLatest { [weak self] _ -> Signal<Void> in
                guard let self = self else { return .never() }
                
                let otterScaleID = OtterScale.shared.getInternalID()
                
                print(otterScaleID)
                
                func source() -> Single<Void> {
                    Single<Void>.create { single in
                        if let cachedToken = self.sessionManager.getSession()?.userToken {
                            if cachedToken != otterScaleID {
                                self.profileManager.syncTokens(
                                    oldToken: cachedToken,
                                    newToken: otterScaleID
                                ) { result in
                                    let error = result.error() ?? ContentError(.notContent)
                                    single(result.isSuccess ? .success(()) : .failure(error))
                                }
                            } else {
                                single(.success(()))
                            }
                        } else {
                            self.profileManager.login(userToken: otterScaleID) { result in
                                let error = result.error() ?? ContentError(.notContent)
                                single(result.isSuccess ? .success(()) : .failure(error))
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
    
    func makeStates() -> Single<Void> {
        Single<Void>.create { [weak self] single in
            guard let self else { return Disposables.create() }
            
            self.contentManager
                .fetchStates(forceUpdate: true) { result in
                    switch result {
                    case .success:
                        single(.success(Void()))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func makeLotteries() -> Single<Void> {
        Single<Void>.create { [weak self] single in
            guard let self else { return Disposables.create() }
            
            self.contentManager
                .fetchLotteries(forceUpdate: true) { result in
                    switch result {
                    case .success:
                        single(.success(Void()))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            
            return Disposables.create()
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
