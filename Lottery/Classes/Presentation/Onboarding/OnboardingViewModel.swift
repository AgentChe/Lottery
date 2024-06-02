//
//  OnboardingViewModel.swift
//  Soccer
//
//  Created by Андрей Чернышев on 23.08.2022.
//

import Foundation

final class OnboardingViewModel {
    enum Step {
        case paygate, main
    }
    
    private lazy var sessionManager = SessionManager()
    private let profileManager: ProfileManagerProtocol = ProfileManager() // Inject ProfileManager
    
    // MARK: Public
    func whatNext() -> Step {
        sessionManager.hasActiveSubscriptions() ? .main : .paygate
    }
    
    func setProfile(state: Int?, lotteries: [Int], completion: @escaping (Result<Void, Error>) -> Void) {
        profileManager.setProfile(lotteries: lotteries, state: state) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
