//
//  DateCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/14/24.
//

import UIKit

class BorderedCollectionView: UICollectionView {
    private let borderColor = Appearance.main500 // Color of the border
    private let borderWidth: CGFloat = 1.0 // Width of the border line

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Remove any existing border layers to avoid duplication
        layer.sublayers?.filter { $0.name == "borderLayer" }.forEach { $0.removeFromSuperlayer() }
        
        // Add left border
        let leftBorderLayer = CALayer()
        leftBorderLayer.backgroundColor = borderColor.cgColor
        leftBorderLayer.frame = CGRect(x: 0, y: 0, width: borderWidth, height: bounds.height)
        leftBorderLayer.name = "borderLayer"
        layer.addSublayer(leftBorderLayer)
        
        // Add top border
        let topBorderLayer = CALayer()
        topBorderLayer.backgroundColor = borderColor.cgColor
        topBorderLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: borderWidth)
        topBorderLayer.name = "borderLayer"
        layer.addSublayer(topBorderLayer)
    }
}




class DateCell: UICollectionViewCell {
    let dateLabel = UILabel()
    private let borderLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
         
        setupDateLabel()
        setupBorders()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupDateLabel() {
        dateLabel.font = Fonts.Inter.regular(size: 16)
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setupBorders() {
        borderLayer.strokeColor = Appearance.main500.cgColor // Color of the border
        borderLayer.lineWidth = 1.0 // Width of the border line
        borderLayer.fillColor = nil
        contentView.layer.addSublayer(borderLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create the path for the right and bottom borders
        let path = UIBezierPath()
        
        // Right border
        path.move(to: CGPoint(x: contentView.bounds.width - 1, y: 0))
        path.addLine(to: CGPoint(x: contentView.bounds.width - 1, y: contentView.bounds.height))
        
        // Bottom border
        path.move(to: CGPoint(x: 0, y: contentView.bounds.height - 1))
        path.addLine(to: CGPoint(x: contentView.bounds.width, y: contentView.bounds.height - 1))
        
        borderLayer.path = path.cgPath
    }
}

