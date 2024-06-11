//
//  TicketCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/11/24.
//


import UIKit

class TicketCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TicketCell"
    
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let numbersStackView = UIStackView()
    private let ticketImageView = UIImageView()
    private let editButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Set cell properties
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        // Add and configure ticketImageView
        ticketImageView.translatesAutoresizingMaskIntoConstraints = false
        ticketImageView.contentMode = .scaleAspectFit
        self.addSubview(ticketImageView)
        
        // Add and configure titleLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.addSubview(titleLabel)
        
        // Add and configure dateLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        self.addSubview(dateLabel)
        
        // Add and configure numbersStackView
        numbersStackView.translatesAutoresizingMaskIntoConstraints = false
        numbersStackView.axis = .horizontal
        numbersStackView.distribution = .equalSpacing
        numbersStackView.alignment = .center
        self.addSubview(numbersStackView)
        
        // Add and configure editButton
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle("Edit ticket", for: .normal)
        editButton.backgroundColor = .red
        editButton.layer.cornerRadius = 8
        editButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        editButton.isHidden = true
        self.addSubview(editButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            ticketImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            ticketImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            ticketImageView.widthAnchor.constraint(equalToConstant: 60),
            ticketImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: ticketImageView.leadingAnchor, constant: -10),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: ticketImageView.leadingAnchor, constant: -10),
            
            numbersStackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            numbersStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            numbersStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            
            editButton.topAnchor.constraint(equalTo: numbersStackView.bottomAnchor, constant: 10),
            editButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            editButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            editButton.heightAnchor.constraint(equalToConstant: 40),
            editButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
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
        
        // Clear old views
        numbersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add number labels to stack view
        for numberSet in ticket.numbers {
            for number in numberSet {
                let label = UILabel()
                label.text = "\(number)"
                label.textAlignment = .center
                label.font = UIFont.boldSystemFont(ofSize: 14)
                label.textColor = .black
                label.backgroundColor = .clear
                label.layer.cornerRadius = 12
                label.layer.masksToBounds = true
                label.layer.borderWidth = 1
                label.layer.borderColor = UIColor.lightGray.cgColor
                label.widthAnchor.constraint(equalToConstant: 24).isActive = true
                label.heightAnchor.constraint(equalToConstant: 24).isActive = true
                numbersStackView.addArrangedSubview(label)
            }
        }
        
        // Load ticket image asynchronously
        if let url = ticket.pictureUrl {
            loadImage(from: url)
        } else {
            ticketImageView.image = nil
        }
        
        // Configure cell appearance based on draw date
        if ticketDate > now {
            editButton.isHidden = false
            self.layer.borderColor = UIColor.blue.cgColor
        } else {
            editButton.isHidden = true
            self.layer.borderColor = UIColor.lightGray.cgColor
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
}
