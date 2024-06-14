//
//  EditNumberCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/14/24.
//

import UIKit

class EditNumberCell: UICollectionViewCell {
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18.scale)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = Appearance.mono100
        layer.cornerRadius = 20.scale
        layer.masksToBounds = true
        layer.borderColor = Appearance.main500.cgColor
        layer.borderWidth = 1.scale
        addSubview(numberLabel)
        
        NSLayoutConstraint.activate([
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(number: Int, isLastInRow: Bool) {
        numberLabel.text = "\(number)"
        if isLastInRow {
            // Apply the special background and text color for the last cell in the row
            backgroundColor = Appearance.main100
            numberLabel.textColor = Appearance.mono100
            layer.borderWidth = 0.scale
        } else {
            // Reset to default appearance if not the last cell in the row
            backgroundColor = Appearance.mono100
            numberLabel.textColor = Appearance.mono200 // Or your default text color
        }
    }
}
