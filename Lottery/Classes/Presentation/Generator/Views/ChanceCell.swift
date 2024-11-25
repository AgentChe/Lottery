//
//  ChanceCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 11/3/24.
//

import UIKit

class ChanceCell: UICollectionViewCell {
    static let reusableIdentifier: String = "ChanceCell"
   
    let chanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.numberOfLines = 10
        label.font = Fonts.Inter.regular(size: 14.scale)
        label.textColor = Appearance.mono200
        label.backgroundColor = .clear
        return label
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Appearance.chanceLabelColor
        layer.cornerRadius = 16.scale
        setupSubviews()
        setupConstraints()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupSubviews() {
          addSubview(chanceLabel)
      }
      
      private func setupConstraints() {
          NSLayoutConstraint.activate([
              chanceLabel.widthAnchor.constraint(equalToConstant: 311.scale),
              chanceLabel.heightAnchor.constraint(equalToConstant: 41.scale),
              chanceLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1.scale),
              chanceLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
          ])
      }
}
