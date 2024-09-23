//
//  PastGameCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/6/24.
//

import UIKit
import Kingfisher

class PastGameCell: UICollectionViewCell {
    private var backgroundImageView = UIImageView()
    private let whiteBackgroundView = UIView()
    var whiteBackgroundTopConstraint: NSLayoutConstraint!
    var whiteBackgroundHeightConstraint: NSLayoutConstraint!
    
    
    private let logoImageView = UIImageView()
    private let dateLabelContainer = UIView()
    private let dateLabel = UILabel()
    private let jackpotLabel = UILabel()
    private let jackpotTitleLabel = UILabel()
    
    var logoImageLeadingConstraint: NSLayoutConstraint!
    var logoImageWidthConstraint: NSLayoutConstraint!
    var logoImageTopConstraint: NSLayoutConstraint!
    var jackpotTitleTopConstraint: NSLayoutConstraint!
    
    private let winningNumbersTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "PastGameCell.WinningNumbers".localized
        label.font = Fonts.Inter.bold(size: 12.scale)
        label.textAlignment = .left
        label.textColor = Appearance.mono100
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        let attributedText = NSMutableAttributedString(string: "PastGameCell.WinningNumbers".localized)
        attributedText.addAttribute(.kern, value: 1.5, range: NSRange(location: 0, length: attributedText.length))
        
        label.attributedText = attributedText
        return label
    }()
    var myLuckyNumbersCollectionViewHeightConstraint: NSLayoutConstraint!
    var winningNumbersCollectionViewHeightConstraint: NSLayoutConstraint!
     let myLuckyNumbersTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "PastGameCell.MyLuckyNumbers".localized
        label.font = Fonts.Inter.bold(size: 12.scale)
        label.textAlignment = .left
        label.textColor = Appearance.mono100
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let attributedText = NSMutableAttributedString(string: "PastGameCell.MyLuckyNumbers".localized)
        attributedText.addAttribute(.kern, value: 1.5, range: NSRange(location: 0, length: attributedText.length))
        label.attributedText = attributedText
        
        return label
    }()
    
     let dashedLineImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PastDraws.DashedLine")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
     lazy var winningNumbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
         layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8.scale
        layout.minimumLineSpacing = 8.scale
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
         collectionView.backgroundColor = .clear//.red
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
         
         collectionView.isUserInteractionEnabled = true
         collectionView.showsVerticalScrollIndicator = false
         collectionView.showsHorizontalScrollIndicator = false
         collectionView.layer.masksToBounds = false

         collectionView.register(NumberCell.self, forCellWithReuseIdentifier: "NumberCell")
         
        return collectionView
    }()
    
     lazy var myLuckyNumbersCollectionView: NoVerticalScrollCollectionView = {
        let layout = UICollectionViewFlowLayout()
         layout.scrollDirection = .vertical
         layout.minimumInteritemSpacing = 8.scale
         layout.minimumLineSpacing = 8.scale
        let collectionView = NoVerticalScrollCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
         
         collectionView.isUserInteractionEnabled = true
         collectionView.showsVerticalScrollIndicator = false
         collectionView.showsHorizontalScrollIndicator = false
         collectionView.layer.masksToBounds = false
         collectionView.register(LuckyNumbersRowCollecitonViewCell.self, forCellWithReuseIdentifier: LuckyNumbersRowCollecitonViewCell.reuseIdentifier)
       
         collectionView.layer.masksToBounds = false
        return collectionView
    }()
    
    // Arrays to hold the nested numbers
    private var winningNumbers: [[Int]] = []
    private var myLuckyNumbers: [[Int]] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
        setupLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.kf.cancelDownloadTask()
    }
}

// MARK: - Public Methods
extension PastGameCell {
    func configure(game: Game, lotteries: [Lottery]) {
        logoImageView.image = UIImage(named: "placeholderImage")
        logoImageView.contentMode = .scaleAspectFit
        myLuckyNumbers = game.myLuckyNumbers ?? []
        winningNumbers = game.winningNumbers ?? []
        
        
        if let image = UIImage(named:  myLuckyNumbers != [] ? "pastDrawDefBcg" : "pastDrawNoLuckyNumbers") {
            backgroundImageView.image = image
            if myLuckyNumbers.count > 5 {
                if let image = UIImage(named: "OnboardingBackground") {
                    backgroundImageView.image = image
                }
            }
        }
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: game.date))
        dateLabel.text = formattedDate.uppercased()
        
        jackpotLabel.text = game.jackpot != "" ? formatToMillions(game.jackpot) : "UNDETERMINED"
        
        
        if game.jackpot != "" {
            jackpotLabel.font = Fonts.Inter.bold(size: 24.scale)// Apply scale to font size
            jackpotLabel.textAlignment = .center
            jackpotLabel.textColor = Appearance.mono200
            jackpotLabel.translatesAutoresizingMaskIntoConstraints = false
        } else {
            let jackpotTextAttributes = TextAttributes()
                .font(Fonts.Inter.medium(size: 14.scale))
                .textColor(Appearance.main300)
                .letterSpacing(1.5)
                .textAlignment(.center)

            let jackpotText = "UNDETERMINED".attributed(with: jackpotTextAttributes)
            jackpotLabel.attributedText = jackpotText
            jackpotLabel.translatesAutoresizingMaskIntoConstraints = false
        }
        whiteBackgroundHeightConstraint.isActive = false
        whiteBackgroundHeightConstraint =  whiteBackgroundView.heightAnchor.constraint(equalToConstant: ( game.lotteryId == 1 || game.lotteryId == 4) ? 116.scale : 144.scale)
        whiteBackgroundHeightConstraint.isActive = true
        setNeedsLayout()
        
        for lottery in lotteries {
            if lottery.id == game.lotteryId {
                
                logoImageView.kf.setImage(with: lottery.logoUrl)
                if doesURLContain(lottery.logoUrl.absoluteString, word: "mega") || doesURLContain(lottery.logoUrl.absoluteString, word: "2by2") {
//                    logoImageLeadingConstraint.isActive = false
//                    logoImageWidthConstraint.isActive = false
//                    logoImageTopConstraint.isActive = false
                    jackpotTitleTopConstraint.isActive = false
//                    whiteBackgroundHeightConstraint.isActive = false
//                   
//                    
//                    logoImageLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -25.scale)
//                    logoImageWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 188.scale)
//                    logoImageTopConstraint = logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10.scale)
                    jackpotTitleTopConstraint = jackpotTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor , constant: 13.scale)
//                    whiteBackgroundHeightConstraint = whiteBackgroundView.heightAnchor.constraint(equalToConstant: 144.scale)
//                
//                    
//                    logoImageLeadingConstraint.isActive = true
//                    logoImageWidthConstraint.isActive = true
//                    logoImageTopConstraint.isActive = true
                   jackpotTitleTopConstraint.isActive = true
//                    whiteBackgroundHeightConstraint.isActive = true
//                    setNeedsLayout()
                    jackpotTitleLabel.alpha = 1
                }
                if  doesURLContain(lottery.logoUrl.absoluteString, word: "lotto")  {
//                    logoImageLeadingConstraint.isActive = false
//                    logoImageWidthConstraint.isActive = false
//                    logoImageTopConstraint.isActive = false
                    jackpotTitleTopConstraint.isActive = false
//                    whiteBackgroundHeightConstraint.isActive = false
//                 
//                    logoImageLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -32.scale)
//                     logoImageWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 188.scale)
                    jackpotTitleTopConstraint = jackpotTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor , constant: 13.scale)
//                    whiteBackgroundHeightConstraint = whiteBackgroundView.heightAnchor.constraint(equalToConstant: 144.scale)
//                   
//                    logoImageLeadingConstraint.isActive = true
//                    logoImageWidthConstraint.isActive = true
//                    logoImageTopConstraint.isActive = true
                    jackpotTitleTopConstraint.isActive = true
//                    whiteBackgroundHeightConstraint.isActive = true
//                    setNeedsLayout()
                    jackpotTitleLabel.alpha = 1
                    
                }
                
                if  doesURLContain(lottery.logoUrl.absoluteString, word: "power") {
//                    logoImageLeadingConstraint.isActive = false
//                    logoImageWidthConstraint.isActive = false
//                    logoImageTopConstraint.isActive = false
                    jackpotTitleTopConstraint.isActive = false
                    whiteBackgroundHeightConstraint.isActive = false
                  
//                    logoImageLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale)
//                    logoImageWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 155.scale)
//                    logoImageTopConstraint = logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5.scale)
                    jackpotTitleTopConstraint = jackpotTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor , constant: -3.scale)
//                    whiteBackgroundHeightConstraint = whiteBackgroundView.heightAnchor.constraint(equalToConstant: 116.scale)
                  
//                    logoImageLeadingConstraint.isActive = true
//                    logoImageWidthConstraint.isActive = true
//                    logoImageTopConstraint.isActive = true
                    jackpotTitleTopConstraint.isActive = true
                    whiteBackgroundHeightConstraint.isActive = true
                    setNeedsLayout()
                  
                    jackpotTitleLabel.alpha = 1
                }
            
                if  doesURLContain(lottery.logoUrl.absoluteString, word: "cash4") {
//                    logoImageLeadingConstraint.isActive = false
//                    logoImageWidthConstraint.isActive = false
//                    logoImageTopConstraint.isActive = false
                    jackpotTitleTopConstraint.isActive = false
                    whiteBackgroundHeightConstraint.isActive = false
              
//                    logoImageTopConstraint = logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8.scale)
//                    logoImageLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale)
//                    logoImageWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 80.scale)
                    
                    jackpotTitleTopConstraint = jackpotTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor , constant: -10.scale)
//                    whiteBackgroundHeightConstraint = whiteBackgroundView.heightAnchor.constraint(equalToConstant: 116.scale)
                
//                    logoImageLeadingConstraint.isActive = true
//                    logoImageWidthConstraint.isActive = true
//                    logoImageTopConstraint.isActive = true
                    jackpotTitleTopConstraint.isActive = true
                    whiteBackgroundHeightConstraint.isActive = true
                    setNeedsLayout()
                
                    jackpotTitleLabel.alpha = 0
                    jackpotLabel.text = game.jackpot != "" ? "\(game.jackpot) per day" : "UNDETERMINED"

                }
                
            }
        }
       
        
        
        // Assign data to arrays (use the full double array)
        winningNumbers = game.winningNumbers ?? []
        myLuckyNumbers = game.myLuckyNumbers ?? []
        
         
     
        myLuckyNumbersCollectionViewHeightConstraint.isActive = false
        if myLuckyNumbers.isEmpty {
            let cellHeight = 150.scale
            myLuckyNumbersCollectionViewHeightConstraint =    myLuckyNumbersCollectionView.heightAnchor.constraint(equalToConstant: cellHeight)
        } else {
            let cellHeight =  CGFloat(max(0, myLuckyNumbers.count )) * CGFloat(40 + 10.scale) + 0.scale
            myLuckyNumbersCollectionViewHeightConstraint =    myLuckyNumbersCollectionView.heightAnchor.constraint(equalToConstant: cellHeight)
        }
        myLuckyNumbersCollectionViewHeightConstraint.isActive = true
        
        winningNumbersCollectionViewHeightConstraint.isActive = false
        if winningNumbers.isEmpty {
            let cellHeight = 50.scale
            winningNumbersCollectionViewHeightConstraint =    winningNumbersCollectionView.heightAnchor.constraint(equalToConstant: cellHeight)
        } else {
            let cellHeight =  CGFloat(max(0, winningNumbers.count )) * CGFloat(40 + 10.scale) + 0.scale
            winningNumbersCollectionViewHeightConstraint =    winningNumbersCollectionView.heightAnchor.constraint(equalToConstant: cellHeight)
        }
        winningNumbersCollectionViewHeightConstraint.isActive = true
        setNeedsLayout()
        // Reload collection views with new data
        winningNumbersCollectionView.reloadData()
        myLuckyNumbersCollectionView.reloadData()
        
    }
    
}

// MARK: - Setup Methods
private extension PastGameCell {
    func setupUI() {
        backgroundColor = .white
        
        // Setup backgroundImageView
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleToFill
        addSubview(backgroundImageView)
        
        // Setup whiteBackgroundView
        whiteBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        whiteBackgroundView.backgroundColor = .white
        whiteBackgroundView.layer.cornerRadius = 20.scale
        whiteBackgroundView.layer.borderWidth = 2.scale
        whiteBackgroundView.layer.borderColor = Appearance.witeBcgBorderColor.cgColor
        addSubview(whiteBackgroundView)
        
        // Existing UI setup
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = Fonts.Inter.medium(size: 12.5.scale)
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
        
        addSubview(logoImageView)
    
        whiteBackgroundView.addSubview(dateLabel)
      
        addSubview(winningNumbersCollectionView)
        addSubview(winningNumbersTitleLabel)
        addSubview(dashedLineImageView)
        addSubview(myLuckyNumbersCollectionView)
        addSubview(myLuckyNumbersTitleLabel)
        
        addSubview(jackpotTitleLabel)
        addSubview(jackpotLabel)
    }

    
    func setupLayoutConstraints() {
        myLuckyNumbersCollectionViewHeightConstraint = myLuckyNumbersCollectionView.heightAnchor.constraint(equalToConstant: 40.scale)
        winningNumbersCollectionViewHeightConstraint = winningNumbersCollectionView.heightAnchor.constraint(equalToConstant: 40.scale)
        logoImageLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16.scale)
        logoImageWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 100.scale)
        logoImageTopConstraint = logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10.scale)
        whiteBackgroundTopConstraint = whiteBackgroundView.topAnchor.constraint(equalTo: topAnchor)
        
        whiteBackgroundHeightConstraint =  whiteBackgroundView.heightAnchor.constraint(equalToConstant: self.frame.size.height >= 250.scale ? 144.scale : 116.scale)
        jackpotTitleTopConstraint = jackpotTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor , constant: 10.scale)

        NSLayoutConstraint.activate([
            // Background Image Constraints
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // White Background View Constraints
            whiteBackgroundTopConstraint,
            whiteBackgroundView.widthAnchor.constraint(equalToConstant: 343.scale),
            whiteBackgroundHeightConstraint,

            // Logo Image Constraints
            logoImageTopConstraint,
            logoImageLeadingConstraint,
            logoImageWidthConstraint,
            logoImageView.heightAnchor.constraint(equalToConstant: 48.scale),
            
            jackpotTitleTopConstraint,
            jackpotTitleLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16.scale),
            jackpotTitleLabel.heightAnchor.constraint(equalToConstant: 15.scale),
          
            jackpotLabel.topAnchor.constraint(equalTo: jackpotTitleLabel.bottomAnchor, constant: 5.scale),
            jackpotLabel.leadingAnchor.constraint(equalTo: jackpotTitleLabel.leadingAnchor, constant: 0.scale),
            jackpotLabel.heightAnchor.constraint(equalToConstant: 30.scale),
            
            
            dateLabel.centerYAnchor.constraint(equalTo: jackpotLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22.scale),
            dateLabel.heightAnchor.constraint(equalToConstant: 13.scale),

            
            // Winning Numbers CollectionView Constraints
            winningNumbersCollectionView.topAnchor.constraint(equalTo: whiteBackgroundView.bottomAnchor, constant: 8.scale),
            winningNumbersCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            winningNumbersCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            winningNumbersCollectionViewHeightConstraint,

            // Winning Numbers Title Label Constraints
            winningNumbersTitleLabel.bottomAnchor.constraint(equalTo: winningNumbersCollectionView.bottomAnchor, constant: 23.scale),
            winningNumbersTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            winningNumbersTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),

            // Dashed Line View Constraints
            dashedLineImageView.topAnchor.constraint(equalTo: winningNumbersTitleLabel.bottomAnchor, constant: 17.scale),
            dashedLineImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.scale),
            dashedLineImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.scale),
            dashedLineImageView.heightAnchor.constraint(equalToConstant: 1.scale),

            // My Lucky Numbers CollectionView Constraints
            myLuckyNumbersCollectionView.topAnchor.constraint(equalTo: dashedLineImageView.bottomAnchor, constant: 20.scale),
            myLuckyNumbersCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            myLuckyNumbersCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            myLuckyNumbersCollectionViewHeightConstraint,

            // My Lucky Numbers Title Label Constraints
            myLuckyNumbersTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20.scale),
            myLuckyNumbersTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            myLuckyNumbersTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
        ])
    }

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PastGameCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == winningNumbersCollectionView {
            return  CGSize(width: 40.scale, height: 40.scale)
        } else {
            let viewWidth = frame.width
            return CGSize(width: viewWidth , height: 40.scale)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.scale,
                            left: 0.scale,
                            bottom: 0.scale,
                            right:  0.scale)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == winningNumbersCollectionView {
            return winningNumbers.count ?? 0
        } else {
            return myLuckyNumbers != [] ? 1 : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == winningNumbersCollectionView {
            return winningNumbers.first?.count ?? 0
        } else {
            return myLuckyNumbers.count ?? 0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == winningNumbersCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberCell", for: indexPath) as? NumberCell else {
                fatalError("Could not dequeue cell with identifier: NumberCell")
            }
            configureCellForWinningNumbers(cell, at: indexPath)
            return cell
        }
        if collectionView == myLuckyNumbersCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LuckyNumbersRowCollecitonViewCell.reuseIdentifier, for: indexPath) as? LuckyNumbersRowCollecitonViewCell else {
                fatalError("Could not dequeue cell with identifier: LuckyNumbersRowCollecitonViewCell")
            }
            cell.numbers = myLuckyNumbers[indexPath.item]
            return cell
        }
        
        fatalError("Not implemented")
    }
    
    private func configureCellForWinningNumbers(_ cell: NumberCell, at indexPath: IndexPath) {
    
        let number = winningNumbers[indexPath.section][indexPath.item]
        var lastIndex = winningNumbers[0].count - 1
        
        if indexPath.item == lastIndex {
            cell.numberLabel.text = String(number)
            cell.backgroundViewContainer.backgroundColor = Appearance.main100
            cell.numberLabel.textColor = Appearance.mono100
            cell.backgroundViewContainer.alpha = 1
            cell.layer.borderColor = UIColor.clear.cgColor
        } else {
            cell.numberLabel.text = String(number)
            cell.backgroundViewContainer.backgroundColor = Appearance.mono100
            cell.backgroundViewContainer.alpha = 0.5
            cell.numberLabel.textColor = Appearance.mono100
            cell.layer.borderColor = UIColor.clear.cgColor//Appearance.main500.cgColor
        }
        if myLuckyNumbers.count != 0 {
            configureCell(cell, withNumber: number, comparisonArray: myLuckyNumbers, indexPath: indexPath)
        }
    }
    
    
    private func configureCellForLuckyNumbers(_ cell: NumberCell, at indexPath: IndexPath) {
        let number = myLuckyNumbers[indexPath.section][indexPath.item]
        configureCell(cell, withNumber: number, comparisonArray: winningNumbers, indexPath: indexPath)
        if indexPath.item == myLuckyNumbers[0].count-1 {
            for winNumArray in winningNumbers {
                if winNumArray.last != number {
                    cell.numberLabel.textColor = Appearance.main100
                    cell.layer.borderColor = Appearance.main100.cgColor
                    cell.backgroundViewContainer.backgroundColor = Appearance.mono100
                    cell.backgroundViewContainer.alpha = 0.5
                }
            }
        }
    }
    
    private func configureCell(_ cell: NumberCell, withNumber number: Int, comparisonArray: [[Int]], indexPath: IndexPath) {
        if comparisonArray.count == 0 {
            return

        }
        var lastIndex = comparisonArray[0].count - 1
        if indexPath.item == lastIndex {
         
        } else {
            cell.numberLabel.textColor = Appearance.mono100
        }
        
        
        let allNumbers = Set(comparisonArray.flatMap({ $0 }))
        let isHighlight = allNumbers.contains(number)
        cell.configure(with: String(number))
        cell.backgroundViewContainer.backgroundColor = isHighlight ? Appearance.main600 : Appearance.mono100
        if cell.backgroundViewContainer.backgroundColor  == Appearance.main600 {
            cell.numberLabel.textColor = Appearance.mono200
        }
    
        cell.backgroundViewContainer.alpha = isHighlight ? 1 : 0.5
       
        cell.layer.borderColor = isHighlight ? UIColor.clear.cgColor : Appearance.main500.cgColor
      
        if indexPath.item == lastIndex {
            cell.backgroundViewContainer.backgroundColor = Appearance.main100
            cell.backgroundViewContainer.alpha = 1
            cell.numberLabel.textColor = Appearance.mono100
            cell.layer.borderColor = UIColor.clear.cgColor
        } else {
            
        }
        
      
    }
}

extension PastGameCell {
    private func formatToMillions(_ value: String) -> String {
        guard let number = Double(value.filter { "0123456789.".contains($0) }) else {
            return value
        }

        if number < 1_000_000 && number >= 1_000 {
            let thousand = number / 1_000
            return String(format: "$%.0f K.", thousand)  // Format for numbers in thousands
        } else if number < 1_000 {
            return String(format: "$%.0f", number)  // Format for numbers less than 1,000
        }

        let million = number / 1_000_000
        return String(format: "$%.0f M.", million)  // Format for numbers in millions
    }
    func doesURLContain(_ urlString: String, word: String) -> Bool {
        return urlString.lowercased().contains(word)
    }
}
extension UIView {
    func disableAllConstraints() {
        var viewsToDisable: [UIView] = [self]
        var index = 0
        
        while index < viewsToDisable.count {
            let currentView = viewsToDisable[index]
            viewsToDisable += currentView.subviews
            currentView.constraints.forEach { $0.isActive = false }
            index += 1
        }
    }
}
