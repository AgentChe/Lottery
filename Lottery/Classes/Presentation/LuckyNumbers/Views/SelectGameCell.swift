//
//  SelectGameCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/26/24.
//

import UIKit


class SelectGameCell: UICollectionViewCell {
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.Inter.regular(size: 14.scale)
        label.textColor = Appearance.main300
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeholderImage")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        layer.cornerRadius = 16.scale
        layer.borderWidth = 1.scale
        layer.borderColor = Appearance.lightGrayBorderTicket.cgColor
        backgroundColor = Appearance.mono100
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(gameImageView)
        
        NSLayoutConstraint.activate([
            // Date label constraints
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dateLabel.widthAnchor.constraint(equalToConstant: 120.scale),
            dateLabel.heightAnchor.constraint(equalToConstant: 24.scale),
            
            // Game image view constraints
            gameImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            gameImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant:  -5.scale),
            gameImageView.widthAnchor.constraint(equalToConstant: 150.scale),
            gameImageView.heightAnchor.constraint(equalToConstant: 45.scale)
        ])
    }
    
    func configure(with date: String, imageName: String) {
        dateLabel.text = date
        gameImageView.image = UIImage(named: imageName)
    }
}
