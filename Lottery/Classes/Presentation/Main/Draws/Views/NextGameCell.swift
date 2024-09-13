//
//  NextGameCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/6/24.
//


import UIKit
import Kingfisher

class NextGameCell: UICollectionViewCell {
    
    private var backgroundImageView = UIImageView()
    private let whiteBackgroundView = UIView()
    private let logoImageView = UIImageView()
    var winningNumbers: [[Int]] = []
    private let dateContainerImageView = UIImageView()
    private let dateMiniLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.Inter.medium(size: 16.scale) // Set custom font
        label.textColor = Appearance.main300 // Set custom color
        return label
    }()

    private let monthMiniLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.Inter.medium(size: 10.scale) // Set custom font
        label.textColor = Appearance.mono100 // Set custom color
        return label
    }()

    lazy var winningNumbersCollectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
       layout.scrollDirection = .vertical
       layout.minimumInteritemSpacing = 10.scale
       layout.minimumLineSpacing = 14.scale
       layout.itemSize = CGSize(width: 40.scale, height: 40.scale)
       
       let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
       collectionView.backgroundColor = .clear
       collectionView.translatesAutoresizingMaskIntoConstraints = false
       collectionView.dataSource = self
       collectionView.delegate = self
       collectionView.isUserInteractionEnabled = false
       collectionView.register(NumberCell.self, forCellWithReuseIdentifier: "NumberCell")
       return collectionView
   }()
    
    let latestWinningNumbersLabel: UILabel = {
        let label = UILabel()
        let textAttributes = TextAttributes()
            .font(Fonts.Inter.bold(size: 12.scale))
            .textColor(Appearance.mono100)
            .letterSpacing(2)
        label.attributedText = "latest winning numbers".uppercased().attributed(with: textAttributes)

        return label
    }()
    
    private let dateLabel = UILabel()
    private let jackpotLabel = UILabel()
    private let jackpotTitleLabel = UILabel()
    
    
    var logoImageLeadingConstraint: NSLayoutConstraint!
    var logoImageWidthConstraint: NSLayoutConstraint!
    var logoImageTopConstraint: NSLayoutConstraint!
    var jackpotTitleTopConstraint: NSLayoutConstraint!
    var whiteBcgHeightConstraint: NSLayoutConstraint!


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
        logoImageView.contentMode = .scaleAspectFit
      
        if self.frame.size.height == 232.scale {
            if let image = UIImage(named: "nextDrawDefBcg") {
                backgroundImageView.image = image
            }
        } else {
            if let image = UIImage(named: "nextDrawCashAndPowerBcg") {
                backgroundImageView.image = image
            }
        }
     
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy" // Custom format for "JUN 2, 2024"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent formatting
        
        var formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: game.date))
        dateLabel.text = formattedDate.uppercased() // Convert to uppercase
        
        dateFormatter.dateFormat = "d" // Custom format for "JUN 2, 2024"
        formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: game.date))
        dateMiniLabel.text = formattedDate.uppercased()
        
        dateFormatter.dateFormat = "MMM" // Custom format for "JUN 2, 2024"
        formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: game.date))
        monthMiniLabel.text = formattedDate.uppercased()
        
        print(dateMiniLabel.text, monthMiniLabel.text)

        jackpotLabel.text = game.jackpot != "" ? formatToMillions(game.jackpot) : "UNDETERMINED"
        
        
        if game.jackpot != "" {
            jackpotLabel.font = Fonts.Inter.bold(size: 24.scale)// Apply scale to font size
            jackpotLabel.textAlignment = .center
            jackpotLabel.textColor = Appearance.mono200
            jackpotLabel.translatesAutoresizingMaskIntoConstraints = false
     
            if let image = UIImage(named:"dateCalendarImage") {
                dateContainerImageView.contentMode = .scaleAspectFit
                dateContainerImageView.image = image
            }
            dateLabel.alpha = 0
            dateContainerImageView.alpha = 1

            
        } else {
            let jackpotTextAttributes = TextAttributes()
                .font(Fonts.Inter.medium(size: 14.scale))
                .textColor(Appearance.main300)
                .letterSpacing(1.5)
                .textAlignment(.center)

            let jackpotText = "UNDETERMINED".attributed(with: jackpotTextAttributes)
            jackpotLabel.attributedText = jackpotText
            jackpotLabel.translatesAutoresizingMaskIntoConstraints = false
            
            dateContainerImageView.alpha = 0
            dateLabel.alpha = 1
        }
        
        
        for lottery in lotteries {
            if lottery.id == game.lotteryId {

                logoImageView.kf.setImage(with: lottery.logoUrl)
                if doesURLContain(lottery.logoUrl.absoluteString, word: "mega") || doesURLContain(lottery.logoUrl.absoluteString, word: "2by2") {
                    logoImageLeadingConstraint.isActive = false
                    logoImageWidthConstraint.isActive = false
                    logoImageTopConstraint.isActive = false
                    jackpotTitleTopConstraint.isActive = false
                    whiteBcgHeightConstraint.isActive = false
                    
               
                    logoImageLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -25.scale)
                    logoImageWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 188.scale)
                    logoImageTopConstraint = logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10.scale)
                    jackpotTitleTopConstraint = jackpotTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor , constant: 13.scale)
                    whiteBcgHeightConstraint =             whiteBackgroundView.heightAnchor.constraint(equalToConstant: 144.scale)
                    
                    logoImageLeadingConstraint.isActive = true
                    logoImageWidthConstraint.isActive = true
                    logoImageTopConstraint.isActive = true
                    jackpotTitleTopConstraint.isActive = true
                    whiteBcgHeightConstraint.isActive = true
                    setNeedsLayout()
                    jackpotTitleLabel.alpha = 1
                    
                }
               if doesURLContain(lottery.logoUrl.absoluteString, word: "lotto") {
                    logoImageLeadingConstraint.isActive = false
                    logoImageWidthConstraint.isActive = false
                   logoImageTopConstraint.isActive = false
                   jackpotTitleTopConstraint.isActive = false
                   whiteBcgHeightConstraint.isActive = false
                 
                   logoImageLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -32.scale)
                    logoImageWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 188.scale)
                   jackpotTitleTopConstraint = jackpotTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor , constant: 13.scale)
                   whiteBcgHeightConstraint =             whiteBackgroundView.heightAnchor.constraint(equalToConstant: 144.scale)
                
                   logoImageLeadingConstraint.isActive = true
                   logoImageWidthConstraint.isActive = true
                   logoImageTopConstraint.isActive = true
                   jackpotTitleTopConstraint.isActive = true
                   whiteBcgHeightConstraint.isActive = true
                    setNeedsLayout()
                   jackpotTitleLabel.alpha = 1
                }
                if  doesURLContain(lottery.logoUrl.absoluteString, word: "power") {
                    logoImageLeadingConstraint.isActive = false
                    logoImageWidthConstraint.isActive = false
                    logoImageTopConstraint.isActive = false
                    jackpotTitleTopConstraint.isActive = false
                    whiteBcgHeightConstraint.isActive = false
                
                    logoImageLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale)
                    logoImageWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 155.scale)
                    logoImageTopConstraint = logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5.scale)
                    jackpotTitleTopConstraint = jackpotTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor , constant: 3.scale)
                    whiteBcgHeightConstraint =             whiteBackgroundView.heightAnchor.constraint(equalToConstant: 116.scale)
                    
                    logoImageLeadingConstraint.isActive = true
                    logoImageWidthConstraint.isActive = true
                    logoImageTopConstraint.isActive = true
                    jackpotTitleTopConstraint.isActive = true
                    whiteBcgHeightConstraint.isActive = true
                    setNeedsLayout()
                    jackpotTitleLabel.alpha = 1
                }
                
                if  doesURLContain(lottery.logoUrl.absoluteString, word: "cash4") {
                    logoImageLeadingConstraint.isActive = false
                    logoImageWidthConstraint.isActive = false
                    logoImageTopConstraint.isActive = false
                    jackpotTitleTopConstraint.isActive = false
                    whiteBcgHeightConstraint.isActive = false
                    
                    logoImageTopConstraint = logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8.scale)
                    logoImageLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale)
                    logoImageWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 80.scale)
                    
                    jackpotTitleTopConstraint = jackpotTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor , constant: -10.scale)
                    whiteBcgHeightConstraint =             whiteBackgroundView.heightAnchor.constraint(equalToConstant: 116.scale)
                    
                    logoImageLeadingConstraint.isActive = true
                    logoImageWidthConstraint.isActive = true
                    logoImageTopConstraint.isActive = true
                    jackpotTitleTopConstraint.isActive = true
                    whiteBcgHeightConstraint.isActive = true
                    
                    setNeedsLayout()
                    
                    jackpotLabel.text = game.jackpot != "" ? "\(game.jackpot) per day" : "UNDETERMINED"
                    dateContainerImageView.alpha = 0
                    dateLabel.alpha = 1
                    jackpotTitleLabel.alpha = 0
                }
                
            }
        }
        
        
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
        backgroundColor = Appearance.mono100
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFit
        
        // Configure whiteBackgroundView
        whiteBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        whiteBackgroundView.backgroundColor = Appearance.mono100
        whiteBackgroundView.layer.cornerRadius = 16.3.scale
        whiteBackgroundView.layer.borderWidth = 2.scale
        whiteBackgroundView.layer.borderColor = Appearance.witeBcgBorderColor.cgColor
        
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        dateContainerImageView.translatesAutoresizingMaskIntoConstraints = false
        dateMiniLabel.translatesAutoresizingMaskIntoConstraints = false
        monthMiniLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = Fonts.Inter.medium(size: 12.5.scale) // Apply scale to font size
        dateLabel.textAlignment = .center
        dateLabel.textColor = Appearance.main300
        dateLabel.backgroundColor = Appearance.mono100
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
     
        
        let jackpotTitleTextAttributes = TextAttributes()
            .font(Fonts.Inter.medium(size: 12.scale))
            .textColor(Appearance.mono200)
            .letterSpacing(1.5) // Adjust the kerning value as needed
            .textAlignment(.left)

        // Apply the attributed string to the label
        jackpotTitleLabel.attributedText = "JACKPOT".attributed(with: jackpotTitleTextAttributes)
        jackpotTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        // Add backgroundImageView as the first subview
        addSubview(backgroundImageView)
        // Add whiteBackgroundView above backgroundImageView
        addSubview(whiteBackgroundView)
        addSubview(logoImageView)
        whiteBackgroundView.addSubview(dateContainerImageView)
        dateContainerImageView.addSubview(dateMiniLabel)
        dateContainerImageView.addSubview(monthMiniLabel)
   
        
        whiteBackgroundView.addSubview(dateLabel)
       
        addSubview(jackpotTitleLabel)
        addSubview(jackpotLabel)
        
        winningNumbersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(winningNumbersCollectionView)
        
        latestWinningNumbersLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(latestWinningNumbersLabel)
   
    }
    
    func setupLayoutConstraints() {
        logoImageLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10.scale)
        logoImageWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 188.scale)
        logoImageTopConstraint = logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10.scale)
        jackpotTitleTopConstraint = jackpotTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor , constant: 10.scale)
        
        whiteBcgHeightConstraint =             whiteBackgroundView.heightAnchor.constraint(equalToConstant: self.frame.size.height == 232.scale ? 144.scale : 116.scale)
        
        NSLayoutConstraint.activate([
            // Set backgroundImageView constraints to cover the entire cell
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Set whiteBackgroundView constraints to cover the entire cell
            whiteBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            whiteBackgroundView.widthAnchor.constraint(equalToConstant: 343.scale),
            whiteBcgHeightConstraint,
            
            logoImageTopConstraint,
            logoImageLeadingConstraint,
            logoImageWidthConstraint,
            logoImageView.heightAnchor.constraint(equalToConstant: 48.scale),
        
          
          
            jackpotTitleTopConstraint,
            jackpotTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22.scale),
            jackpotTitleLabel.heightAnchor.constraint(equalToConstant: 15.scale),
          
            jackpotLabel.topAnchor.constraint(equalTo: jackpotTitleLabel.bottomAnchor, constant: 5.scale),
            jackpotLabel.leadingAnchor.constraint(equalTo: jackpotTitleLabel.leadingAnchor, constant: 0.scale),
            jackpotLabel.heightAnchor.constraint(equalToConstant: 30.scale),
            
          
            dateLabel.centerYAnchor.constraint(equalTo: jackpotLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22.scale),
            dateLabel.heightAnchor.constraint(equalToConstant: 13.scale),
            
            dateContainerImageView.bottomAnchor.constraint(equalTo: whiteBackgroundView.bottomAnchor, constant: -22.scale),
            dateContainerImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22.scale),
            dateContainerImageView.widthAnchor.constraint(equalToConstant: 48.scale),
            dateContainerImageView.heightAnchor.constraint(equalToConstant: 45.scale),
            
         
            monthMiniLabel.centerXAnchor.constraint(equalTo: dateContainerImageView.centerXAnchor),
            monthMiniLabel.topAnchor.constraint(equalTo: dateContainerImageView.topAnchor, constant: 2.scale),
            
            dateMiniLabel.centerXAnchor.constraint(equalTo: dateContainerImageView.centerXAnchor),
            dateMiniLabel.topAnchor.constraint(equalTo: dateContainerImageView.topAnchor, constant: 22.scale),
            dateMiniLabel.heightAnchor.constraint(equalToConstant: 16.scale),
            
            
            
            winningNumbersCollectionView.bottomAnchor.constraint(equalTo: latestWinningNumbersLabel.topAnchor, constant: -10.scale),
            winningNumbersCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            winningNumbersCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            winningNumbersCollectionView.heightAnchor.constraint(equalToConstant: 40.scale),
            
            latestWinningNumbersLabel.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -13.scale),
            latestWinningNumbersLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            latestWinningNumbersLabel.heightAnchor.constraint(equalToConstant: 14.scale)
           
        ])
    }
    
    func doesURLContain(_ urlString: String, word: String) -> Bool {
        return urlString.lowercased().contains(word)
    }
}

extension NextGameCell:  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
            return UIEdgeInsets(top: 0.scale,
                                left: winningNumbers.first?.count == 6 ? 10.scale : 58.scale,
                                bottom: 10.scale,
                                right:  winningNumbers.first?.count == 6 ? 10.scale : -58.scale)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return winningNumbers.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == winningNumbersCollectionView {
            return winningNumbers.first?.count ?? 0
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberCell", for: indexPath) as? NumberCell else {
            fatalError("Could not dequeue cell with identifier: NumberCell")
        }
        
        if collectionView == winningNumbersCollectionView {
            configureCellForWinningNumbers(cell, at: indexPath)
        }
        return cell
    }
    private func configureCellForWinningNumbers(_ cell: NumberCell, at indexPath: IndexPath) {
        let number = winningNumbers[indexPath.section][indexPath.item]
       
        var lastIndex = winningNumbers[0].count - 1
        
        if indexPath.item == lastIndex {
            cell.numberLabel.text = String(number)
            cell.backgroundViewContainer.backgroundColor = Appearance.main100
            cell.backgroundViewContainer.alpha = 1
            
        } else {
            cell.numberLabel.text = String(number)
            cell.backgroundViewContainer.backgroundColor = Appearance.mono100
            cell.backgroundViewContainer.alpha = 0.5
        }
    }
    private func configureCell(_ cell: NumberCell, withNumber number: Int, comparisonArray: [[Int]], indexPath: IndexPath) {
        if comparisonArray.count == 0 {
            return

        }
        var lastIndex = comparisonArray[0].count - 1
        if indexPath.item == lastIndex {
         
        } else {
            cell.numberLabel.textColor = Appearance.mono200
        }
        
        
        let allNumbers = Set(comparisonArray.flatMap({ $0 }))
        let isHighlight = allNumbers.contains(number)
        cell.configure(with: String(number))
        cell.backgroundColor = isHighlight ? Appearance.main600 : Appearance.mono100
        cell.layer.borderColor = isHighlight ? UIColor.clear.cgColor : Appearance.main500.cgColor
      
        if indexPath.item == lastIndex {
            cell.backgroundColor = Appearance.main100
            cell.numberLabel.textColor = Appearance.mono100
            cell.layer.borderColor = UIColor.clear.cgColor
        } else {
            
        }
        
      
    }
    
}
