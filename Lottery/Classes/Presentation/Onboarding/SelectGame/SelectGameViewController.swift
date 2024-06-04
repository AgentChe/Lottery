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

    private let selectGameView = SelectGameView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func loadView() {
        view = selectGameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        fetchGames()
    }
}

// MARK: - Private Methods

private extension SelectGameViewController {
    func setupButtons() {
        selectGameView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        selectGameView.addAnotherGameButton.addTarget(self, action: #selector(addAnotherGameButtonTapped), for: .touchUpInside)
    }
    
    func fetchGames() {
        gamesManager.fetchNextGames(stateId: nil) { [weak self] result in
            switch result {
            case .success(let games):
                self?.games = games
                self?.selectGameView.updateGames(games)
            case .failure(let error):
                self?.presentTryAgainViewController(with: error)
            }
        }
    }
    
    @objc func continueButtonTapped() {
        let selectedGames = selectGameView.getSelectedGames()
        if selectedGames.isEmpty {
            presentTryAgainViewController(with: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please select at least one game."]))
            return
        }
        
        // Show preloader and hide button
        selectGameView.continueButton.isHidden = true
        selectGameView.preloader.startAnimating()
        
        onContinue?(selectedGames)
    }
    
    @objc func addAnotherGameButtonTapped() {
        let suggestNewGameVC = SuggestNewGameViewController()
        suggestNewGameVC.modalPresentationStyle = .fullScreen
        present(suggestNewGameVC, animated: true, completion: nil)
    }
    
    func presentTryAgainViewController(with error: Error) {
        let vc = TryAgainViewController.make(error: error) { [weak self] in
            self?.fetchGames()
        }
        present(vc, animated: true)
    }
}

