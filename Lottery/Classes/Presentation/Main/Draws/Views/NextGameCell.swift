//
//  NextGameCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/6/24.
//

//
//  NextGameCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/6/24.
//

import UIKit

class NextGameCell: UICollectionViewCell {
    
    private let logoImageView = UIImageView()
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
//MARK: - Public Methods
extension NextGameCell {
    func configure(game: Game) {
        // Assuming the logo is provided based on the lotteryId
        logoImageView.image = UIImage(named: "lottery_logo_\(game.lotteryId)") // Replace with actual image name logic
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: game.date))
        jackpotLabel.text = game.jackpot
        cashValueLabel.text = game.cashValue
    }
}
// MARK: - Setup Methods
private extension NextGameCell {
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
        
        jackpotLabel.font = UIFont.boldSystemFont(ofSize: 28)
        jackpotLabel.textAlignment = .center
        jackpotLabel.textColor = Appearance.mono200
        jackpotLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cashValueLabel.font = UIFont.boldSystemFont(ofSize: 28)
        cashValueLabel.textAlignment = .center
        cashValueLabel.textColor = Appearance.mono200
        cashValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        jackpotTitleLabel.text = "JACKPOT"
        jackpotTitleLabel.font = UIFont.systemFont(ofSize: 14)
        jackpotTitleLabel.textAlignment = .center
        jackpotTitleLabel.textColor = Appearance.mono200
        jackpotTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cashValueTitleLabel.text = "CASH VALUE"
        cashValueTitleLabel.font = UIFont.systemFont(ofSize: 14)
        cashValueTitleLabel.textAlignment = .center
        cashValueTitleLabel.textColor = Appearance.mono200
        cashValueTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(logoImageView)
        addSubview(dateLabel)
        addSubview(jackpotLabel)
        addSubview(cashValueLabel)
        addSubview(jackpotTitleLabel)
        addSubview(cashValueTitleLabel)
    }
    
    func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            logoImageView.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -10),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            
            dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            jackpotLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            jackpotLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            cashValueLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            cashValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            jackpotTitleLabel.topAnchor.constraint(equalTo: jackpotLabel.bottomAnchor, constant: 5),
            jackpotTitleLabel.centerXAnchor.constraint(equalTo: jackpotLabel.centerXAnchor),
            
            cashValueTitleLabel.topAnchor.constraint(equalTo: cashValueLabel.bottomAnchor, constant: 5),
            cashValueTitleLabel.centerXAnchor.constraint(equalTo: cashValueLabel.centerXAnchor),
            
            cashValueTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
 
}
