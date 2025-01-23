//
//  ScratchOffCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 9/6/24.
//

import UIKit

class ScratchOffCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ScratchOffCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.Inter.medium(size: 14.scale)
        label.textColor = Appearance.mono200
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.Inter.medium(size: 14.scale)
        label.textColor = Appearance.lightGrayTextColor
        return label
    }()
    
    private let ticketImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = Appearance.mono100
        imageView.image = UIImage(named: "") // Placeholder image
        return imageView
    }()
    
    private let dashedLineImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "PastDraws.DashedLine")
        return imageView
    }()
    
    // New UIImageView
    private let scrstchTicketImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "someImageName") // Placeholder image
        imageView.layer.cornerRadius = 15.scale
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private var editButtonHeightConstraint: NSLayoutConstraint!
    private var numbersCollectionViewBottomConstraint: NSLayoutConstraint!
    private var numbersCollectionViewBottomToEditButtonConstraint: NSLayoutConstraint!
    private var editButtonBottomConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Set cell properties
        self.backgroundColor = .white

        // Add subviews
        self.addSubview(ticketImageView)
        self.addSubview(titleLabel)
        self.addSubview(dateLabel)
        self.addSubview(dashedLineImageView)
        self.addSubview(scrstchTicketImageView) // Add new UIImageView
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            ticketImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 26.scale),
            ticketImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.scale),
            ticketImageView.widthAnchor.constraint(equalToConstant: 24.scale),
            ticketImageView.heightAnchor.constraint(equalToConstant: 24.scale),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 23.scale),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            titleLabel.trailingAnchor.constraint(equalTo: ticketImageView.leadingAnchor, constant: -10.scale),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5.scale),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: ticketImageView.leadingAnchor, constant: -10.scale),
            
            dashedLineImageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 35.scale),
            dashedLineImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dashedLineImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            dashedLineImageView.heightAnchor.constraint(equalToConstant: 1.scale),
            
            // Constraints for the new UIImageView
            scrstchTicketImageView.topAnchor.constraint(equalTo: dashedLineImageView.bottomAnchor, constant: 10.scale),
            scrstchTicketImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.scale),
            scrstchTicketImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.scale),
            scrstchTicketImageView.widthAnchor.constraint(equalToConstant: 303.scale), // Width of 303.scale
            scrstchTicketImageView.heightAnchor.constraint(equalToConstant: 166.scale), // Height of 166.scale
        ])
    }
    
    func configure(with ticket: ScratchOff) {
        if let date = ticket.date {// Current date as Date object}
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy" // Custom format for "JUN 2, 2024"
            formatter.timeZone = TimeZone(abbreviation: "GMT")
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            // Format and set the date label
            let formattedDate = formatter.string(from: date)
            dateLabel.text = formattedDate.uppercased()
        }
        
        // Compare dates and set the title accordingly
        titleLabel.text = "ANALYSIS RESULT"
        
        // Load ticket image asynchronously
        let imageURLString = ticket.imageUrl
        if let url = URL(string: imageURLString) {
            self.scrstchTicketImageView.kf.setImage(with: url)
        }
       
        if let image = UIImage(named: "chevronRight") {
            ticketImageView.image = image
        }
        setNeedsLayout()
              
        let shapeLayer = self.createCustomShapeLayer()
        self.layer.mask = shapeLayer
        
        // Add the border layer
        let borderLayer = self.createBorderLayer()
        
        if let subLayers = self.layer.sublayers {
            for subLayer in subLayers {
                if subLayer.isKind(of: CAShapeLayer.self) {
                    subLayer.removeFromSuperlayer()
                }
            }
        }
        self.layer.addSublayer(borderLayer)
    }
}


extension ScratchOffCell {
    func createCustomShapeLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        // Create a Bezier path resembling the ticket shape with 32.scale circular cutouts
        let path = UIBezierPath()
        
        // Define the shape based on the cell's bounds
        let bounds = self.bounds
        let cornerRadius: CGFloat = 20.scale // Radius for the corners
        let cutoutRadius: CGFloat = 16.scale // Radius for 32.scale diameter cutouts
        
        // Start at the top-left corner
        path.move(to: CGPoint(x: bounds.minX + cornerRadius, y: bounds.minY))
        
        // Top edge
        path.addLine(to: CGPoint(x: bounds.maxX - cornerRadius, y: bounds.minY))
        path.addArc(withCenter: CGPoint(x: bounds.maxX - cornerRadius, y: bounds.minY + cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi * 2, clockwise: true)
        
        // Right edge with inward arc (cutout)
        path.addLine(to: CGPoint(x: bounds.maxX, y: 100.scale - cutoutRadius))
        path.addArc(withCenter: CGPoint(x: bounds.maxX, y: 100.scale), radius: cutoutRadius, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi / 2, clockwise: false)
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - cornerRadius))
        path.addArc(withCenter: CGPoint(x: bounds.maxX - cornerRadius, y: bounds.maxY - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
        
        // Bottom edge
        path.addLine(to: CGPoint(x: bounds.minX + cornerRadius, y: bounds.maxY))
        path.addArc(withCenter: CGPoint(x: bounds.minX + cornerRadius, y: bounds.maxY - cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: true)
        
        // Left edge with inward arc (cutout)
        path.addLine(to: CGPoint(x: bounds.minX, y: 100.scale + cutoutRadius))
        path.addArc(withCenter: CGPoint(x: bounds.minX, y: 100.scale), radius: cutoutRadius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi * 1.5, clockwise: false)
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY + cornerRadius))
        path.addArc(withCenter: CGPoint(x: bounds.minX + cornerRadius, y: bounds.minY + cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 1.5, clockwise: true)
        
        // Close the path
        path.close()
        
        // Assign the path to the layer
        layer.path = path.cgPath
        layer.fillColor = UIColor.white.cgColor
        
        return layer
    }
    
    func createBorderLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        // Use the same path as the custom shape layer
        let path = UIBezierPath()
        
        // Define the shape based on the cell's bounds
        let bounds = self.bounds
        let cornerRadius: CGFloat = 20.scale // Radius for the corners
        let cutoutRadius: CGFloat = 16.scale // Radius of each circular cutout (50x50, hence radius is 25)
        
        // Start at the top-left corner
        path.move(to: CGPoint(x: bounds.minX + cornerRadius, y: bounds.minY))
        
        // Top edge
        path.addLine(to: CGPoint(x: bounds.maxX - cornerRadius, y: bounds.minY))
        path.addArc(withCenter: CGPoint(x: bounds.maxX - cornerRadius, y: bounds.minY + cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi * 2, clockwise: true)
        
        // Right edge with inward arc (cutout)
        path.addLine(to: CGPoint(x: bounds.maxX, y: 100.scale - cutoutRadius))
        path.addArc(withCenter: CGPoint(x: bounds.maxX, y: 100.scale), radius: cutoutRadius, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi / 2, clockwise: false)
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - cornerRadius))
        path.addArc(withCenter: CGPoint(x: bounds.maxX - cornerRadius, y: bounds.maxY - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
        
        // Bottom edge
        path.addLine(to: CGPoint(x: bounds.minX + cornerRadius, y: bounds.maxY))
        path.addArc(withCenter: CGPoint(x: bounds.minX + cornerRadius, y: bounds.maxY - cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: true)
        
        // Left edge with inward arc (cutout)
        path.addLine(to: CGPoint(x: bounds.minX, y: 100.scale + cutoutRadius))
        path.addArc(withCenter: CGPoint(x: bounds.minX, y: 100.scale), radius: cutoutRadius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi * 1.5, clockwise: false)
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY + cornerRadius))
        path.addArc(withCenter: CGPoint(x: bounds.minX + cornerRadius, y: bounds.minY + cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 1.5, clockwise: true)
        
        // Close the path
        path.close()
        
        // Assign the path to the layer
        layer.path = path.cgPath
        layer.strokeColor = Appearance.lightGrayBorderTicket.cgColor // Customize the border color
        layer.lineWidth = 2.0 // Customize the border width
        layer.fillColor = UIColor.clear.cgColor // Ensure the fill color is clear
        
        return layer
    }
}
