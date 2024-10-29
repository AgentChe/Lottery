//
//  TicketNumberCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 10/24/24.
//

import UIKit
protocol TicketNumbersCollectionCellDelegate: AnyObject {
    func ticketNumbersRowCell(_ cell: TicketNumbersCollectionCell, didScroll contentOffset: CGPoint)
    func winningNumbersRowCell(_ cell: WinningNumbersCollectionCell, didScroll contentOffset: CGPoint)
}
class TicketNumbersCollectionCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    static let identifier = "TicketNumberCell"
    var bonusIdx: [Int] = [] {
        didSet {
            
//            for i in 0..<bonusIdx.count {
//                bonusIdx[i] = bonusIdx[i] + 1
//            }
        }
    }
    var ticketNumbers: [[Int]] = []
    var ticketsNumbersWithLabels: [[String]] = []
    var winningNumbers: [[Int]] = []
    var winningNumbersWithLabels: [[String]] = []
    var section: Int!
    var indexPath: IndexPath!
    var numbers: [Int] = []
    weak var parentCell: TicketDataCell?
    weak var delegate: TicketNumbersCollectionCellDelegate?
    
    
    lazy var ticketRowNumbersCollectionView: UICollectionView = {
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
        ticketRowNumbersCollectionView.contentOffset = .zero
    }
    func config() {
        ticketsNumbersWithLabels = convertTo2DStringArray(ticketNumbers)
        winningNumbersWithLabels = convertTo2DStringArray(winningNumbers)
        print("ticketsNumbersWithLabels", ticketsNumbersWithLabels)
        ticketRowNumbersCollectionView.reloadData()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollectionView() {
        contentView.addSubview(ticketRowNumbersCollectionView)

        NSLayoutConstraint.activate([
            ticketRowNumbersCollectionView.topAnchor.constraint(equalTo: topAnchor),
            ticketRowNumbersCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            ticketRowNumbersCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale),
            ticketRowNumbersCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.scale
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            return  CGSize(width: 20.scale, height: 40.scale)
        } else {
            return  CGSize(width: 40.scale, height: 40.scale)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ticketsNumbersWithLabels[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FullNumberTicketCell.reuseIdentifier, for: indexPath) as! FullNumberTicketCell
        let labelString = ticketsNumbersWithLabels[section][indexPath.item]
        //print("label:", label)
        // Determine if this is the last item in the section
        let isInBothArrays = isNumericElementInBothArrays(labelString: labelString, array1: winningNumbersWithLabels, array2: ticketsNumbersWithLabels)
        
        let isLastItemInSection = bonusIdx.contains(indexPath.item)
        cell.configure(with: labelString, isLastInSection: isLastItemInSection, indexPath: indexPath, showCheckmark: isInBothArrays)
        
        return cell
    }
   
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       delegate?.ticketNumbersRowCell(self, didScroll: scrollView.contentOffset)
     
    }

 
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.scale,
                            left: 0.scale,
                            bottom: 0.scale,
                            right:  0.scale)
    }

    func convertTo2DStringArray(_ input: [[Int]]) -> [[String]] {
        let alphabet = (65...90).map { String(UnicodeScalar($0)!) } // "A" to "Z"
        
        var result = [[String]]()
        var letterIndex = 0
        var repeatIndex = 0
        
        for array in input {
            // Generate the label (e.g., "A", "B", ..., "Z", "A1", "B1", ...)
            let label: String
            if letterIndex < alphabet.count {
                label = alphabet[letterIndex]
            } else {
                let baseIndex = (letterIndex % alphabet.count)
                label = alphabet[baseIndex] + "\(repeatIndex)"
            }
            
            // Convert the current array to [String] and prepend the label
            let newArray = [label] + array.map { String($0) }
            result.append(newArray)
            
            // Update the indices for next label
            letterIndex += 1
            if letterIndex == alphabet.count {
                letterIndex = 0
                repeatIndex += 1
            }
        }
        
        return result
    }
}

extension TicketNumbersCollectionCell{
    func isNumericElementInBothArrays(labelString: String, array1: [[String]], array2: [[String]]) -> Bool {
        // Check if labelString is numeric
        guard let _ = Double(labelString) else {
            return false // If labelString is not a number, return false immediately
        }
        
        // Filter and flatten both arrays to include only numeric strings
        let flattenedArray1 = array1.flatMap { $0 }.filter { Double($0) != nil }
        let flattenedArray2 = array2.flatMap { $0 }.filter { Double($0) != nil }
        
        // Check if the numeric labelString exists in both filtered arrays
        return flattenedArray1.contains(labelString) && flattenedArray2.contains(labelString)
    }

}
