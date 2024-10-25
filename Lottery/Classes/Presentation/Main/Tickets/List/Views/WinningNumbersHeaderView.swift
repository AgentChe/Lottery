//
//  WinningNumbersHeaderView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 10/24/24.
//

import UIKit

class WinningNumbersHeaderView: UICollectionReusableView {
    
    static let identifier = "WinningNumbersHeaderView"
    
    // ImageView for the dashed line
    private let dashedLineImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "FullTicket.Spearator")
        return imageView
    }()
    
    // Label for the new title
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.Inter.medium(size: 14.scale) // Assuming custom font "Inter"
        label.textColor = Appearance.main300
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "WINNING NUMBERS"  // New title
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        backgroundColor = .systemPink
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(dashedLineImageView)
        addSubview(titleLabel)
        
        // Set constraints for the imageView
        NSLayoutConstraint.activate([
            dashedLineImageView.topAnchor.constraint(equalTo: topAnchor),
            dashedLineImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dashedLineImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dashedLineImageView.heightAnchor.constraint(equalToConstant: 1.scale) // Full width, height of 1.scale
        ])
        
        // Set constraints for the title label
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: dashedLineImageView.bottomAnchor, constant: 16.scale),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale)
        ])
    }
}
