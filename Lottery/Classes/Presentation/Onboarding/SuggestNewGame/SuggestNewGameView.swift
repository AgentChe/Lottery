//  SuggestNewGameView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit

final class SuggestNewGameView: UIView {
    let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "SELECT THE GAME"
        label.font = Fonts.Inter.bold(size: 19.scale)
        label.textColor = Appearance.mono200
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
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
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "  Type in the game title"
        textField.font = Fonts.Inter.medium(size: 15.scale)
        textField.textColor = Appearance.mono200
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // Setting placeholder text color
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Appearance.main300
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "  Type in the game title", attributes: placeholderAttributes)
        
        return textField
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.medium(size: 17.scale)
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let cancelButton: UIButton = {
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
    
    let dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "SuggestNewGame.Close"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var bottomConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = Appearance.main500
        
        addSubview(headerLabel)
        addSubview(dismissButton)
        addSubview(descriptionLabel)
        addSubview(textField)
        addSubview(saveButton)
        addSubview(cancelButton)
        
        bottomConstraint = saveButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50.scale)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 63.scale),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            headerLabel.trailingAnchor.constraint(equalTo: dismissButton.leadingAnchor, constant: -10.scale),
            
            dismissButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            dismissButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            dismissButton.widthAnchor.constraint(equalToConstant: 24.scale),
            dismissButton.heightAnchor.constraint(equalToConstant: 24.scale),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 14.scale),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            
            textField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 25.scale),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale),
            textField.heightAnchor.constraint(equalToConstant: 44.scale),
            
            saveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            saveButton.heightAnchor.constraint(equalToConstant: 50.scale),
            bottomConstraint,
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 10.scale),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            cancelButton.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        endEditing(true)
    }
}
