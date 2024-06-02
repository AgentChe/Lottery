//
//  WelcomeViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit

class WelcomeViewController: UIViewController {
    var onContinue: (() -> Void)?
    
    private let welcomeView = WelcomeView()
    
    override func loadView() {
        view = welcomeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
    }
    
    private func setupButton() {
        welcomeView.startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    @objc private func startButtonTapped() {
        onContinue?()
    }
}
