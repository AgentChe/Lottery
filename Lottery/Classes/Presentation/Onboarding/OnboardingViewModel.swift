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
    
    // MARK: Public
    func whatNext() -> Step {
        sessionManager.hasActiveSubscriptions() ? .main : .paygate
    }
}
