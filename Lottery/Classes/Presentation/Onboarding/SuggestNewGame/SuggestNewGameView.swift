//  SuggestNewGameView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit

final class SuggestNewGameView: UIView {
    
    // MARK: - UI Components
    
    let headerLabel: UILabel = {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.bold(size: 19.scale))
            .lineHeight(22.8.scale)
            .textAlignment(.left)
        
        let label = UILabel()
        label.attributedText = "Suggest a New Game".localized.attributed(with: attrs)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let attrs = TextAttributes()
            .textColor(Appearance.main300)
            .font(Fonts.Inter.medium(size: 15.scale))
            .lineHeight(18.scale)
            .textAlignment(.left)
        
        let label = UILabel()
        label.attributedText = "Let us know which game you want to monitor. We will add it to shortly on the list.".localized.attributed(with: attrs)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let textField: InsetTextField = {
        let textField = InsetTextField()
        let attrs = TextAttributes()
            .textColor(Appearance.main300)
            .font(Fonts.Inter.medium(size: 15.scale))
        
        textField.attributedPlaceholder = "  Type in the game title".localized.attributed(with: attrs)
        textField.font = Fonts.Inter.medium(size: 15.scale)
        textField.textColor = Appearance.mono200
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        
        let attrs = TextAttributes()
            .textColor(.white)
            .font(Fonts.Inter.medium(size: 17.scale))
        
        let attributedTitle = "Save".localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.medium(size: 17.scale))
        
        let attributedTitle = "Cancel".localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        button.layer.borderWidth = 1.scale
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "SuggestNewGame.Close"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods

private extension SuggestNewGameView {
    func setupView() {
        backgroundColor = Appearance.main500
        
        addSubview(headerLabel)
        addSubview(descriptionLabel)
        addSubview(textField)
        addSubview(saveButton)
        addSubview(cancelButton)
        addSubview(dismissButton)
        
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 83.scale),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50.scale),
            
            dismissButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            dismissButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            dismissButton.widthAnchor.constraint(equalToConstant: 24.scale),
            dismissButton.heightAnchor.constraint(equalToConstant: 24.scale),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10.scale),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            
            textField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20.scale),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale),
            textField.heightAnchor.constraint(equalToConstant: 44.scale),
            
            saveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            saveButton.heightAnchor.constraint(equalToConstant: 50.scale),
            saveButton.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor, constant: -20.scale),
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 10.scale),
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            cancelButton.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        endEditing(true)
    }
}
