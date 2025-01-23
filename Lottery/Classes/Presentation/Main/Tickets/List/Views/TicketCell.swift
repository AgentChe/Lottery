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
    func viewAllButtonTapped(for cell: TicketCell, ticket: Ticket, bonusIdx: [Int], completion: (() -> Void)?)
}

class TicketCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,TicketNumbersRowCellDelegate {
    var lotteries: [Lottery] = []
    var ticket: Ticket?
    var bonusIdx: [Int] = [] {
        didSet {
            for i in 0..<bonusIdx.count {
                bonusIdx[i] = bonusIdx[i] + 1
            }
        }
    }
     
    func ticketNumbersRowCell(_ cell: TicketNumbersRowCollectionViewCell, didScroll contentOffset: CGPoint) {
        // Iterate over the visible cells in numbersCollectionView
        for visibleCell in numbersCollectionView.visibleCells {
            if let rowCell = visibleCell as? TicketNumbersRowCollectionViewCell, rowCell != cell {
                rowCell.ticketNumbersCollectionView.contentOffset = contentOffset
            }
        }
    }
    
    static let reuseIdentifier = "TicketCell"
    weak var delegate: TicketCellDelegate?
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.Inter.medium(size: 12.scale)
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
    
    private let viewAllButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("TicketCell.ViewAll".localized, for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 22.scale // Rounded corners, half of height
        button.addTarget(self, action: #selector(viewAllButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        return button
    }()
    
    var numbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12.scale
        layout.minimumInteritemSpacing = 12.scale
        
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
    
    @objc  func viewAllButtonTapped() {
        //delegate?.editButtonTapped(for: self)
        if let ticket = ticket {
            delegate?.viewAllButtonTapped(for: self, ticket: ticket, bonusIdx: bonusIdx, completion: nil)
        }
        
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
        numbersCollectionView.register(TicketNumbersRowCollectionViewCell.self, forCellWithReuseIdentifier: TicketNumbersRowCollectionViewCell.reuseIdentifier)
        
        // Add subviews
        self.addSubview(ticketImageView)
        self.addSubview(dateLabel)
        self.addSubview(numbersCollectionView)
        self.addSubview(dashedLineImageView) // Add dashed line image view
        self.addSubview(viewAllButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            ticketImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 26.scale),
            ticketImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.scale),
            ticketImageView.widthAnchor.constraint(equalToConstant: 150.scale),
            ticketImageView.heightAnchor.constraint(equalToConstant: 50.scale),
            
            dateLabel.topAnchor.constraint(equalTo: ticketImageView.bottomAnchor, constant: 10.scale),
            dateLabel.leadingAnchor.constraint(equalTo: ticketImageView.leadingAnchor, constant: 13.scale),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            
            dashedLineImageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 26.scale),
            dashedLineImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dashedLineImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            dashedLineImageView.heightAnchor.constraint(equalToConstant: 1.scale),
            
            numbersCollectionView.topAnchor.constraint(equalTo: dashedLineImageView.bottomAnchor, constant: 20.scale),
            numbersCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.scale),
            numbersCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.scale),
        ])
        
        editButtonHeightConstraint = viewAllButton.heightAnchor.constraint(equalToConstant: 44.scale)
        editButtonHeightConstraint.isActive = true
        
        numbersCollectionViewBottomConstraint = numbersCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20.scale)
        numbersCollectionViewBottomToEditButtonConstraint = numbersCollectionView.bottomAnchor.constraint(equalTo: viewAllButton.topAnchor, constant: -20.scale)
        
        editButtonBottomConstraint = viewAllButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20.scale)
        
        NSLayoutConstraint.activate([
            viewAllButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.scale),
            viewAllButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.scale),
        ])
    }
    
    func configure(with ticket: Ticket) {
        
        let ticketDate = Date(timeIntervalSince1970: ticket.date) // Convert TimeInterval to Date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy" // Custom format for "JUN 2, 2024"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT") // Set to GMT (UTC)
        formatter.dateStyle = .medium
        
        dateLabel.text = formatter.string(from: ticketDate).uppercased()
        
        // Update numbers array for the collection view
        numbers = ticket.numbers
        numbersCollectionView.reloadData()
        
        // Load ticket image asynchronously
        var lotteryLogoUrlString = lotteries.filter { $0.id == ticket.lotteryId }.first?.logoUrl
        if let url = lotteryLogoUrlString {
            self.ticketImageView.kf.setImage(with: url)
        } else {
            ticketImageView.image = nil
        }
        
        // Configure cell appearance based on draw date
        
        viewAllButton.isHidden = false
        editButtonHeightConstraint.constant = 44.scale
        editButtonBottomConstraint.isActive = true
        numbersCollectionViewBottomToEditButtonConstraint.isActive = true
        numbersCollectionViewBottomConstraint.isActive = false
        
        
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
        return numbers != [] ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TicketNumbersRowCollectionViewCell.reuseIdentifier, for: indexPath) as? TicketNumbersRowCollectionViewCell else {
            fatalError("Could not dequeue cell with identifier: TicketNumbersRowCollectionViewCell")
        }
        cell.bonusIdx = bonusIdx
        cell.indexPath = indexPath
        cell.ticketNumbers = numbers
        cell.section = indexPath.item
        cell.delegate = self
        
        cell.config()
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewWidth = frame.width
        return CGSize(width: viewWidth , height: 40.scale)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 15.scale, left: 0.scale, bottom: 0.scale, right: 0.scale)
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
        
        let upperSizeHeight: CGFloat = 128.scale
        
        // Top edge
        path.addLine(to: CGPoint(x: bounds.maxX - cornerRadius, y: bounds.minY))
        path.addArc(withCenter: CGPoint(x: bounds.maxX - cornerRadius, y: bounds.minY + cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi * 2, clockwise: true)
        
        // Right edge with inward arc (cutout)
        path.addLine(to: CGPoint(x: bounds.maxX, y: upperSizeHeight - cutoutRadius))
        path.addArc(withCenter: CGPoint(x: bounds.maxX, y: upperSizeHeight), radius: cutoutRadius, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi / 2, clockwise: false)
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - cornerRadius))
        path.addArc(withCenter: CGPoint(x: bounds.maxX - cornerRadius, y: bounds.maxY - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
        
        // Bottom edge
        path.addLine(to: CGPoint(x: bounds.minX + cornerRadius, y: bounds.maxY))
        path.addArc(withCenter: CGPoint(x: bounds.minX + cornerRadius, y: bounds.maxY - cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: true)
        
        // Left edge with inward arc (cutout)
        path.addLine(to: CGPoint(x: bounds.minX, y: upperSizeHeight + cutoutRadius))
        path.addArc(withCenter: CGPoint(x: bounds.minX, y: upperSizeHeight), radius: cutoutRadius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi * 1.5, clockwise: false)
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
        
        let upperSizeHeight: CGFloat = 128.scale
        
        // Start at the top-left corner
        path.move(to: CGPoint(x: bounds.minX + cornerRadius, y: bounds.minY))
        
        // Top edge
        path.addLine(to: CGPoint(x: bounds.maxX - cornerRadius, y: bounds.minY))
        path.addArc(withCenter: CGPoint(x: bounds.maxX - cornerRadius, y: bounds.minY + cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi * 2, clockwise: true)
        
        // Right edge with inward arc (cutout)
        path.addLine(to: CGPoint(x: bounds.maxX, y: upperSizeHeight - cutoutRadius))
        path.addArc(withCenter: CGPoint(x: bounds.maxX, y: upperSizeHeight), radius: cutoutRadius, startAngle: CGFloat.pi * 1.5, endAngle: CGFloat.pi / 2, clockwise: false)
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - cornerRadius))
        path.addArc(withCenter: CGPoint(x: bounds.maxX - cornerRadius, y: bounds.maxY - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
        
        // Bottom edge
        path.addLine(to: CGPoint(x: bounds.minX + cornerRadius, y: bounds.maxY))
        path.addArc(withCenter: CGPoint(x: bounds.minX + cornerRadius, y: bounds.maxY - cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: true)
        
        // Left edge with inward arc (cutout)
        path.addLine(to: CGPoint(x: bounds.minX, y: upperSizeHeight + cutoutRadius))
        path.addArc(withCenter: CGPoint(x: bounds.minX, y: upperSizeHeight), radius: cutoutRadius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi * 1.5, clockwise: false)
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
