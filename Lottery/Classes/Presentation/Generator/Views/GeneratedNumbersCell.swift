//
//  GeneratedNumbersCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 11/3/24.
//

import UIKit

class GeneratedNumbersCell: UICollectionViewCell {
 
    
    static let reusableIdentifier: String = "GeneratedNumbersCell"
    var numbers : [[Int]] = []
    var bonusIdx: [Int] = []
    
    private var ticketNumbersCollectionViewHeightConstraint: NSLayoutConstraint!
    private var ticketNumberCollectionViewTopConstraint: NSLayoutConstraint!
    
    lazy var ticketNumbersCollectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0.scale
        layout.minimumLineSpacing = 0.scale
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TicketNumbersCollectionCell.self, forCellWithReuseIdentifier: TicketNumbersCollectionCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .green//Appearance.mono100
        layer.masksToBounds = true
        layer.cornerRadius = 16.scale
        addSubview(ticketNumbersCollectionView)
      
        ticketNumbersCollectionViewHeightConstraint = ticketNumbersCollectionView.heightAnchor.constraint(equalToConstant: 250.scale)
   
        ticketNumberCollectionViewTopConstraint = ticketNumbersCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0.scale)
        
        NSLayoutConstraint.activate([
            ticketNumberCollectionViewTopConstraint,
            ticketNumbersCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -0.scale),
            ticketNumbersCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.scale),
            ticketNumbersCollectionViewHeightConstraint
        ])
        
       
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configure the cell with data
     func configure() {

        updateCollectionViewHeights() // Adjust heights based on `isTheWinner`
    }
    
    private func updateCollectionViewHeights() {
        let ticketHeight = CGFloat(numbers.count)*(40.scale + 10.scale + 4.scale) + 20.scale
        ticketNumbersCollectionViewHeightConstraint.constant = ticketHeight
        layoutIfNeeded() // Apply the changes to the layout
    }
}

extension GeneratedNumbersCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.scale // Adjust the value as needed for the desired space between sections
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count // Number of ticket numbers
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TicketNumbersCollectionCell.identifier, for: indexPath) as! TicketNumbersCollectionCell
        cell.bonusIdx = bonusIdx
        cell.indexPath = indexPath
        cell.ticketNumbers = numbers
        cell.winningNumbers = []
        cell.section = indexPath.item
        cell.config()
        cell.ticketRowNumbersCollectionView.layer.masksToBounds = false
        cell.delegate = self
        
        return cell
    }
    
    // Define the size for the cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: 54.scale)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.scale, left: -10.scale, bottom: 0.scale, right: 0.scale)
    }
}

extension GeneratedNumbersCell:TicketNumbersCollectionCellDelegate {
    func ticketNumbersRowCell(_ cell: TicketNumbersCollectionCell, didScroll contentOffset: CGPoint) {
        // Iterate over the visible cells in numbersCollectionView
        for visibleCell in ticketNumbersCollectionView.visibleCells {
            if let rowCell = visibleCell as? TicketNumbersCollectionCell, rowCell != cell {
                rowCell.ticketRowNumbersCollectionView.contentOffset = contentOffset
            }
        }
    }
    func winningNumbersRowCell(_ cell: WinningNumbersCollectionCell, didScroll contentOffset: CGPoint) {
        
    }
}
