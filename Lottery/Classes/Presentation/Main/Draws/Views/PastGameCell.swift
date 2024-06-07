//
//  PastGameCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/6/24.
//

import UIKit
import Kingfisher

class PastGameCell: UICollectionViewCell {
    
    private let logoImageView = UIImageView()
    private let dateLabel = UILabel()
    private let winningNumbersLabel = UILabel()
    private let winningNumbersStackView = UIStackView()
    private let luckyNumbersLabel = UILabel()
    private let luckyNumbersStackView = UIStackView()
    private let separatorLine = UIView()

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
extension PastGameCell {
    func configure(game: Game, lotteries: [Lottery]) {
        if let lottery = lotteries.first(where: { $0.id == game.lotteryId }) {
            // Use the URL directly from the Lottery struct
            logoImageView.kf.setImage(
                with: lottery.logoUrl,
                placeholder: UIImage(named: "placeholderImage"),
                options: [
                    .transition(.fade(0.25)),
                    .cacheOriginalImage
                ]
            )
        } else {
            // If no lottery matches, use a placeholder image
            logoImageView.image = UIImage(named: "placeholderImage")
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: game.date))
        
        // Configure winning numbers
        winningNumbersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let winningNumbers = game.winningNumbers?.first {
            for number in winningNumbers {
                let label = createNumberLabel(number: number)
                winningNumbersStackView.addArrangedSubview(label)
            }
        }
        
        // Configure lucky numbers if available
        luckyNumbersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let luckyNumbers = game.myLuckyNumbers?.first {
            separatorLine.isHidden = false
            luckyNumbersLabel.isHidden = false
            luckyNumbersStackView.isHidden = false
            for number in luckyNumbers {
                let label = createNumberLabel(number: number)
                luckyNumbersStackView.addArrangedSubview(label)
            }
        } else {
            separatorLine.isHidden = true
            luckyNumbersLabel.isHidden = true
            luckyNumbersStackView.isHidden = true
        }
    }
}

// MARK: - Setup Methods
private extension PastGameCell {
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textAlignment = .right
        dateLabel.textColor = Appearance.mono200
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        winningNumbersLabel.text = "WINNING NUMBERS"
        winningNumbersLabel.font = UIFont.systemFont(ofSize: 14)
        winningNumbersLabel.textColor = Appearance.mono200
        winningNumbersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        winningNumbersStackView.axis = .horizontal
        winningNumbersStackView.distribution = .fillEqually
        winningNumbersStackView.spacing = 5
        winningNumbersStackView.translatesAutoresizingMaskIntoConstraints = false
        
        luckyNumbersLabel.text = "MY LUCKY NUMBERS"
        luckyNumbersLabel.font = UIFont.systemFont(ofSize: 14)
        luckyNumbersLabel.textColor = Appearance.mono200
        luckyNumbersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        luckyNumbersStackView.axis = .horizontal
        luckyNumbersStackView.distribution = .fillEqually
        luckyNumbersStackView.spacing = 5
        luckyNumbersStackView.translatesAutoresizingMaskIntoConstraints = false
        
        separatorLine.backgroundColor = .lightGray
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(logoImageView)
        addSubview(dateLabel)
        addSubview(winningNumbersLabel)
        addSubview(winningNumbersStackView)
        addSubview(separatorLine)
        addSubview(luckyNumbersLabel)
        addSubview(luckyNumbersStackView)
    }
    
    func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            logoImageView.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -10),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            
            dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            winningNumbersLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            winningNumbersLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            winningNumbersStackView.topAnchor.constraint(equalTo: winningNumbersLabel.bottomAnchor, constant: 5),
            winningNumbersStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            winningNumbersStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            separatorLine.topAnchor.constraint(equalTo: winningNumbersStackView.bottomAnchor, constant: 20),
            separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            luckyNumbersLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 20),
            luckyNumbersLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            luckyNumbersStackView.topAnchor.constraint(equalTo: luckyNumbersLabel.bottomAnchor, constant: 5),
            luckyNumbersStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            luckyNumbersStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            luckyNumbersStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    func createNumberLabel(number: Int) -> UILabel {
        let label = UILabel()
        label.text = "\(number)"
        label.textAlignment = .center
        label.backgroundColor = number == 19 || number == 32 ? .systemRed : .systemBlue // Customize this condition as needed
        label.textColor = .white
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        label.widthAnchor.constraint(equalToConstant: 40).isActive = true
        label.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return label
    }
}
