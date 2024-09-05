//
//  ChooseScanOptionView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 9/5/24.
//

import UIKit

class ChooseScanOptionView: UIView {

    // Declare buttons outside of setupView()
    let scanDrawButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan Draw", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let scanScratchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan Scratch", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        if let closeImage = UIImage(named: "EditTickets.Close") {
            button.setImage(closeImage, for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // Set background color of the main view
        self.backgroundColor = .lightGray
        
        // Add buttons to the view
        addSubview(scanDrawButton)
        addSubview(scanScratchButton)
        addSubview(dismissButton)

        // Set up layout constraints for scanDrawButton
        NSLayoutConstraint.activate([
            scanDrawButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 30.scale),
            scanDrawButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            scanDrawButton.widthAnchor.constraint(equalToConstant: 311.scale),
            scanDrawButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])

        // Set up layout constraints for scanScratchButton
        NSLayoutConstraint.activate([
            scanScratchButton.topAnchor.constraint(equalTo: scanDrawButton.bottomAnchor, constant: 20.scale),
            scanScratchButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            scanScratchButton.widthAnchor.constraint(equalToConstant: 311.scale),
            scanScratchButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])

        // Set up layout constraints for dismissButton
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.scale),
            dismissButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.scale),
            dismissButton.widthAnchor.constraint(equalToConstant: 12.scale),
            dismissButton.heightAnchor.constraint(equalToConstant: 12.scale)
        ])
    }
}

// Helper extension to simulate .scale for size scaling
extension CGFloat {
    static var scale: CGFloat {
        return UIScreen.main.bounds.width / 375.0 // Example scaling based on iPhone 8 width
    }
}

