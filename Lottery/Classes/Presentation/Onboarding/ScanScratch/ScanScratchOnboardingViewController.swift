//
//  ScanScratchOnboardingViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 9/3/24.
//

import UIKit

class ScanScratchViewController: UIViewController {
    var onContinue: (() -> Void)?
    private let scanScratchView = ScanScratchView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
 
    override func loadView() {
        view = scanScratchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButton()
    }
}

// MARK: - Private Methods

private extension ScanScratchViewController {
    func setupButton() {
        scanScratchView.startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    @objc func startButtonTapped() {
        onContinue?()
    }
}

