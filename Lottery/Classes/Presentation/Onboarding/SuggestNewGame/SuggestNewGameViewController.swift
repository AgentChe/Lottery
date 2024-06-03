
//  SuggestNewGameViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit

final class SuggestNewGameViewController: UIViewController {
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "SELECT THE GAME"
        label.font = Fonts.Inter.bold(size: 19.scale)
        label.textColor = Appearance.mono200
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Let us know which game you want to monitor. We will add it to shortly on the list."
        label.font = Fonts.Inter.medium(size: 15.scale)
        label.textColor = Appearance.main300
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6.scale  // Adjust this value as needed
        
        let attributedString = NSMutableAttributedString(string: label.text ?? "")
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter game name"
        textField.font = Fonts.Inter.medium(size: 15.scale)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.medium(size: 17.scale)
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(Appearance.mono200, for: .normal)
        button.titleLabel?.font = Fonts.Inter.medium(size: 17.scale)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        button.layer.borderWidth = 1.scale
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupKeyboardObservers()
    }
    
    private func setupView() {
        view.backgroundColor = Appearance.main500
        
        view.addSubview(headerLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(textField)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)
        
        bottomConstraint = saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50.scale)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 83.scale),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.scale),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10.scale),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.scale),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            
            textField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20.scale),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.scale),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12.scale),
            textField.heightAnchor.constraint(equalToConstant: 44.scale),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            saveButton.heightAnchor.constraint(equalToConstant: 50.scale),
            bottomConstraint,
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 10.scale),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            cancelButton.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func saveButtonTapped() {
        // Handle saving the new game
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            bottomConstraint.constant = -keyboardFrame.height - 20.scale
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        bottomConstraint.constant = -50.scale
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
