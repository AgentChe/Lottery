
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
        setupKeyboardObservers()
        setupButtonActions()
    }
    
    private func setupButtonActions() {
        suggestNewGameView.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        suggestNewGameView.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        suggestNewGameView.dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
                    self?.showToast(message: "Failed to suggest a new game: \(error.localizedDescription)")
                }
            }
        }
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
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            suggestNewGameView.bottomConstraint.constant = -keyboardFrame.height - 40.scale
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        suggestNewGameView.bottomConstraint.constant = -50.scale
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
