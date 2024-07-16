//
//  TicketCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/11/24.
//

import UIKit
import Kingfisher

protocol TicketCellDelegate: AnyObject {
    func editButtonTapped(for cell: TicketCell)
}

class TicketCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    static let reuseIdentifier = "TicketCell"
    weak var delegate: TicketCellDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.Inter.bold(size: 14.scale)
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
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("TicketCell.EditTicket".localized, for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 22.scale // Rounded corners, half of height
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        return button
    }()
    
    var numbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 6.scale
        layout.minimumInteritemSpacing = 6.scale
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private var numbers: [[Int]] = []

    private var editButtonHeightConstraint: NSLayoutConstraint!
    private var numbersCollectionViewBottomConstraint: NSLayoutConstraint!
    private var numbersCollectionViewBottomToEditButtonConstraint: NSLayoutConstraint!
    private var editButtonBottomConstraint: NSLayoutConstraint!

    @objc private func editButtonTapped() {
        delegate?.editButtonTapped(for: self)
    }

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
        
        // Configure collection view data source and delegate
        numbersCollectionView.dataSource = self
        numbersCollectionView.delegate = self
        numbersCollectionView.register(NumberTicketCell.self, forCellWithReuseIdentifier: NumberTicketCell.reuseIdentifier)
        
        // Add subviews
        self.addSubview(ticketImageView)
        self.addSubview(titleLabel)
        self.addSubview(dateLabel)
        self.addSubview(numbersCollectionView)
        self.addSubview(dashedLineImageView) // Add dashed line image view
        self.addSubview(editButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            ticketImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.scale),
            ticketImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.scale),
            ticketImageView.widthAnchor.constraint(equalToConstant: 150.scale),
            ticketImageView.heightAnchor.constraint(equalToConstant: 50.scale),
            
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
            
            numbersCollectionView.topAnchor.constraint(equalTo: dashedLineImageView.bottomAnchor, constant: 20.scale),
            numbersCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.scale),
            numbersCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.scale),
        ])
        
        editButtonHeightConstraint = editButton.heightAnchor.constraint(equalToConstant: 44.scale)
        editButtonHeightConstraint.isActive = true
        
        numbersCollectionViewBottomConstraint = numbersCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20.scale)
        numbersCollectionViewBottomToEditButtonConstraint = numbersCollectionView.bottomAnchor.constraint(equalTo: editButton.topAnchor, constant: -20.scale)
        
        editButtonBottomConstraint = editButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20.scale)
        
        NSLayoutConstraint.activate([
            editButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.scale),
            editButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.scale),
        ])
    }
    
    func configure(with ticket: Ticket) {
        let now = Date() // Current date as Date object
        let ticketDate = Date(timeIntervalSince1970: ticket.date) // Convert TimeInterval to Date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy" // Custom format for "JUN 2, 2024"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateStyle = .medium
        
        // Compare dates and set the title accordingly
        titleLabel.text = ticketDate > now ? "TicketCell.NextDraw".localized : "TicketCell.PastDraw".localized
        dateLabel.text = formatter.string(from: ticketDate)
        
        // Update numbers array for the collection view
        numbers = ticket.numbers
        numbersCollectionView.reloadData()
        
        // Load ticket image asynchronously
        if let url = ticket.pictureUrl {
            self.ticketImageView.kf.setImage(with: url)
        } else {
            ticketImageView.image = nil
        }
        
        // Configure cell appearance based on draw date
        if ticketDate > now {
            editButton.isHidden = false
            editButtonHeightConstraint.constant = 44.scale
            editButtonBottomConstraint.isActive = true
            numbersCollectionViewBottomToEditButtonConstraint.isActive = true
            numbersCollectionViewBottomConstraint.isActive = false
        } else {
            editButton.isHidden = true
            editButtonHeightConstraint.constant = 0.scale
            editButtonBottomConstraint.isActive = false
            numbersCollectionViewBottomConstraint.isActive = true
            numbersCollectionViewBottomToEditButtonConstraint.isActive = false
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
    
    // MARK: - UICollectionViewDataSource Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumberTicketCell.reuseIdentifier, for: indexPath) as! NumberTicketCell
        let number = numbers[indexPath.section][indexPath.item]
        
        // Determine if this is the last item in the section
        let isLastItemInSection = indexPath.item == numbers[indexPath.section].count - 1
        cell.configure(with: number, isLastInSection: isLastItemInSection)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Size each number cell
        return CGSize(width: 40.scale, height: 40.scale)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let itemCount = numbers[section].count
        let totalCellWidth = CGFloat(40 * itemCount).scale
        let totalSpacingWidth = CGFloat(10 * (itemCount - 1)).scale
        
        let totalWidth = totalCellWidth + totalSpacingWidth
        let inset: CGFloat
        
        if totalWidth < collectionView.bounds.width {
            inset = ((collectionView.bounds.width - totalWidth) / 2).scale
        } else {
            inset = 0.scale
        }
        
        return UIEdgeInsets(top: 15.scale, left: inset, bottom: 0.scale, right: inset)
    }
}

extension TicketCell {
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
