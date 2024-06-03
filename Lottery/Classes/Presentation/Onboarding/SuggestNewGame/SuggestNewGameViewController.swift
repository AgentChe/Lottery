//
//  SuggestNewGameViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit
import Toast_Swift

final class SuggestNewGameViewController: UIViewController {
    private let suggestNewGameView = SuggestNewGameView()
    private let gamesManager: GamesManagerProtocol = GamesManager()

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
    
    private func setupButtonActions() {
        suggestNewGameView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        suggestNewGameView.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        suggestNewGameView.dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
    }
    
    @objc private func saveButtonTapped() {
        guard let gameTitle = suggestNewGameView.textField.text, !gameTitle.isEmpty else {
            showToast(message: "Please enter a game title.")
            return
        }
        suggestNewGame(gameTitle: gameTitle)
    }
    
    private func suggestNewGame(gameTitle: String) {
        gamesManager.suggestNewGame(gameTitle: gameTitle) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showToast(message: "Thanks for adding a new game! We will consider adding it to the list.")
                case .failure(let error):
                    print("Failed to suggest a new game: \(error)")
                    self?.showAlert(message: "Failed to suggest a new game. Please try again.")
                }
            }
        }
    }
  
    private func showAlert(message: String, isError: Bool = true) {
         let alert = UIAlertController(title: isError ? "Error" : "Success", message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default))
         present(alert, animated: true)
    }
    private func showToast(message: String) {
        var style = ToastStyle()
        style.backgroundColor = Appearance.mono200
        style.messageColor = .white
        style.messageAlignment = .center
        style.horizontalPadding = 24.0.scale
        style.verticalPadding = 24.0.scale
        style.titleFont = Fonts.Inter.medium(size: 16.scale)
        self.view.makeToast(message, duration: 3.0, position: .top, style: style)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
