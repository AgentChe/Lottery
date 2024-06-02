//
//  WelcomeVIew.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//


import UIKit

final class WelcomeView: UIView {
    let startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 255/255, green: 0, blue: 0, alpha: 1)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "WELCOME TO LOTTERY SCANNER!"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = UIColor(red: 0, green: 0, blue: 139/255, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bulletPoints: [(text: String, bulletColor: UIColor)] = [
        ("Monitor the main national lottery games", UIColor.red),
        ("Scan and save your tickets", UIColor.red),
        ("Get notified when drawings come out", UIColor.red)
    ]
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "lottery_logos")) // Make sure to add the image to your assets
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .white
        
        addSubview(welcomeLabel)
        addSubview(logoImageView)
        addSubview(startButton)
        
        setupConstraints()
        setupBulletPoints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            welcomeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 300),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            startButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupBulletPoints() {
        var previousLabel: UILabel?
        
        for bulletPoint in bulletPoints {
            let bulletLabel = UILabel()
            bulletLabel.text = bulletPoint.text
            bulletLabel.font = UIFont.systemFont(ofSize: 18)
            bulletLabel.textColor = UIColor(red: 0, green: 0, blue: 139/255, alpha: 1)
            bulletLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let bulletView = UIView()
            bulletView.backgroundColor = bulletPoint.bulletColor
            bulletView.layer.cornerRadius = 3
            bulletView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(bulletLabel)
            addSubview(bulletView)
            
            NSLayoutConstraint.activate([
                bulletView.widthAnchor.constraint(equalToConstant: 6),
                bulletView.heightAnchor.constraint(equalToConstant: 6),
                bulletView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                
                bulletLabel.leadingAnchor.constraint(equalTo: bulletView.trailingAnchor, constant: 10),
                bulletLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                bulletLabel.topAnchor.constraint(equalTo: previousLabel?.bottomAnchor ?? welcomeLabel.bottomAnchor, constant: 20),
                bulletView.centerYAnchor.constraint(equalTo: bulletLabel.centerYAnchor)
            ])
            
            previousLabel = bulletLabel
        }
    }
}
