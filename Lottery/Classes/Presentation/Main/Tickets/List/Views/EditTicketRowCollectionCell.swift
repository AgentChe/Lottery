//
//  EditTicketRowCollectionCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 10/28/24.
//

import UIKit

class EditTicketRowCollectionCell: UICollectionViewCell {
    static let reuseIdentifier: String = "EditTicketRowCollectionCell"
    var numbersStringArray: [[String]] = []
    var bonusIdx: [Int] = []
    // MARK: - UI Components
    weak var parent: TicketEditCell?
    var section: Int?
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
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
        collectionView.register(EditNumberCell.self, forCellWithReuseIdentifier: "EditNumberCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension EditTicketRowCollectionCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Replace with your data count
        if let parent = self.parent {
            return parent.numbersStringArray[section].count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditNumberCell", for: indexPath) as! EditNumberCell
        if let parent = parent {
            if let section = section {
                if let numbers = numbersStringArray[safe: section] {
                    cell.bonusIdx = bonusIdx
                    let number = numbers[indexPath.item]
                    
                    let isLastInRow = true//parent.bonusIdx.contains(indexPath.item)
                    cell.configure(number: number, isLastInRow: isLastInRow, indexPath: indexPath)
                    cell.delegate = parent
                    cell.numberOfCells = numbersStringArray.last?.count
                }
            }
            
        }
        return cell
    }
}

extension EditTicketRowCollectionCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40.scale, height: 40.scale)
    }
}
