//
//  ScanMenuViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/24/24.
//

import UIKit

final class ScanMenuViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // UIImageView for displaying an image
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Scan.ScanMenuViewController") // Replace with your image name
        return imageView
    }()
    
    // First UIButton
    private let scanTicketButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Scan Ticket", for: .normal)
        button.titleLabel?.font = Fonts.Inter.semiBold(size: 16.scale)
        button.backgroundColor = Appearance.main100
        button.tintColor = Appearance.mono100
        button.layer.cornerRadius = 21.scale
        button.addTarget(self, action: #selector(firstButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Second UIButton
    private let addTicketButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add ticket manually", for: .normal)
        button.titleLabel?.font = Fonts.Inter.semiBold(size: 16.scale)
        button.titleLabel?.textColor = .red//Appearance.mono200
        button.backgroundColor = Appearance.mono100
        button.tintColor = Appearance.mono200
        button.layer.cornerRadius = 21.scale
        button.addTarget(self, action: #selector(secondButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.mono200

        // Adding subviews
        view.addSubview(imageView)
        view.addSubview(scanTicketButton)
        view.addSubview(addTicketButton)

        // Applying constraints
        setupConstraints()
        
        setupNavigationBackButton()
    }
    
    func setupNavigationBackButton() {
        // Create a custom back button
        let backButton = UIButton(type: .custom)
        
        // Set the custom image for the button
        if let image = UIImage(named: "Scan.ScanTheTicket") {
            backButton.setImage(image, for: .normal)
        }
        
        // Set the frame or size of the button as needed
        backButton.frame = CGRect(x: 0, y: 0, width: 50.scale, height: 45.scale)
        backButton.imageView?.contentMode = .scaleAspectFit
        
        // Add a target to handle back navigation
        backButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Create a UIBarButtonItem with the custom button
        let backButtonItem = UIBarButtonItem(customView: backButton)
        
        // Replace the default back button with the custom button
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.hidesBackButton = true // Hide the default back button
    }
    @objc private func customBackButtonTapped() {
        // Perform back navigation
        navigationController?.popViewController(animated: true)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Constraints for imageView
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50.scale),
            imageView.widthAnchor.constraint(equalToConstant: 343.scale),
            imageView.heightAnchor.constraint(equalToConstant: 510.scale), // Adjust as needed for aspect ratio
            
            // Constraints for firstButton
            scanTicketButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanTicketButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20.scale),
            scanTicketButton.widthAnchor.constraint(equalToConstant: 343.scale),
            scanTicketButton.heightAnchor.constraint(equalToConstant: 44.scale),
            
            // Constraints for secondButton
            addTicketButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addTicketButton.topAnchor.constraint(equalTo: scanTicketButton.bottomAnchor, constant: 15.scale),
            addTicketButton.widthAnchor.constraint(equalToConstant: 343.scale),
            addTicketButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
    }
    
    // Actions for the buttons
    @objc private func firstButtonTapped() {
        print("First button tapped")
        // Add functionality for the first button
    }
    
    @objc private func secondButtonTapped() {
        print("Second button tapped")
        // Add functionality for the second button
    }
}
