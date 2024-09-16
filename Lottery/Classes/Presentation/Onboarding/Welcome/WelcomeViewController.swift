//  WelcomeViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit

class WelcomeViewController: UIViewController {
    var onContinue: (() -> Void)?
    private let welcomeView = WelcomeView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func loadView() {
        view = welcomeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
        
        AmplitudeManager.shared.logEvent(name: "Welcome Screen")
    }
}

// MARK: - Private Methods

private extension WelcomeViewController {
    func setupButton() {
        welcomeView.startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    @objc func startButtonTapped() {
        onContinue?()
    }
}
