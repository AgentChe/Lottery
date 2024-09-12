//
//  ScanScratchView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 9/3/24.
//

import UIKit

final class ScanScratchView: UIView {
    
    // MARK: - UI Components
    
    let startButton: UIButton = {
        let button = UIButton()
        let attrs = TextAttributes()
            .textColor(.white)
            .font(Fonts.Inter.medium(size: 17.scale))
        let attributedTitle = "Continue".localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.bold(size: 19.scale))
            .lineHeight(22.8.scale)
            .textAlignment(.left)
        
        label.attributedText = NSAttributedString(string: "SCAN YOUR SCRATCH-OFF TICKETS", attributes: attrs.dictionary)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descFeatureLabel: UILabel = {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.medium(size: 16.scale))
            .lineHeight(30.scale)
            .textAlignment(.left)
        let label = UILabel()
        label.attributedText = "Easily check the result by scanning your scratch-off tickets. Just scratch the ticket and align it within the frame".localized.attributed(with: attrs)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ScanScratchImage"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods

private extension ScanScratchView {
    func setupView() {
        backgroundColor = Appearance.main400
        
        addSubview(welcomeLabel)
        addSubview(descFeatureLabel)
        addSubview(logoImageView)
        addSubview(startButton)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 84.scale : 50.scale),
            welcomeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            welcomeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            
            descFeatureLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            descFeatureLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            descFeatureLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 27.scale),
            
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: ScreenSize.isIphoneXFamily ? -40.scale : -40.scale),
            logoImageView.widthAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 343.scale : 343.scale*0.86),
            logoImageView.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 343.scale : 343.scale*0.86),
            
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ?  -50.scale : -20.scale),
            startButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 343.scale),
            startButton.heightAnchor.constraint(equalToConstant: 44.scale),
        ])
    }
}
