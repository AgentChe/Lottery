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
        suggestNewGameView.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        updateSaveButtonState()
    }
}

// MARK: - Private Methods

private extension SuggestNewGameViewController {
    func setupButtonActions() {
        suggestNewGameView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        suggestNewGameView.cancelButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        suggestNewGameView.dismissButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
    }
    
    @objc func saveButtonTapped() {
        guard suggestNewGameView.saveButton.isEnabled else { return }
        guard let gameTitle = suggestNewGameView.textField.text, !gameTitle.isEmpty else {
            showToast(message: "SuggestNewGameViewController.EnterGameTitle".localized)
            return
        }
        suggestNewGame(gameTitle: gameTitle)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    func updateSaveButtonState() {
        let isTextEmpty = suggestNewGameView.textField.text?.isEmpty ?? true
        suggestNewGameView.saveButton.isEnabled = !isTextEmpty
        suggestNewGameView.saveButton.backgroundColor = isTextEmpty ? Appearance.main100.withAlphaComponent(0.5) : Appearance.main100
    }
    
    func suggestNewGame(gameTitle: String) {
        gamesManager.suggestNewGame(gameTitle: gameTitle) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showToast(message: "Thanks for adding a new game! We will consider adding it to the list.".localized, duration: 0.45)
                    self?.suggestNewGameView.textField.resignFirstResponder()
                    delay(0.7) {
                        self?.dismissViewController() 
                    }
                case .failure(let error):
                    self?.presentTryAgainViewController(with: error, gameTitle: gameTitle)
                }
            }
        }
    }
    
    func showToast(message: String, duration: CGFloat = 3.0) {
        var style = ToastStyle()
        style.backgroundColor = Appearance.mono200
        style.messageColor = .white
        style.messageAlignment = .center
        style.horizontalPadding = 24.0.scale
        style.verticalPadding = 24.0.scale
        style.titleFont = Fonts.Inter.medium(size: 16.scale)
        self.view.makeToast(message, duration: duration, position: .top, style: style)
    }
    
    func presentTryAgainViewController(with error: Error, gameTitle: String) {
        let retryHandler: () -> Void = { [weak self] in
            self?.suggestNewGame(gameTitle: gameTitle)
        }
        let vc = TryAgainViewController.make(error: error, tryAgain: retryHandler)
        self.present(vc, animated: true)
    }
    
    @objc func dismissViewController() {
        suggestNewGameView.resetCancelButtonBottomConstraint()
        dismiss(animated: true, completion: nil)
    }
}
