
//
//  TicketEditCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/13/24.
//

import UIKit

class TicketEditCell: UICollectionViewCell {

    var ticket: Ticket?
    var numbersStringArray: [[String]] = [] {
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
    
    // Plus Button Declaration
    private let plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "EditTickets.PlusButtonImage"), for: .normal) // Replace with your image asset name
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25.scale // Half the height and width for a circular button
        button.layer.masksToBounds = true
        button.backgroundColor = .blue
        return button
    }()
    
    // CollectionView Declaration with Inline Configuration
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12.scale
        layout.minimumInteritemSpacing = 12.scale
        layout.sectionInset = UIEdgeInsets(top: 10.scale, left: 10.scale, bottom: 0.scale, right: 10.scale)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .red
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(EditNumberCell.self, forCellWithReuseIdentifier: "EditNumberCell")
        collectionView.register(RemoveCell.self, forCellWithReuseIdentifier: "RemoveCell") // Register RemoveCell
        
        return collectionView
    }()
    var collectionViewHeightConstraint: NSLayoutConstraint!
    
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
        numbersStringArray = ticket.numbers.map { $0.map { "\($0)" } }
        
        logoImageView.image = UIImage(named: "placeholderImage")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: ticket.date))
        dateLabel.text = formattedDate.uppercased()
        
        pencilEditImageView.image = UIImage(named: "EditTickets.Pencil")
        collectionViewHeightConstraint.isActive = false
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: CGFloat(numbersStringArray.count) * (40 + 10 + 10).scale)
        collectionViewHeightConstraint.isActive = true
        collectionView.reloadData()
    }
}

private extension TicketEditCell {
    @objc private func plusButtonTapped() {
        guard var ticket = self.ticket else { return }
        
        // Add a new empty section (or initialize with default values)
        numbersStringArray.append(["", "", "", "", ""]) // Appending an empty section for demonstration
        
        // Update the cell's ticket property and UI
        self.ticket = ticket
        collectionViewHeightConstraint.isActive = false
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: CGFloat(numbersStringArray.count) * (40 + 10).scale)
        collectionViewHeightConstraint.isActive = true
        
        collectionView.reloadData()
    }

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
        addSubview(plusButton) // Add Plus Button to the view hierarchy
        
        customDatePicker.onDateSelected = { [weak self] selectedDate in
            self?.updateDateLabel(with: selectedDate)
            self?.dismissDatePicker()
        }
        
        customDatePicker.onClose = { [weak self] in
            self?.dismissDatePicker()
        }
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    func setupLayoutConstraints() {
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: CGFloat((ticket?.numbers.count ?? 0)) * (40 + 10 + 10).scale)
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
            collectionViewHeightConstraint,
            
            // Set constraints for the Plus Button
            plusButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            plusButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 15.scale),
            plusButton.widthAnchor.constraint(equalToConstant: 50.scale),
            plusButton.heightAnchor.constraint(equalToConstant: 50.scale)
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
        print("@ numbersStringArray.count: \(numbersStringArray.count)")
        return numbersStringArray.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Add 1 to the count to include the RemoveCell
        if let numbersCount = numbersStringArray[safe: section]?.count {
            return numbersCount + 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == (numbersStringArray[safe: indexPath.section]?.count ?? 0) {
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
            
            // Get the appropriate number for this index
            if let numbers = numbersStringArray[safe: indexPath.section] {
                let number = numbers[indexPath.item]
                let isLastInRow = indexPath.item == numbers.count - 1 // Check if it's the last item in its row
                cell.configure(number: number, isLastInRow: isLastInRow)
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Check if the selected cell is a RemoveCell
        if indexPath.item == (numbersStringArray[safe: indexPath.section]?.count ?? 0) {
            // Handle the removal of the item
            removeItem(at: indexPath)
        } else {
            // Handle selection for EditNumberCell if needed
        }
    }
    
    private func removeItem(at indexPath: IndexPath) {
        // Perform removal logic. For example, you might update the numbersStringArray and reload the data.
        if var numbers = numbersStringArray[safe: indexPath.section] {
            numbers.removeLast()
            numbersStringArray[indexPath.section] = numbers
            collectionView.reloadData()
        }
    }
    
    // Implementing sizeForItemAt to dynamically set item size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == (numbersStringArray[safe: indexPath.section]?.count ?? 0) {
            // Size for the RemoveCell
            return CGSize(width: 40.scale, height: 40.scale) // Example size, adjust as needed
        } else {
            // Size for the EditNumberCell
            return CGSize(width: 40.scale, height: 40.scale) // Example size, adjust as needed
        }
    }
}
