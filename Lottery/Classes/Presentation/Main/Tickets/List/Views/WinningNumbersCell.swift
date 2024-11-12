//
//  WinningNumbersCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 10/24/24.
//

import UIKit

class WinningNumbersCollectionCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    static let identifier = "WinningNumberCell"
    
    var bonusIdx: [Int] = []
    var winningNumbers: [[Int]] = []
    var winningNumbersWithLabels: [[String]] = []
    var ticketNumbers: [[Int]] = []
    var ticketNumbersWithLabels: [[String]] = []
    var section: Int!
    var indexPath: IndexPath!
    var numbers: [Int] = []

    weak var delegate: TicketNumbersCollectionCellDelegate?
    weak var parentCell: TicketDataCell?
    
    lazy var winningNumbersRowNumbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(FullNumberTicketCell.self, forCellWithReuseIdentifier: FullNumberTicketCell.reuseIdentifier)
        return collectionView
    }()
    override func prepareForReuse() {
        super.prepareForReuse()
        winningNumbersRowNumbersCollectionView.contentOffset = .zero
    }
    func config() {
        winningNumbersWithLabels = convertTo2DStringArray(winningNumbers)
        ticketNumbersWithLabels = convertTo2DStringArray(ticketNumbers)
        //print("ticketsNumbersWithLabels", winningNumbersWithLabels)
        winningNumbersRowNumbersCollectionView.reloadData()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollectionView() {
        contentView.addSubview(winningNumbersRowNumbersCollectionView)

        NSLayoutConstraint.activate([
            winningNumbersRowNumbersCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            winningNumbersRowNumbersCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            winningNumbersRowNumbersCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.scale),
            winningNumbersRowNumbersCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10.scale
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 10.scale
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return  CGSize(width: 40.scale, height: 40.scale)
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return winningNumbersWithLabels[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FullNumberTicketCell.reuseIdentifier, for: indexPath) as! FullNumberTicketCell
        let labelString = winningNumbersWithLabels[section][indexPath.item]
       // print("label:", label)
        // Determine if this is the last item in the section
        let isInBothArrays = isElementInBothArrays(labelString: labelString, array1: winningNumbersWithLabels, array2: ticketNumbersWithLabels)
        let isLastItemInSection = bonusIdx.contains(indexPath.item)
        cell.configure(with: labelString, isLastInSection: isLastItemInSection, indexPath: indexPath, isWinningNumbersCollectionView: true, showCheckmark: isInBothArrays)
        
        
        return cell
    }
   
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
       delegate?.winningNumbersRowCell(self, didScroll: scrollView.contentOffset)
     
    }

 
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.scale,
                            left: 5.scale,
                            bottom: 0.scale,
                            right: 0.scale)
    }

    func convertTo2DStringArray(_ intArray: [[Int]]) -> [[String]] {
        return intArray.map { innerArray in
            innerArray.map { String($0) }
        }
    }
    
}

extension WinningNumbersCollectionCell {
    func isElementInBothArrays(labelString: String, array1: [[String]], array2: [[String]]) -> Bool {
        // Flatten both 2D arrays into single-dimensional arrays
        let flattenedArray1 = array1.flatMap { $0 }
        let flattenedArray2 = array2.flatMap { $0 }
        
        // Check if the labelString exists in both flattened arrays
        return flattenedArray1.contains(labelString) && flattenedArray2.contains(labelString)
    }
}
