//  SuggestNewGameViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit

final class SuggestNewGameViewController: UIViewController {
    private let suggestNewGameView = SuggestNewGameView()
    
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
        // Handle saving the new game
       // dismiss(animated: true, completion: nil)
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
