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
    func configure(game: Game, lotteries: [Lottery]) {
//        if let lottery = lotteries.first(where: { $0.id == game.lotteryId }) {
//            // Use the URL directly from the Lottery struct
//            logoImageView.kf.setImage(
//                with: lottery.logoUrl,
//                placeholder: UIImage(named: "placeholderImage"),
//                options: [
//                    .transition(.fade(0.25)),
//                    .cacheOriginalImage
//                ]
//            )
//        } else {
            // If no lottery matches, use a placeholder image
            logoImageView.image = UIImage(named: "placeholderImage")
       // }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: game.date))
        
        // Directly use the non-optional strings and format them
        jackpotLabel.text = formatToMillions(game.jackpot)
        cashValueLabel.text = formatToMillions(game.cashValue ?? "$0 M.")
    }
    
    // Helper method to format large numbers
    private func formatToMillions(_ value: String) -> String {
        // Filter out non-numeric characters except the decimal point
        guard let number = Double(value.filter { "0123456789.".contains($0) }) else {
            return value // Return the original value if conversion fails
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
            // Position logoImageView in the top-left corner
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: -26),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -5),
            logoImageView.widthAnchor.constraint(equalToConstant: 188),
            logoImageView.heightAnchor.constraint(equalToConstant: 58),
            
            // Position dateLabel to the right of logoImageView
            dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: -20),
            dateLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Position jackpotLabel below logoImageView
            jackpotLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            jackpotLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -100),
            
            // Position cashValueLabel below logoImageView
            cashValueLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            cashValueLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 100),
            
            // Position jackpotTitleLabel below jackpotLabel
            jackpotTitleLabel.topAnchor.constraint(equalTo: jackpotLabel.bottomAnchor, constant: 5),
            jackpotTitleLabel.centerXAnchor.constraint(equalTo: jackpotLabel.centerXAnchor),
            
            // Position cashValueTitleLabel below cashValueLabel
            cashValueTitleLabel.topAnchor.constraint(equalTo: cashValueLabel.bottomAnchor, constant: 5),
            cashValueTitleLabel.centerXAnchor.constraint(equalTo: cashValueLabel.centerXAnchor),
            
            // Position cashValueTitleLabel's bottom to the bottom of the cell
            cashValueTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
}
