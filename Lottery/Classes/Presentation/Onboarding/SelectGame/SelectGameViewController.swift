//
//  SelectGameViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//


import UIKit

import UIKit

class SelectGameViewController: UIViewController {
    var onContinue: (([Int]) -> Void)?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    private let selectGameView = SelectGameView()
    
    override func loadView() {
        view = selectGameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
    }
    
    private func setupButton() {
        selectGameView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    @objc private func continueButtonTapped() {
        let selectedGames = selectGameView.getSelectedGames()
        onContinue?(selectedGames)
    }
}
