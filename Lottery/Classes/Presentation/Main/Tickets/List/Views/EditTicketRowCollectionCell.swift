//
//  EditTicketRowCollectionCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 10/28/24.
//

import UIKit

class EditTicketRowCollectionCell: UICollectionViewCell,EditNumberCellDelegate {
    static let reuseIdentifier: String = "EditTicketRowCollectionCell"
    weak var parentDelegate: EditTicketRowCollectionCellDelegate?
    var numbersStringArray: [[String]] = []
    var bonusIdx: [Int] = []
    var numbers: [String] = []

    
    // MARK: - UI Components
    weak var parent: TicketEditCell?
    var section: Int = 0
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8.scale
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Appearance.mono100
        return collectionView
    }()
    func numberCell(_ cell: EditNumberCell, didUpdateNumber number: String, at indexPath: IndexPath) {
        // Update the number in the local 'numbers' array
        numbers[indexPath.item] = number

        // Notify the parent of the update
        parentDelegate?.editTicketRowCollectionCell(self, didUpdateNumbers: numbers, inSection: self.section)
    }


    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        backgroundColor = .red
        configureCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        configureCollectionView()
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0.scale),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.scale),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -0.scale),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -0.scale)
        ])
    }
    
    private func configureCollectionView() {
        collectionView.register(EditNumberCell.self, forCellWithReuseIdentifier: EditNumberCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension EditTicketRowCollectionCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditNumberCell.reuseIdentifier, for: indexPath) as! EditNumberCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.numberOfCells = numbers.count
        
        // Configure the cell with the number
        let number = numbers[indexPath.item]
        let isLastInRow = (indexPath.item == numbers.count - 1)
        cell.bonusIdx = bonusIdx
        cell.configure(number: number, isLastInRow: isLastInRow, indexPath: indexPath)
        
        return cell
    }
    
}

extension EditTicketRowCollectionCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40.scale, height: 40.scale)
    }
    func numberCell(_ cell: EditNumberCell, didFinishEditingNumber number: String, at indexPath: IndexPath) {
        // Move to the next appropriate cell
        parentDelegate?.editTicketRowCollectionCell(self, moveToNextUnfilledCellFrom: indexPath)
    }

}



