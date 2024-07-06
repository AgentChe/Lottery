//
//  NumberCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/10/24.
//

import UIKit

class NumberCell: UICollectionViewCell {
     let numberLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(numberLabel)
        backgroundColor = Appearance.mono100
        layer.cornerRadius = 20.scale
        layer.masksToBounds = true
        layer.borderColor = Appearance.main500.cgColor
        layer.borderWidth = 1.scale
        
        numberLabel.font = Fonts.Inter.medium(size: 16.scale)
        numberLabel.textAlignment = .center
        numberLabel.textColor = Appearance.mono200
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with number: String) {
        numberLabel.text = number
    }
    
    func setNumberLabelColor(_ color: UIColor) {
        numberLabel.textColor = color
    }
}
