//
//  NextGameCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/6/24.
//


import UIKit

class NextGameCell: UICollectionViewCell {
    
    private let logoImageView = UIImageView()
    private let dateLabelContainer = UIView()
    private let dateLabel = UILabel()
    private let jackpotLabel = UILabel()
    private let cashValueLabel = UILabel()
    private let jackpotTitleLabel = UILabel()
    private let cashValueTitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods
extension NextGameCell {
    func configure(game: Game, lotteries: [Lottery]) {
        logoImageView.image = UIImage(named: "placeholderImage")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy" // Custom format for "JUN 2, 2024"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent formatting
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set timezone if needed
        let formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: game.date))
        dateLabel.text = formattedDate.uppercased() // Convert to uppercase

        jackpotLabel.text = formatToMillions(game.jackpot)
        cashValueLabel.text = formatToMillions(game.cashValue ?? "$0 M.")
    }
    
    private func formatToMillions(_ value: String) -> String {
        guard let number = Double(value.filter { "0123456789.".contains($0) }) else {
            return value
        }
        
        let million = number / 1_000_000
        return String(format: "$%.0f M.", million)
    }
}

// MARK: - Setup Methods
private extension NextGameCell {
    func setupUI() {
        backgroundColor = .white
        
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        dateLabelContainer.layer.shadowColor = Appearance.dropShadowColor?.cgColor
        dateLabelContainer.layer.shadowOpacity = 0.5
        dateLabelContainer.layer.shadowRadius = 3.scale // Apply scale to shadow radius
        dateLabelContainer.layer.shadowOffset = CGSize(width: 0, height: 2.scale) // Apply scale to shadow offset
        
        dateLabel.font = Fonts.Inter.medium(size: 12.scale) // Apply scale to font size
        dateLabel.textAlignment = .center
        dateLabel.textColor = Appearance.main300
        dateLabel.backgroundColor = Appearance.mono100
        dateLabel.layer.cornerRadius = 14.scale // Apply scale to corner radius
        dateLabel.layer.masksToBounds = true
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        jackpotLabel.font = UIFont.boldSystemFont(ofSize: 28.scale) // Apply scale to font size
        jackpotLabel.textAlignment = .center
        jackpotLabel.textColor = Appearance.mono200
        jackpotLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cashValueLabel.font = UIFont.boldSystemFont(ofSize: 28.scale) // Apply scale to font size
        cashValueLabel.textAlignment = .center
        cashValueLabel.textColor = Appearance.mono200
        cashValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        jackpotTitleLabel.text = "JACKPOT"
        jackpotTitleLabel.font = UIFont.systemFont(ofSize: 14.scale) // Apply scale to font size
        jackpotTitleLabel.textAlignment = .center
        jackpotTitleLabel.textColor = Appearance.mono200
        jackpotTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cashValueTitleLabel.text = "CASH VALUE"
        cashValueTitleLabel.font = UIFont.systemFont(ofSize: 14.scale) // Apply scale to font size
        cashValueTitleLabel.textAlignment = .center
        cashValueTitleLabel.textColor = Appearance.mono200
        cashValueTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(logoImageView)
        addSubview(dateLabelContainer)
        dateLabelContainer.addSubview(dateLabel)
        addSubview(jackpotLabel)
        addSubview(cashValueLabel)
        addSubview(jackpotTitleLabel)
        addSubview(cashValueTitleLabel)
    }
    
    func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: -27.scale),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -5.scale), // Apply scale to leading constraint
            logoImageView.widthAnchor.constraint(equalToConstant: 188.scale), // Apply scale to width
            logoImageView.heightAnchor.constraint(equalToConstant: 58.scale), // Apply scale to height
            
            dateLabelContainer.topAnchor.constraint(equalTo: topAnchor, constant: -14.scale), // Apply scale to top constraint
            dateLabelContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30.scale), // Apply scale to trailing constraint
            dateLabelContainer.widthAnchor.constraint(equalToConstant: 102.scale), // Apply scale to width
            dateLabelContainer.heightAnchor.constraint(equalToConstant: 28.scale), // Apply scale to height
            
            dateLabel.centerXAnchor.constraint(equalTo: dateLabelContainer.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: dateLabelContainer.centerYAnchor),
            dateLabel.widthAnchor.constraint(equalTo: dateLabelContainer.widthAnchor),
            dateLabel.heightAnchor.constraint(equalTo: dateLabelContainer.heightAnchor),
            
            jackpotLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20.scale), // Apply scale to top constraint
            jackpotLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -100.scale), // Apply scale to centerX constraint
            
            cashValueLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20.scale), // Apply scale to top constraint
            cashValueLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 100.scale), // Apply scale to centerX constraint
            
            jackpotTitleLabel.topAnchor.constraint(equalTo: jackpotLabel.bottomAnchor, constant: 5.scale), // Apply scale to top constraint
            jackpotTitleLabel.centerXAnchor.constraint(equalTo: jackpotLabel.centerXAnchor),
            
            cashValueTitleLabel.topAnchor.constraint(equalTo: cashValueLabel.bottomAnchor, constant: 5.scale), // Apply scale to top constraint
            cashValueTitleLabel.centerXAnchor.constraint(equalTo: cashValueLabel.centerXAnchor),
            
            cashValueTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20.scale) // Apply scale to bottom constraint
        ])
    }
}
