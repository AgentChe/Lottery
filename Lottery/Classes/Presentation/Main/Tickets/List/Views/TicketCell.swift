//
//  TicketCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/11/24.
//

import UIKit

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
        imageView.image = UIImage(named: "placeholderImage") // Placeholder image
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
        button.setTitle("Edit ticket", for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 22.scale // Rounded corners, half of height
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        return button
    }()
    
    private var numbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 6.scale
        layout.minimumInteritemSpacing = 6.scale
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .yellow
        return collectionView
    }()
    
    private var numbers: [[Int]] = []

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
        
        // Create and apply the custom shape layer as a mask
        let shapeLayer = createCustomShapeLayer()
        self.layer.mask = shapeLayer
        
        // Add the border layer
        let borderLayer = createBorderLayer()
        self.layer.addSublayer(borderLayer)
        
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
    
    private func createCustomShapeLayer() -> CAShapeLayer {
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
    
    private func createBorderLayer() -> CAShapeLayer {
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
            numbersCollectionView.bottomAnchor.constraint(equalTo: editButton.isHidden ?  self.bottomAnchor : editButton.topAnchor, constant: -20.scale),
            
            editButton.topAnchor.constraint(equalTo: numbersCollectionView.bottomAnchor, constant: 20.scale),
            editButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.scale),
            editButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.scale),
            editButton.heightAnchor.constraint(equalToConstant: editButton.isHidden ?  0.scale : 44.scale),
            editButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20.scale),
        ])
    }
    
    func configure(with ticket: Ticket) {
        let now = Date() // Current date as Date object
        let ticketDate = Date(timeIntervalSince1970: ticket.date) // Convert TimeInterval to Date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        // Compare dates and set the title accordingly
        titleLabel.text = ticketDate > now ? "NEXT DRAW" : "PAST DRAW"
        dateLabel.text = formatter.string(from: ticketDate)
        
        // Update numbers array for the collection view
        numbers = ticket.numbers
        numbersCollectionView.reloadData()
        
        // Load ticket image asynchronously
        if let url = ticket.pictureUrl {
            loadImage(from: url)
        } else {
            ticketImageView.image = nil
        }
        
        // Configure cell appearance based on draw date
        if ticketDate > now {
            editButton.isHidden = false
            setNeedsLayout()
        } else {
            editButton.isHidden = true
            setNeedsLayout()
        }
    }
    
    private func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.ticketImageView.image = image
                }
            }
        }
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
