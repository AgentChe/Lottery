//
//  SelectGameViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit

class SelectGameViewController: UIViewController {
    var onContinue: (([Int]) -> Void)?
    private let gamesManager: GamesManagerProtocol = GamesManager()
    private var games: [Game] = []

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
        fetchGames()
    }
    
    private func setupButtons() {
        selectGameView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        selectGameView.addAnotherGameButton.addTarget(self, action: #selector(addAnotherGameButtonTapped), for: .touchUpInside)
    }
    
    private func fetchGames() {
        gamesManager.fetchNextGames(stateId: nil) { [weak self] result in
            switch result {
            case .success(let games):
                self?.games = games
                self?.selectGameView.updateGames(games)
            case .failure(let error):
                print("Failed to fetch games: \(error)")
            }
        }
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
