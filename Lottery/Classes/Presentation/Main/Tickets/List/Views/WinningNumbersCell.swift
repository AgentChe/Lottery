//
//  WinningNumbersCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 10/24/24.
//

import UIKit

class WinningNumberCell: UICollectionViewCell {
    
    static let identifier = "WinningNumberCell"
    
    // Label for displaying the winning number
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(numberLabel)
        
        // Set constraints for the label
        NSLayoutConstraint.activate([
            numberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            numberLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    // Configure the cell with a winning number
    func configure(with number: Int) {
        numberLabel.text = "\(number)"
    }
}
