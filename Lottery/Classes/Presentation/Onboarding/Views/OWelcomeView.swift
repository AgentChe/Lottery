//
//  OWelcomeView.swift
//  Lottery
//
//  Created by Андрей Чернышев on 23.05.2024.
//

import UIKit

final class OWelcomeView: OSlideView {
    override init(step: OnboardingView.Step) {
        super.init(step: step)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension OWelcomeView {
    func makeConstraints() {
        
    }
}

// MARK: Lazy initialization
private extension OWelcomeView {
    
}
