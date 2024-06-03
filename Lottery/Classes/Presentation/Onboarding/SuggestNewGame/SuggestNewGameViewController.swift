//
//  SuggestNewGameViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit
import Toast_Swift

final class SuggestNewGameViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let suggestNewGameView = SuggestNewGameView()
    private let gamesManager: GamesManagerProtocol = GamesManager()
    
    // MARK: - Lifecycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func loadView() {
        view = suggestNewGameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonActions()
    }
}

// MARK: - Private Methods

private extension SuggestNewGameViewController {
    func setupButtonActions() {
        suggestNewGameView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        suggestNewGameView.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        suggestNewGameView.dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
    }
    
    @objc func saveButtonTapped() {
        guard let gameTitle = suggestNewGameView.textField.text, !gameTitle.isEmpty else {
            showToast(message: "Please enter a game title.")
            return
        }
        suggestNewGame(gameTitle: gameTitle)
    }
    
    func suggestNewGame(gameTitle: String) {
        gamesManager.suggestNewGame(gameTitle: gameTitle) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showToast(message: "Thanks for adding a new game! We will consider adding it to the list.")
                case .failure(let error):
                    print("Failed to suggest a new game: \(error)")
                    self?.presentTryAgainViewController(with: error)
                }
            }
        }
    }
    
    func showToast(message: String) {
        var style = ToastStyle()
        style.backgroundColor = Appearance.mono200
        style.messageColor = .white
        style.messageAlignment = .center
        style.horizontalPadding = 24.0.scale
        style.verticalPadding = 24.0.scale
        style.titleFont = Fonts.Inter.medium(size: 16.scale)
        self.view.makeToast(message, duration: 3.0, position: .top, style: style)
    }
    
    func presentTryAgainViewController(with error: Error) {
        let vc = TryAgainViewController.make(error: error)
        self.present(vc, animated: true)
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
