//
//  TickedEditCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/13/24.
//


import UIKit

class TicketEditCell: UICollectionViewCell {
    
    var ticket: Ticket?
    private let logoImageView = UIImageView()
    private let dateLabelContainer = UIView()
    private let dateLabel = TickedEditDatePaddedLabel()
    private let pencilEditImageView = UIImageView()
    
    private var datePickerContainer: UIView?
    private let customDatePicker = CustomCalendarView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayoutConstraints()
        addDateLabelTapGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(ticket: Ticket) {
        logoImageView.image = UIImage(named: "placeholderImage")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy" // Custom format for "JUN 2, 2024"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent formatting
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set timezone if needed
        let formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: ticket.date))
        dateLabel.text = formattedDate.uppercased() // Convert to uppercase
        
        pencilEditImageView.image = UIImage(named: "EditTickets.Pencil")
    }
}

private extension TicketEditCell {
    func setupUI() {
        backgroundColor = Appearance.mono100
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        dateLabelContainer.layer.shadowColor = Appearance.dropShadowColor?.cgColor
        dateLabelContainer.layer.shadowOpacity = 0.5
        dateLabelContainer.layer.shadowRadius = 3.scale // Apply scale to shadow radius
        dateLabelContainer.layer.shadowOffset = CGSize(width: 0, height: 2.scale) // Apply scale to shadow offset
        
        dateLabel.font = Fonts.Inter.medium(size: 12.5.scale) // Apply scale to font size
        dateLabel.textAlignment = .center
        dateLabel.textColor = Appearance.main300
        dateLabel.backgroundColor = Appearance.mono100
        dateLabel.layer.cornerRadius = 17.scale  // Apply scale to corner radius
        dateLabel.layer.masksToBounds = true
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        pencilEditImageView.contentMode = .scaleAspectFit
        pencilEditImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(logoImageView)
        addSubview(dateLabelContainer)
        dateLabelContainer.addSubview(dateLabel)
        dateLabelContainer.addSubview(pencilEditImageView)
        
        // Set up custom date picker
        customDatePicker.onDateSelected = { [weak self] selectedDate in
            self?.updateDateLabel(with: selectedDate)
            self?.dismissDatePicker()
        }
        
        customDatePicker.onClose = { [weak self] in
            self?.dismissDatePicker()
        }
    }
    
    func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: -27.scale),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -5.scale), // Apply scale to leading constraint
            logoImageView.widthAnchor.constraint(equalToConstant: 188.scale), // Apply scale to width
            logoImageView.heightAnchor.constraint(equalToConstant: 58.scale), // Apply scale to height
            
            dateLabelContainer.topAnchor.constraint(equalTo: topAnchor, constant: -16.scale), // Apply scale to top constraint
            dateLabelContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25.scale), // Apply scale to trailing constraint
            dateLabelContainer.widthAnchor.constraint(equalToConstant: 122.scale), // Apply scale to width
            dateLabelContainer.heightAnchor.constraint(equalToConstant: 32.scale), // Apply scale to height
            
            dateLabel.leadingAnchor.constraint(equalTo: dateLabelContainer.leadingAnchor, constant: -10.scale), // Snap to left border with -10.scale
            dateLabel.centerYAnchor.constraint(equalTo: dateLabelContainer.centerYAnchor),
            dateLabel.widthAnchor.constraint(equalTo: dateLabelContainer.widthAnchor, constant: 10.scale), // Adjust width to account for the negative leading margin
            dateLabel.heightAnchor.constraint(equalTo: dateLabelContainer.heightAnchor),
            
            pencilEditImageView.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: -33.scale),
            pencilEditImageView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            pencilEditImageView.widthAnchor.constraint(equalToConstant: 24.scale),
            pencilEditImageView.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
    }
    
    func addDateLabelTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateLabelTapped))
        dateLabelContainer.isUserInteractionEnabled = true
        dateLabelContainer.addGestureRecognizer(tapGesture)
    }
    
    @objc func dateLabelTapped() {
        presentDatePicker()
    }
    
    func presentDatePicker() {
        datePickerContainer = UIView(frame: self.superview?.bounds ?? .zero)
        datePickerContainer?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        customDatePicker.translatesAutoresizingMaskIntoConstraints = false
        datePickerContainer?.addSubview(customDatePicker)
        self.superview?.addSubview(datePickerContainer!)
        
        NSLayoutConstraint.activate([
            customDatePicker.centerYAnchor.constraint(equalTo: datePickerContainer!.centerYAnchor, constant: 50.scale),
            customDatePicker.centerXAnchor.constraint(equalTo: datePickerContainer!.centerXAnchor),
            customDatePicker.widthAnchor.constraint(equalTo: datePickerContainer!.widthAnchor, multiplier: 0.8.scale),
            customDatePicker.heightAnchor.constraint(equalToConstant: 485.scale)
        ])
    }
    
    func dismissDatePicker() {
        datePickerContainer?.removeFromSuperview()
        datePickerContainer = nil
    }
    
    func updateDateLabel(with date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let formattedDate = dateFormatter.string(from: date)
        dateLabel.text = formattedDate.uppercased()
    }
}
