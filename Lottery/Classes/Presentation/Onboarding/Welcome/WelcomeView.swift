//
//  WelcomeView.swift
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
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "WELCOME TO LOTTERY SCANNER!"
        label.font = Fonts.Inter.bold(size: 19.scale)
        label.textColor = Appearance.mono200
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bulletPoint1Label: UILabel = {
        let label = UILabel()
        label.text = "Monitor the main national lottery games"
        label.font = Fonts.Inter.medium(size: 16.scale)
        label.textColor = Appearance.mono200
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bulletPoint1View: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bulletPoint2Label: UILabel = {
        let label = UILabel()
        label.text = "Scan and save your tickets"
        label.font = Fonts.Inter.medium(size: 16.scale)
        label.textColor = Appearance.mono200
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bulletPoint2View: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bulletPoint3Label: UILabel = {
        let label = UILabel()
        label.text = "Get notified when drawings come out"
        label.font = Fonts.Inter.medium(size: 16.scale)
        label.textColor = Appearance.mono200
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bulletPoint3View: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Welcome.Games"))
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
        backgroundColor = Appearance.main400
        
        addSubview(welcomeLabel)
        addSubview(bulletPoint1View)
        addSubview(bulletPoint1Label)
        addSubview(bulletPoint2View)
        addSubview(bulletPoint2Label)
        addSubview(bulletPoint3View)
        addSubview(bulletPoint3Label)
        addSubview(logoImageView)
        addSubview(startButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 84.scale),
            welcomeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            welcomeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            
            bulletPoint1View.widthAnchor.constraint(equalToConstant: 6.scale),
            bulletPoint1View.heightAnchor.constraint(equalToConstant: 6.scale),
            bulletPoint1View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            bulletPoint1View.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 36.scale),
            
            bulletPoint1Label.leadingAnchor.constraint(equalTo: bulletPoint1View.trailingAnchor, constant: 10.scale),
            bulletPoint1Label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            bulletPoint1Label.centerYAnchor.constraint(equalTo: bulletPoint1View.centerYAnchor),
            
            bulletPoint2View.widthAnchor.constraint(equalToConstant: 6.scale),
            bulletPoint2View.heightAnchor.constraint(equalToConstant: 6.scale),
            bulletPoint2View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            bulletPoint2View.topAnchor.constraint(equalTo: bulletPoint1Label.bottomAnchor, constant: 32.scale),
            
            bulletPoint2Label.leadingAnchor.constraint(equalTo: bulletPoint2View.trailingAnchor, constant: 10.scale),
            bulletPoint2Label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            bulletPoint2Label.centerYAnchor.constraint(equalTo: bulletPoint2View.centerYAnchor),
            
            bulletPoint3View.widthAnchor.constraint(equalToConstant: 6.scale),
            bulletPoint3View.heightAnchor.constraint(equalToConstant: 6.scale),
            bulletPoint3View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            bulletPoint3View.topAnchor.constraint(equalTo: bulletPoint2Label.bottomAnchor, constant: 32.scale),
            
            bulletPoint3Label.leadingAnchor.constraint(equalTo: bulletPoint3View.trailingAnchor, constant: 10.scale),
            bulletPoint3Label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            bulletPoint3Label.centerYAnchor.constraint(equalTo: bulletPoint3View.centerYAnchor),
            
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -40.scale),
            logoImageView.widthAnchor.constraint(equalToConstant: 343.scale),
            logoImageView.heightAnchor.constraint(equalToConstant: 356.scale),
            
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50.scale),
            startButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 343.scale),
            startButton.heightAnchor.constraint(equalToConstant: 44.scale),
        ])
    }
}
