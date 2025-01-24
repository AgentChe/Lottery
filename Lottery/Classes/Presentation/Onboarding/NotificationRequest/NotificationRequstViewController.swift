//
//  NotificationRequestViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 10/15/24.
//

import UIKit

class NotificationRequestViewController: UIViewController {
    
    private let allowButton: UIButton = {
        let button = UIButton()
        
        let attrs = TextAttributes()
            .textColor(.white)
            .font(Fonts.Inter.bold(size: 14.scale))
        
        let attributedTitle = "Allow Notifications".localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 20.scale
        button.addTarget(self, action: #selector(allowButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let denyButton: UIButton = {
        let button = UIButton()
        
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.bold(size: 14.scale))
        
        let attributedTitle = "Maybe later".localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.backgroundColor = Appearance.mono100
        button.layer.cornerRadius = 20.scale
        button.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        button.layer.borderWidth = 1.scale
        button.layer.cornerRadius = 20.scale
        button.addTarget(self, action: #selector(denyButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "SuggestNewGame.Close"), for: .normal)
        button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "NotificationRequestViewController.allowHeaderLabel".localized
        label.font = Fonts.Inter.bold(size: 16.scale)
        label.textColor = Appearance.mono200
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        let attrs = TextAttributes()
            .textColor(.white)
            .font(Fonts.Inter.medium(size: 14.scale))
            .lineHeight(21.scale)
        
        label.attributedText = "NotificationRequestViewController.allowDescritionLabel".localized.attributed(with: attrs)
        label.font = Fonts.Inter.regular(size: 14.scale)
        label.textColor = Appearance.main300
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notificationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "NotificationsRequest.image")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 1.0
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Appearance.main400
        setupLayout()
    }
    
    private func setupLayout() {
        allowButton.translatesAutoresizingMaskIntoConstraints = false
        denyButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(headerLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(notificationImageView)
        view.addSubview(allowButton)
        view.addSubview(denyButton)
        view.addSubview(dismissButton)
        
        NSLayoutConstraint.activate([
            // Dismiss Button Constraints
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.scale),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            dismissButton.widthAnchor.constraint(equalToConstant: 24.scale),
            dismissButton.heightAnchor.constraint(equalToConstant: 24.scale),
            
            // Header Label Constraints
            headerLabel.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 60.scale),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Description Label Constraints
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10.scale),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20.scale),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20.scale),
            
            // Notification Image Constraints
            notificationImageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20.scale),
            notificationImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notificationImageView.widthAnchor.constraint(equalToConstant: 327.scale),
            notificationImageView.heightAnchor.constraint(equalToConstant: 93.scale),
            
            // Allow Button Constraints
            allowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            allowButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            allowButton.heightAnchor.constraint(equalToConstant: 44.scale),
            allowButton.bottomAnchor.constraint(equalTo: denyButton.topAnchor, constant: -10.scale),
            
            // Deny Button Constraints
            denyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            denyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            denyButton.heightAnchor.constraint(equalToConstant: 44.scale),
            denyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.scale)
        ])
    }
    
    @objc private func allowButtonTapped() {
        // Request notification authorization when the allow button is tapped
        PushNotificationsManager.shared.requestAuthorization() { bool in
            if let onboardingViewController = self.presentingViewController as? OnboardingViewController {
                self.dismiss(animated: true) {
                    onboardingViewController.completeOnboarding()
                }
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc private func denyButtonTapped() {
        let sheetVC = SheetViewController()
        
        if let sheet = sheetVC.sheetPresentationController {
            sheet.detents = [.medium()] // You can choose from .small(), .medium(), or .large()
            sheet.prefersGrabberVisible = false // Show the grabber handle at the top of the sheet
            sheet.preferredCornerRadius = 20 // Optional: Customize the corner radius of the sheet
        }
        
        present(sheetVC, animated: true)
    }
    
    @objc private func dismissButtonTapped() {
        // Handle dismiss action
        if let onboardingViewController = self.presentingViewController as? OnboardingViewController {
            dismiss(animated: true) {
                onboardingViewController.completeOnboarding()
            }
        }
    }
}
