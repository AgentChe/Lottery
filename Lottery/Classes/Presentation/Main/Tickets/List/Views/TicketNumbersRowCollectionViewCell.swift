//
//  TicketNumbersRowCollectionViewCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 10/22/24.
//

import UIKit

protocol TicketNumbersRowCellDelegate: AnyObject {
    func ticketNumbersRowCell(_ cell: TicketNumbersRowCollectionViewCell, didScroll contentOffset: CGPoint)
}

class TicketNumbersRowCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    static let reuseIdentifier = "TicketNumbersRowCollectionViewCell"
    var bonusIdx: [Int] = []
    var ticketNumbers: [[Int]] = []
    var ticketsNumbersWithLabels: [[String]] = []
    var section: Int!
    var indexPath: IndexPath!
    var numbers: [Int] = []

    weak var delegate: TicketNumbersRowCellDelegate?
    
    lazy var ticketNumbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.register(NumberTicketCell.self, forCellWithReuseIdentifier: NumberTicketCell.reuseIdentifier)
        return collectionView
    }()
    override func prepareForReuse() {
        super.prepareForReuse()
        ticketNumbersCollectionView.contentOffset = .zero
    }
    func config() {
        ticketsNumbersWithLabels = convertTo2DStringArray(ticketNumbers)
       // print("ticketsNumbersWithLabels", ticketsNumbersWithLabels)
        ticketNumbersCollectionView.reloadData()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollectionView() {
        contentView.addSubview(ticketNumbersCollectionView)
        
        NSLayoutConstraint.activate([
            ticketNumbersCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            ticketNumbersCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            ticketNumbersCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.scale),
            ticketNumbersCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10.scale
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 0 {
            return 0.scale
        } else {
            return 0.scale
        }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumberTicketCell.reuseIdentifier, for: indexPath) as! NumberTicketCell
        
        let label = ticketsNumbersWithLabels[section][indexPath.item]
        print("label:", label)
        // Determine if this is the last item in the section
        let isLastItemInSection = bonusIdx.contains(indexPath.item)
        cell.configure(with: label, isLastInSection: isLastItemInSection, indexPath: indexPath)
        
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
 
