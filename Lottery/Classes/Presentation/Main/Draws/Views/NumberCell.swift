//
//  NumberCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/10/24.
//

import UIKit
class NumberCell: UICollectionViewCell {
    // Create the backgroundView
    let backgroundViewContainer = UIView()
    let numberLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Configure the backgroundView
        backgroundViewContainer.backgroundColor = .clear // Set the desired background color
        backgroundViewContainer.layer.cornerRadius = 20.scale
        backgroundViewContainer.layer.masksToBounds = true
        backgroundViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the backgroundView to the cell
        addSubview(backgroundViewContainer)
        
        // Set up the numberLabel
        addSubview(numberLabel)
        numberLabel.font = Fonts.Inter.medium(size: 16.scale)
        numberLabel.textAlignment = .center
        numberLabel.textColor = Appearance.mono100
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up the cell's appearance
        backgroundColor = .clear
        layer.cornerRadius = 20.scale
        
    
        // Set up constraints
        NSLayoutConstraint.activate([
            // BackgroundView constraints to fill the entire cell
            backgroundViewContainer.topAnchor.constraint(equalTo: topAnchor),
            backgroundViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // NumberLabel constraints
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        layer.borderWidth = 1.scale
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Method to configure the number label
    func configure(with number: String) {
        numberLabel.text = number
    }
    
    // Method to set the color of the number label
    func setNumberLabelColor(_ color: UIColor) {
        numberLabel.textColor = color
    }
}
