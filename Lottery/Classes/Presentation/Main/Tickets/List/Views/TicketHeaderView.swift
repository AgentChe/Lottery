//
//  TicketHeaderView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 10/24/24.
//

import UIKit

class TicketHeaderView: UICollectionReusableView {
    
    static let identifier = "TicketHeaderView"
    
    // ImageView for the separator
    private let dashedLineImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "FullTicket.Spearator") // Assuming the image is in assets
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        backgroundColor = .clear//.systemCyan
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(dashedLineImageView)
        
        // Set constraints for the dashed line image view
        NSLayoutConstraint.activate([
            dashedLineImageView.topAnchor.constraint(equalTo: topAnchor, constant: 0.scale),
            dashedLineImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dashedLineImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dashedLineImageView.heightAnchor.constraint(equalToConstant: 1.scale) // Full width, height of 1.scale
        ])
    }
}
