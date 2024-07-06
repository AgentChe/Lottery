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
    private let dateLabelContainer = UIView()
    private let dateLabel = UILabel()
    var logoIamgeLeadingConstraint: NSLayoutConstraint!
    var logoIamgeWidthConstraint: NSLayoutConstraint!
    private let winningNumbersTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "WINNING NUMBERS"
        label.font = Fonts.Inter.regular(size: 12.5.scale)
        label.textAlignment = .center
        label.textColor = Appearance.mono200
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Create an attributed string with increased kerning
        let attributedText = NSMutableAttributedString(string: "WINNING NUMBERS")
        attributedText.addAttribute(.kern, value: 1.5, range: NSRange(location: 0, length: attributedText.length)) // Increase kerning as needed
        
        label.attributedText = attributedText
        return label
    }()
    var myLuckyNumbersCollectionViewHeghitConstraint: NSLayoutConstraint!
    var winningNumbersCollectionViewHeghitConstraint: NSLayoutConstraint!
     let myLuckyNumbersTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "MY LUCKY NUMBERS"
        label.font = Fonts.Inter.regular(size: 12.5.scale)
        label.textAlignment = .center
        label.textColor = Appearance.mono200
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Create an attributed string with increased kerning
        let attributedText = NSMutableAttributedString(string: "MY LUCKY NUMBERS")
        attributedText.addAttribute(.kern, value: 1.5, range: NSRange(location: 0, length: attributedText.length)) // Increase kerning as needed
        
        label.attributedText = attributedText
        
        return label
    }()
    
     let dashedLineImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PastDraws.DashedLine")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var winningNumbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10.scale
        layout.minimumLineSpacing = 14.scale
        layout.itemSize = CGSize(width: 40.scale, height: 40.scale)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .blue
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isUserInteractionEnabled = false
        collectionView.register(NumberCell.self, forCellWithReuseIdentifier: "NumberCell")
        return collectionView
    }()
    
     lazy var myLuckyNumbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10.scale
       
        layout.itemSize = CGSize(width: 40.scale, height: 40.scale)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .red
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
         collectionView.isUserInteractionEnabled = false
        collectionView.delegate = self
        collectionView.register(NumberCell.self, forCellWithReuseIdentifier: "NumberCell")
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
}

// MARK: - Public Methods
extension PastGameCell {
    func configure(game: Game, lotteries: [Lottery]) {
        logoImageView.image = UIImage(named: "placeholderImage")
        logoImageView.contentMode = .scaleAspectFit
        myLuckyNumbers = game.myLuckyNumbers ?? []
        winningNumbers = game.winningNumbers ?? []
        for lottery in lotteries {
            if lottery.id == game.lotteryId {
                
                logoImageView.kf.setImage(with: lottery.logoUrl)
                if doesURLContain(lottery.logoUrl.absoluteString, word: "mega") || doesURLContain(lottery.logoUrl.absoluteString, word: "2by2") {
                    logoIamgeLeadingConstraint.isActive = false
                    logoIamgeWidthConstraint.isActive = false
                    logoIamgeLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -15.scale)
                    logoIamgeWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 188.scale)
                    logoIamgeLeadingConstraint.isActive = true
                    logoIamgeWidthConstraint.isActive = true
                    setNeedsLayout()
                    
                }
                if  doesURLContain(lottery.logoUrl.absoluteString, word: "power") || doesURLContain(lottery.logoUrl.absoluteString, word: "lotto") {
                    logoIamgeLeadingConstraint.isActive = false
                    logoIamgeWidthConstraint.isActive = false
                    logoIamgeLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale)
                    logoIamgeWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 160.scale)
                    logoIamgeLeadingConstraint.isActive = true
                    logoIamgeWidthConstraint.isActive = true
                    setNeedsLayout()
                }
                
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: game.date))
        dateLabel.text = formattedDate.uppercased()
        
        // Assign data to arrays (use the full double array)
        winningNumbers = game.winningNumbers ?? []
        myLuckyNumbers = game.myLuckyNumbers ?? []
        
        // Reload collection views with new data
        winningNumbersCollectionView.reloadData()
        myLuckyNumbersCollectionView.reloadData()
     
        myLuckyNumbersCollectionViewHeghitConstraint.isActive = false
        if myLuckyNumbers.isEmpty {
            let cellHeight = 150.scale
            myLuckyNumbersCollectionViewHeghitConstraint =    myLuckyNumbersCollectionView.heightAnchor.constraint(equalToConstant: cellHeight)
        } else {
            let cellHeight =  CGFloat(max(0, myLuckyNumbers.count )) * CGFloat(40 + 10.scale) + 0.scale
            myLuckyNumbersCollectionViewHeghitConstraint =    myLuckyNumbersCollectionView.heightAnchor.constraint(equalToConstant: cellHeight)
        }
        myLuckyNumbersCollectionViewHeghitConstraint.isActive = true
        
        winningNumbersCollectionViewHeghitConstraint.isActive = false
        if winningNumbers.isEmpty {
            let cellHeight = 50.scale
            winningNumbersCollectionViewHeghitConstraint =    winningNumbersCollectionView.heightAnchor.constraint(equalToConstant: cellHeight)
        } else {
            let cellHeight =  CGFloat(max(0, winningNumbers.count )) * CGFloat(40 + 10.scale) + 0.scale
            winningNumbersCollectionViewHeghitConstraint =    winningNumbersCollectionView.heightAnchor.constraint(equalToConstant: cellHeight)
        }
        winningNumbersCollectionViewHeghitConstraint.isActive = true
        setNeedsLayout()
        
        
    }
    
}

// MARK: - Setup Methods
private extension PastGameCell {
    func setupUI() {
        backgroundColor = .white
        
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        dateLabelContainer.layer.shadowColor = Appearance.dropShadowColor?.cgColor
        dateLabelContainer.layer.shadowOpacity = 0.5
        dateLabelContainer.layer.shadowRadius = 3.scale
        dateLabelContainer.layer.shadowOffset = CGSize(width: 0, height: 2.scale)
        
        dateLabel.font = Fonts.Inter.medium(size: 12.5.scale)
        dateLabel.textAlignment = .center
        dateLabel.textColor = Appearance.main300
        dateLabel.backgroundColor = Appearance.mono100
        dateLabel.layer.cornerRadius = 17.scale
        dateLabel.layer.masksToBounds = true
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(logoImageView)
        addSubview(dateLabelContainer)
        dateLabelContainer.addSubview(dateLabel)
        addSubview(winningNumbersCollectionView)
        addSubview(winningNumbersTitleLabel)
        addSubview(dashedLineImageView)
        addSubview(myLuckyNumbersCollectionView)
        addSubview(myLuckyNumbersTitleLabel)
    }
    
    func setupLayoutConstraints() {
        myLuckyNumbersCollectionViewHeghitConstraint =    myLuckyNumbersCollectionView.heightAnchor.constraint(equalToConstant: 40.scale)
      winningNumbersCollectionViewHeghitConstraint = winningNumbersCollectionView.heightAnchor.constraint(equalToConstant: 40.scale)
        logoIamgeLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -15.scale)
        logoIamgeWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 188.scale)
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: -29.scale),
            logoIamgeLeadingConstraint,
            logoIamgeWidthConstraint,
            logoImageView.heightAnchor.constraint(equalToConstant: 58.scale),
            
            dateLabelContainer.topAnchor.constraint(equalTo: topAnchor, constant: -16.scale),
            dateLabelContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30.scale),
            dateLabelContainer.widthAnchor.constraint(equalToConstant: 112.scale),
            dateLabelContainer.heightAnchor.constraint(equalToConstant: 32.scale),
            
            dateLabel.centerXAnchor.constraint(equalTo: dateLabelContainer.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: dateLabelContainer.centerYAnchor),
            dateLabel.widthAnchor.constraint(equalTo: dateLabelContainer.widthAnchor),
            dateLabel.heightAnchor.constraint(equalTo: dateLabelContainer.heightAnchor),
            
            // Winning Numbers CollectionView
            winningNumbersCollectionView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20.scale),
            winningNumbersCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            winningNumbersCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            winningNumbersCollectionViewHeghitConstraint,
            
            // Winning Numbers Title Label
            winningNumbersTitleLabel.bottomAnchor.constraint(equalTo: winningNumbersCollectionView.bottomAnchor, constant: 30.scale),
            winningNumbersTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            winningNumbersTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            
            // Dashed Line View
            dashedLineImageView.topAnchor.constraint(equalTo: winningNumbersTitleLabel.bottomAnchor, constant: 25.scale),
            dashedLineImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.scale),
            dashedLineImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.scale),
            dashedLineImageView.heightAnchor.constraint(equalToConstant: 1.scale),
            
            // My Lucky Numbers CollectionView
            myLuckyNumbersCollectionView.topAnchor.constraint(equalTo: dashedLineImageView.bottomAnchor, constant: 20.scale),
            myLuckyNumbersCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            myLuckyNumbersCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            myLuckyNumbersCollectionViewHeghitConstraint  ,
            
            // My Lucky Numbers Title Label
            myLuckyNumbersTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25.scale),
            myLuckyNumbersTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            myLuckyNumbersTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
        ])
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PastGameCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == winningNumbersCollectionView {
            return UIEdgeInsets(top: 0.scale, left: 0, bottom: 10.scale, right: 0)
        } else {
            return UIEdgeInsets(top: 0.scale, left: 0, bottom: 10.scale, right: 0)
        }
        // Adjust insets as needed
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == winningNumbersCollectionView {
            return winningNumbers.count ?? 0 // Using the first set of numbers for simplicity
        } else {
            return myLuckyNumbers.count ?? 0 // Using the first set of numbers for simplicity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == winningNumbersCollectionView {
            return winningNumbers.first?.count ?? 0 // Using the first set of numbers for simplicity
        } else {
            return myLuckyNumbers.first?.count ?? 0 // Using the first set of numbers for simplicity
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberCell", for: indexPath) as? NumberCell else {
            fatalError("Could not dequeue cell with identifier: NumberCell")
        }
        
        if collectionView == winningNumbersCollectionView {
            configureCellForWinningNumbers(cell, at: indexPath)
        } else {
            configureCellForLuckyNumbers(cell, at: indexPath)
        }
        
        return cell
    }

    private func configureCellForWinningNumbers(_ cell: NumberCell, at indexPath: IndexPath) {
        let number = winningNumbers[indexPath.section][indexPath.item]
        configureCell(cell, withNumber: number, comparisonArray: myLuckyNumbers, indexPath: indexPath)
    }

    private func configureCellForLuckyNumbers(_ cell: NumberCell, at indexPath: IndexPath) {
        let number = myLuckyNumbers[indexPath.section][indexPath.item]
        configureCell(cell, withNumber: number, comparisonArray: winningNumbers, indexPath: indexPath)
    }

    private func configureCell(_ cell: NumberCell, withNumber number: Int, comparisonArray: [[Int]], indexPath: IndexPath) {
        let allNumbers = Set(comparisonArray.flatMap({ $0 }))
        let isHighlight = allNumbers.contains(number)
        cell.configure(with: String(number))
        cell.backgroundColor = isHighlight ? Appearance.main600 : .white
        cell.layer.borderColor = isHighlight ? UIColor.clear.cgColor : Appearance.main500.cgColor
        if comparisonArray.count == 0 {
            return
            
        }
//        let lastIndex = comparisonArray[indexPath.section].count - 1
//
//        if indexPath.item == lastIndex {
//            cell.backgroundColor = Appearance.main100
//            cell.setNumberLabelColor(Appearance.mono100)
//        } else {
//            cell.setNumberLabelColor(Appearance.mono200)
//        }
    }
}

extension PastGameCell {
    private func formatToMillions(_ value: String) -> String {
        guard let number = Double(value.filter { "0123456789.".contains($0) }) else {
            return value
        }
        
        let million = number / 1_000_000
        return String(format: "$%.0f M.", million)
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
