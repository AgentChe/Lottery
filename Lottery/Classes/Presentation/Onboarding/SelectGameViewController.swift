//
//  SelectGameViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//


import UIKit

class SelectGameViewController: UIViewController {
    var onContinue: (() -> Void)?
    
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
        onContinue?()
    }
}
