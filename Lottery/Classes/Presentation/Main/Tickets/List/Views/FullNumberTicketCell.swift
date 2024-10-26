//
//  FullNumberTicketCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 10/26/24.
//

import UIKit

class FullNumberTicketCell: UICollectionViewCell {
    
    static let reuseIdentifier = "NumberTicketCell"
    
    let numberLabel = UILabel()
    private let checkmarkImageView = UIImageView(image: UIImage(named: "TicketDataCell.Checkmark"))
    
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
        
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.isHidden = false // Initially hidden
        
        self.addSubview(numberLabel)
        self.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            numberLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            numberLabel.topAnchor.constraint(equalTo: self.topAnchor),
            numberLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            checkmarkImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: -9.scale),
            checkmarkImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8.scale),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24.scale),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
    }
    
    func configure(with numberOrLabel: String, isLastInSection: Bool, indexPath: IndexPath, isWinningNumbersCollectionView: Bool = false, showCheckmark: Bool = false) {
        numberLabel.text = "\(numberOrLabel)"
        
        // Apply styles based on isLastInSection and indexPath
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
        
        if indexPath.item == 0 && !isWinningNumbersCollectionView {
            numberLabel.layer.borderWidth = 0
            numberLabel.textColor = Appearance.main300
        }
        
        if showCheckmark && !isLastInSection {
            numberLabel.textColor = Appearance.green
        }
        // Show or hide the checkmark based on the configuration
        checkmarkImageView.isHidden = !showCheckmark
    }
}
