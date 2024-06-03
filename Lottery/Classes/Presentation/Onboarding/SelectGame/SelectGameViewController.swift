//
//  SelectGameViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//


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
        setupButtons()
    }
    
    private func setupButtons() {
        selectGameView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        selectGameView.addAnotherGameButton.addTarget(self, action: #selector(addAnotherGameButtonTapped), for: .touchUpInside)
    }
    
    @objc private func continueButtonTapped() {
        let selectedGames = selectGameView.getSelectedGames()
        onContinue?(selectedGames)
    }
    
    @objc private func addAnotherGameButtonTapped() {
        let suggestNewGameVC = SuggestNewGameViewController()
        suggestNewGameVC.modalPresentationStyle = .fullScreen
        present(suggestNewGameVC, animated: true, completion: nil)
    }
}
