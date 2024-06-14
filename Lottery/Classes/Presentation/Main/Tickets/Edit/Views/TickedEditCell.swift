//
//  TicketEditCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/13/24.
//

import UIKit

class TicketEditCell: UICollectionViewCell {
    
    var ticket: Ticket? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private let logoImageView = UIImageView()
    private let dateLabelContainer = UIView()
    private let dateLabel = TickedEditDatePaddedLabel()
    private let pencilEditImageView = UIImageView()
    
    private var datePickerContainer: UIView?
    private let customDatePicker = CustomCalendarView()
    
    // CollectionView Declaration with Inline Configuration
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 40.scale, height: 40.scale)
        layout.minimumLineSpacing = 10.scale
        layout.minimumInteritemSpacing = 10.scale
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(EditNumberCell.self, forCellWithReuseIdentifier: "EditNumberCell")
        collectionView.register(RemoveCell.self, forCellWithReuseIdentifier: "RemoveCell") // Register RemoveCell
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayoutConstraints()
        addDateLabelTapGesture()
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupLayoutConstraints()
        addDateLabelTapGesture()
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func configure(ticket: Ticket) {
        self.ticket = ticket
        
        logoImageView.image = UIImage(named: "placeholderImage")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: ticket.date))
        dateLabel.text = formattedDate.uppercased()
        
        pencilEditImageView.image = UIImage(named: "EditTickets.Pencil")
        
        collectionView.reloadData()
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
        dateLabelContainer.layer.shadowRadius = 3.scale
        dateLabelContainer.layer.shadowOffset = CGSize(width: 0, height: 2.scale)
        
        dateLabel.font = Fonts.Inter.medium(size: 12.5.scale)
        dateLabel.textAlignment = .center
        dateLabel.textColor = Appearance.main300
        dateLabel.backgroundColor = Appearance.mono100
        dateLabel.layer.cornerRadius = 17.scale
        dateLabel.layer.masksToBounds = true
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        pencilEditImageView.contentMode = .scaleAspectFit
        pencilEditImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(logoImageView)
        addSubview(dateLabelContainer)
        dateLabelContainer.addSubview(dateLabel)
        dateLabelContainer.addSubview(pencilEditImageView)
        addSubview(collectionView)
        
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
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -5.scale),
            logoImageView.widthAnchor.constraint(equalToConstant: 188.scale),
            logoImageView.heightAnchor.constraint(equalToConstant: 58.scale),
            
            dateLabelContainer.topAnchor.constraint(equalTo: topAnchor, constant: -16.scale),
            dateLabelContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25.scale),
            dateLabelContainer.widthAnchor.constraint(equalToConstant: 122.scale),
            dateLabelContainer.heightAnchor.constraint(equalToConstant: 32.scale),
            
            dateLabel.leadingAnchor.constraint(equalTo: dateLabelContainer.leadingAnchor, constant: -10.scale),
            dateLabel.centerYAnchor.constraint(equalTo: dateLabelContainer.centerYAnchor),
            dateLabel.widthAnchor.constraint(equalTo: dateLabelContainer.widthAnchor, constant: 10.scale),
            dateLabel.heightAnchor.constraint(equalTo: dateLabelContainer.heightAnchor),
            
            pencilEditImageView.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: -33.scale),
            pencilEditImageView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            pencilEditImageView.widthAnchor.constraint(equalToConstant: 24.scale),
            pencilEditImageView.heightAnchor.constraint(equalToConstant: 24.scale),
            
            collectionView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10.scale),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.scale),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.scale),
            collectionView.heightAnchor.constraint(equalToConstant: 60.scale)
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

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension TicketEditCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // Assuming all numbers are in one section for horizontal scrolling
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Add 1 to the count to include the RemoveCell
        return (ticket?.numbers.flatMap { $0 }.count ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == (ticket?.numbers.flatMap { $0 }.count ?? 0) {
            // If the index is the last one, return a RemoveCell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RemoveCell", for: indexPath) as? RemoveCell else {
                return UICollectionViewCell()
            }
            cell.layer.cornerRadius = 20.scale
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditNumberCell", for: indexPath) as? EditNumberCell else {
                return UICollectionViewCell()
            }
            
            // Flatten the numbers array and get the appropriate number for this index
            if let numbers = ticket?.numbers.flatMap({ $0 }), indexPath.item < numbers.count {
                let number = numbers[indexPath.item]
                let isLastInRow = indexPath.item == numbers.count - 1 // Check if it's the last item in its row
                cell.configure(number: number, isLastInRow: isLastInRow)
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Check if the selected cell is a RemoveCell
        if indexPath.item == (ticket?.numbers.flatMap { $0 }.count ?? 0) {
            // Handle the removal of the item
            removeItem(at: indexPath)
        } else {
            // Handle selection for EditNumberCell if needed
        }
    }
    
    private func removeItem(at indexPath: IndexPath) {
        // Perform removal logic. For example, you might update the ticket's numbers and reload the data.
        // You would typically update your data model and then call collectionView.reloadData() or perform a batch update
        // Here's a simple example assuming you want to remove the last item from the numbers array
        if var numbers = ticket?.numbers.flatMap({ $0 }) {
            numbers.removeLast()
           // ticket?.numbers = [numbers]
            collectionView.reloadData()
        }
    }
}
