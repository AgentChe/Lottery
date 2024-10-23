//
//  NumberTicketCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/12/24.
//

import UIKit

class NumberTicketCell: UICollectionViewCell {
    
    static let reuseIdentifier = "NumberTicketCell"
    
    let numberLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .clear
        
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.textAlignment = .center
        numberLabel.font = Fonts.Inter.medium(size: 14.scale)
        numberLabel.textColor = Appearance.mono200
        numberLabel.layer.cornerRadius = 20.scale
        numberLabel.layer.masksToBounds = true
        numberLabel.layer.borderWidth = 1.scale
        numberLabel.layer.borderColor = Appearance.lightGrayBorderTicket.cgColor
        
        self.addSubview(numberLabel)
        
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            numberLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            numberLabel.topAnchor.constraint(equalTo: self.topAnchor),
            numberLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func configure(with numberOrLabel: String, isLastInSection: Bool, indexPath: IndexPath) {
        numberLabel.text = "\(numberOrLabel)"
        
        if isLastInSection {
            numberLabel.backgroundColor = Appearance.main100
            numberLabel.textColor = Appearance.mono100
            numberLabel.layer.borderWidth = 0
        } else {
            numberLabel.backgroundColor = .clear
            numberLabel.textColor = Appearance.mono200
            numberLabel.layer.borderColor = Appearance.lightGrayBorderTicket.cgColor
            numberLabel.layer.borderWidth = 1
        }
        if indexPath.item == 0 {
            numberLabel.layer.borderWidth = 0
            numberLabel.textColor = Appearance.main300
        }
    }
}
