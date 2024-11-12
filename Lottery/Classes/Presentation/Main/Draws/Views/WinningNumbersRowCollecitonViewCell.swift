//
//  WinningNumbersRowCollecitonViewCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 11/12/24.
//
import UIKit

protocol PastDrawsWinningNumbersRowCellDelegate: AnyObject {
    func luckyNumbersRowCell(_ cell: WinningNumbersRowCollecitonViewCell, didScroll contentOffset: CGPoint)
}
class WinningNumbersRowCollecitonViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    static let reuseIdentifier = "WinningNumbersRowCollecitonViewCell"
    var bonusIdx: [Int] = []
    var winningNumbers: [[Int]] = []
    var myLuckyNumbers: [[Int]] = []
    var indexPath: IndexPath!
    var numbers: [Int] = []
    weak var delegate: PastDrawsWinningNumbersRowCellDelegate?
    lazy var myLuckyNumbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 20.scale
        layout.itemSize = CGSize(width: 40.scale, height: 40.scale) // Adjust item size to match NumberCell
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(NumberCell.self, forCellWithReuseIdentifier: "NumberCell")
        return collectionView
    }()
    func config() {
        numbers = winningNumbers[indexPath.item]
        myLuckyNumbersCollectionView.reloadData()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        // Listen for scroll sync notifications
      //  NotificationCenter.default.addObserver(self, selector: #selector(synchronizeScroll(notification:)), name: .syncScroll, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollectionView() {
        contentView.addSubview(myLuckyNumbersCollectionView)

        NSLayoutConstraint.activate([
            myLuckyNumbersCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            myLuckyNumbersCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            myLuckyNumbersCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            myLuckyNumbersCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberCell", for: indexPath) as! NumberCell
        if numbers.count > indexPath.item {
            let number = numbers[indexPath.item]
            configureCell(cell, withNumber: number, comparisonArray: winningNumbers, indexPath: indexPath)
            if bonusIdx.contains(indexPath.item) {
                for winNumArray in winningNumbers {
                    if winNumArray.last != number {
                        cell.numberLabel.textColor = Appearance.main100
                        cell.layer.borderColor = Appearance.main100.cgColor
                        cell.backgroundViewContainer.backgroundColor = UIColor(hex: "#D9E2FA", alpha: 0.2)
                        cell.backgroundViewContainer.alpha = 0.5
                    }
                }
            }
        }
        return cell
    }
    private func configureCell(_ cell: NumberCell, withNumber number: Int, comparisonArray: [[Int]], indexPath: IndexPath) {
        if comparisonArray.count == 0 {
            return

        }
        var lastIndex = comparisonArray[0].count - 1
        if bonusIdx.contains(indexPath.item) {
         
        } else {
            cell.numberLabel.textColor = Appearance.mono100
        }
        
        
        let allNumbers = Set(comparisonArray.flatMap({ $0 }))
        let isHighlight = allNumbers.contains(number)
        cell.configure(with: String(number))
        cell.backgroundViewContainer.backgroundColor = isHighlight ? Appearance.main600 : UIColor(hex: "#D9E2FA", alpha: 0.2)
        if cell.backgroundViewContainer.backgroundColor  == Appearance.main600 {
            cell.numberLabel.textColor = Appearance.mono200
        }
    
        cell.backgroundViewContainer.alpha = isHighlight ? 1 : 0.5
       
        cell.layer.borderColor = isHighlight ? UIColor.clear.cgColor :  UIColor.clear.cgColor
      
        if bonusIdx.contains(indexPath.item) {
            cell.backgroundViewContainer.backgroundColor = Appearance.main100
            cell.backgroundViewContainer.alpha = 1
            cell.numberLabel.textColor = Appearance.mono100
            cell.layer.borderColor = UIColor.clear.cgColor
        } else {
            
        }
    }
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(delegate)
           delegate?.luckyNumbersRowCell(self, didScroll: scrollView.contentOffset)
        }
    // MARK: - Synchronize Scroll
    @objc private func synchronizeScroll(notification: Notification) {
        guard let userInfo = notification.userInfo, let offset = userInfo["offset"] as? CGPoint else { return }
        myLuckyNumbersCollectionView.contentOffset = offset
    }

   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.scale,
                            left: 0.scale,
                            bottom: 0.scale,
                            right:  0.scale)
    }
    
}


