//
//  CustomAlertViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/17/24.
//

import UIKit

class CustomAlertViewController: UIViewController {

    var onConfirmDelete: (() -> Void)?
    var onCancel: (() -> Void)?
    
    // Main container view for the alert
    private let alertContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 15.scale
        view.layer.masksToBounds = true
        return view
    }()
    
    private let alertImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EditTickets.DeleteAlert")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "CustomAlertViewController.Title".localized
        label.font = Fonts.Inter.bold(size: 16.scale) // Using the custom font
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("CustomAlertViewController.DeleteButton".localized, for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.semiBold(size: 16.scale) // Using the custom font
        button.layer.cornerRadius = 22.scale
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("CustomAlertViewController.CancelButton".localized, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = Fonts.Inter.regular(size: 16.scale) // Using the custom font
        button.layer.cornerRadius = 22.scale
        button.layer.borderWidth = 1.scale
        button.layer.borderColor = Appearance.lightGrayBorderTicket.cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        setupUI()
        setupAlertViewConstraints()
    }
    
    private func setupUI() {
        view.addSubview(alertContainerView)
        alertContainerView.addSubview(alertImageView)
        alertContainerView.addSubview(titleLabel)
        alertContainerView.addSubview(deleteButton)
        alertContainerView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            // Constraints for the alert container view
            alertContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertContainerView.widthAnchor.constraint(equalToConstant: 295.scale),
            alertContainerView.heightAnchor.constraint(equalToConstant: 405.scale),
            
            // Constraints for the alert image view
            alertImageView.centerXAnchor.constraint(equalTo: alertContainerView.centerXAnchor),
            alertImageView.topAnchor.constraint(equalTo: alertContainerView.topAnchor, constant: 50.scale),
            alertImageView.widthAnchor.constraint(equalToConstant: 133.scale),
            alertImageView.heightAnchor.constraint(equalToConstant: 133.scale),
            
            // Constraints for the title label
            titleLabel.topAnchor.constraint(equalTo: alertImageView.bottomAnchor, constant: 10.scale),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 185.scale),
            titleLabel.heightAnchor.constraint(equalToConstant: 44.scale),
            
            // Constraints for the delete button
            deleteButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.scale),
            deleteButton.widthAnchor.constraint(equalToConstant: 195.scale),
            deleteButton.heightAnchor.constraint(equalToConstant: 44.scale),
            deleteButton.centerXAnchor.constraint(equalTo: alertContainerView.centerXAnchor),
            
            // Constraints for the cancel button
            cancelButton.topAnchor.constraint(equalTo: deleteButton.bottomAnchor, constant: 10.scale),
            cancelButton.widthAnchor.constraint(equalToConstant: 195.scale),
            cancelButton.heightAnchor.constraint(equalToConstant: 44.scale),
            cancelButton.bottomAnchor.constraint(equalTo: alertContainerView.bottomAnchor, constant: -30.scale),
            cancelButton.centerXAnchor.constraint(equalTo: alertContainerView.centerXAnchor)
        ])
    }
    
    private func setupAlertViewConstraints() {
        // The constraints for alertContainerView are already set in setupUI
        // Any additional constraints or modifications can be added here if needed
    }
    
    @objc private func deleteButtonTapped() {
        onConfirmDelete?()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped() {
        onCancel?()
        dismiss(animated: true, completion: nil)
    }
}
