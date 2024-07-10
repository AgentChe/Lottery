//
//  TicketLuckyNumbersEditCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/27/24.
//

import UIKit

class TicketLuckyNumbersEditCell: UICollectionViewCell, RemoveCellDelegate {
    
    var ticket: Ticket?
    var numbersStringArray: [[String]] = [] {
        didSet {
            delegate?.updateSizeOfEditCell(numbersStringArray: numbersStringArray)
        }
    }
    
    weak var delegate: EditTicketViewControllerDelegate?
    weak var parentVC: EditLuckyNumbersViewController?
    private let logoImageView = UIImageView()
    private let dateLabelContainer = UIView()
    private let dateLabel = TickedLuckyNumbersEditDatePaddedLabel()
    private let pencilEditImageView = UIImageView()
    
    private var datePickerContainer: UIView?
    private let customDatePicker = CustomCalendarView()
    
    var logoIamgeLeadingConstraint: NSLayoutConstraint!
    var logoIamgeWidthConstraint: NSLayoutConstraint!
    
    // Plus Button Declaration
    private let plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "TicketLuckyNumbersEditCell.PlusButtonImage".localized), for: .normal)
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
        layout.minimumLineSpacing = 6.scale
        layout.minimumInteritemSpacing = 6.scale
        layout.sectionInset = UIEdgeInsets(top: 6.scale, left: 0.scale, bottom: 0.scale, right: 0.scale)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
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
    
    func configure(ticket: Ticket, game: Game, lotteries: [Lottery]) {
        self.ticket = ticket
        logoImageView.image = UIImage(named: "placeholderImage")
        for lottery in lotteries {
            if lottery.id == game.lotteryId {
                logoImageView.kf.setImage(with: lottery.logoUrl)
                if game.myLuckyNumbers?.count == 0 {
                    if doesURLContain(lottery.logoUrl.absoluteString, word: "2by2") {
                        self.numbersStringArray = [["", "", "", ""]]
                    } else {
                        self.numbersStringArray = [["", "", "", "", "", ""]]
                    }
                    if doesURLContain(lottery.logoUrl.absoluteString, word: "mega") || doesURLContain(lottery.logoUrl.absoluteString, word: "2by2") {
                        logoIamgeLeadingConstraint.isActive = false
                        logoIamgeWidthConstraint.isActive = false
                        logoIamgeLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10.scale)
                        logoIamgeWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 188.scale)
                        logoIamgeLeadingConstraint.isActive = true
                        logoIamgeWidthConstraint.isActive = true
                        setNeedsLayout()
                    }
                    if doesURLContain(lottery.logoUrl.absoluteString, word: "power") || doesURLContain(lottery.logoUrl.absoluteString, word: "lotto") {
                        logoIamgeLeadingConstraint.isActive = false
                        logoIamgeWidthConstraint.isActive = false
                        logoIamgeLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale)
                        logoIamgeWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 160.scale)
                        logoIamgeLeadingConstraint.isActive = true
                        logoIamgeWidthConstraint.isActive = true
                        setNeedsLayout()
                    }
                } else {
                    numbersStringArray = convertIntArrayToStringArray(game.myLuckyNumbers ?? [])
                    if doesURLContain(lottery.logoUrl.absoluteString, word: "mega") || doesURLContain(lottery.logoUrl.absoluteString, word: "2by2") {
                        logoIamgeLeadingConstraint.isActive = false
                        logoIamgeWidthConstraint.isActive = false
                        logoIamgeLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10.scale)
                        logoIamgeWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 188.scale)
                        logoIamgeLeadingConstraint.isActive = true
                        logoIamgeWidthConstraint.isActive = true
                        setNeedsLayout()
                    }
                    if doesURLContain(lottery.logoUrl.absoluteString, word: "power") || doesURLContain(lottery.logoUrl.absoluteString, word: "lotto") {
                        logoIamgeLeadingConstraint.isActive = false
                        logoIamgeWidthConstraint.isActive = false
                        logoIamgeLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale)
                        logoIamgeWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 160.scale)
                        logoIamgeLeadingConstraint.isActive = true
                        logoIamgeWidthConstraint.isActive = true
                        setNeedsLayout()
                    }
                }
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: game.date))
        dateLabel.text = formattedDate.uppercased()
        
        pencilEditImageView.image = UIImage(named: "TicketLuckyNumbersEditCell.PencilImage".localized)
        pencilEditImageView.isHidden = true
        collectionViewHeightConstraint.isActive = false
        
        // Get the number of cells in the last row
        if let firstNumberArray = numbersStringArray.first {
            let numberOfCells = firstNumberArray.count + 1
            // Calculate the available width based on the given constraints
            let totalWidth: CGFloat = 343.scale
            let sideMargins: CGFloat = 40.scale
            let cellSpacing: CGFloat = 3.scale * CGFloat(numberOfCells)
            
            // Calculate the width for each cell
            let availableWidth = totalWidth - sideMargins - cellSpacing
            let cellWidth = availableWidth / CGFloat(numberOfCells)
            collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: CGFloat(numbersStringArray.count) * (cellWidth + 6).scale)
        } else {
            collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: CGFloat(numbersStringArray.count) * (40 + 10 + 10).scale)
        }
        collectionViewHeightConstraint.isActive = true
        collectionView.reloadData()
        setNeedsLayout()
    }
    
    func convertIntArrayToStringArray(_ intArray: [[Int]]) -> [[String]] {
        return intArray.map { $0.map { String($0) } }
    }
}

private extension TicketLuckyNumbersEditCell {
    @objc private func plusButtonTapped() {
        guard var ticket = self.ticket else { return }
    
        let numberOfElementsInLastSection = numbersStringArray.last?.count ?? 5
        let newEmptySection = Array(repeating: "", count: numberOfElementsInLastSection)
    
        numbersStringArray.append(newEmptySection)
        
        self.ticket = ticket

        collectionViewHeightConstraint.isActive = false
        if let firstNumberArray = numbersStringArray.first {
            let numberOfCells = firstNumberArray.count + 1
            // Calculate the available width based on the given constraints
            let totalWidth: CGFloat = 343.scale
            let sideMargins: CGFloat = 40.scale
            let cellSpacing: CGFloat = 3.scale * CGFloat(numberOfCells)
            
            // Calculate the width for each cell
            let availableWidth = totalWidth - sideMargins - cellSpacing
            let cellWidth = availableWidth / CGFloat(numberOfCells)
            collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: CGFloat(numbersStringArray.count) * (cellWidth + 6).scale)
        } else {
            collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: CGFloat(numbersStringArray.count) * (40 + 10).scale)
        }
        collectionViewHeightConstraint.isActive = true

        collectionView.reloadData()
    
        delegate?.updateSizeOfEditCell(numbersStringArray: numbersStringArray)
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
      //  dateLabelContainer.addSubview(pencilEditImageView)
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
        
        logoIamgeLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10.scale)
        logoIamgeWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 188.scale)
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: -27.scale),
            logoIamgeLeadingConstraint,
            logoIamgeWidthConstraint,
            logoImageView.heightAnchor.constraint(equalToConstant: 58.scale),
            
            dateLabelContainer.topAnchor.constraint(equalTo: topAnchor, constant: -16.scale),
            dateLabelContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50.scale),
            dateLabelContainer.widthAnchor.constraint(equalToConstant: 92.scale),
            dateLabelContainer.heightAnchor.constraint(equalToConstant: 32.scale),
            
            dateLabel.centerXAnchor.constraint(equalTo: dateLabelContainer.centerXAnchor, constant: 20.scale),
            dateLabel.centerYAnchor.constraint(equalTo: dateLabelContainer.centerYAnchor),
            dateLabel.widthAnchor.constraint(equalTo: dateLabelContainer.widthAnchor, constant: 10.scale),
            dateLabel.heightAnchor.constraint(equalTo: dateLabelContainer.heightAnchor),
            
            collectionView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10.scale),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.scale),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.scale),
            collectionViewHeightConstraint,
            
            // Set constraints for the Plus Button
            plusButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            plusButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 18.scale),
            plusButton.widthAnchor.constraint(equalToConstant: 50.scale),
            plusButton.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
    }
    
    func addDateLabelTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateLabelTapped))
        dateLabelContainer.isUserInteractionEnabled = true
      //  dateLabelContainer.addGestureRecognizer(tapGesture)
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

extension TicketLuckyNumbersEditCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
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
            cell.indexPath = indexPath
            cell.numberOfCells = numbersStringArray.last?.count
            cell.delegate = self
            if numbersStringArray.count == 1 {
                cell.closeButton.alpha = 0
            }
            
            if numbersStringArray.count > 1  {
                cell.closeButton.alpha = 1
            }
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditNumberCell", for: indexPath) as? EditNumberCell else {
                return UICollectionViewCell()
            }
            
            // Get the appropriate number for this index
            if let numbers = numbersStringArray[safe: indexPath.section] {
                let number = numbers[indexPath.item]
                let isLastInRow = indexPath.item == numbers.count - 1 // Check if it's the last item in its row
                cell.configure(number: number, isLastInRow: isLastInRow, indexPath: indexPath)
                cell.delegate = self // Set the delegate
                cell.numberOfCells = numbersStringArray.last?.count
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if numbersStringArray.count == 1 {
            return UIEdgeInsets(top: 6.scale,
                                left: numbersStringArray[0].count == 6 ? 20.scale : 30.scale, bottom: 0.scale,
                                right:  numbersStringArray[0].count == 6 ? 20.scale : 30.scale)
        } else {
            return UIEdgeInsets(top: 6.scale, left: 0.scale, bottom: 0.scale, right: 0.scale)
        }
    }
    func removeItem(at indexPath: IndexPath) {
        // Check if it's the only row left
        if numbersStringArray.count == 1 && indexPath.section == 0 {
            presentDeleteConfirmationAlert()
        } else {
            // Normal removal process
            numbersStringArray.remove(at: indexPath.section)
            
            collectionViewHeightConstraint.isActive = false
            // Get the number of cells in the last row
            if let firstNumberArray = numbersStringArray.first {
                let numberOfCells = firstNumberArray.count + 1
                // Calculate the available width based on the given constraints
                let totalWidth: CGFloat = 343.scale
                let sideMargins: CGFloat = 40.scale
                let cellSpacing: CGFloat = 3.scale * CGFloat(numberOfCells)
                
                // Calculate the width for each cell
                let availableWidth = totalWidth - sideMargins - cellSpacing
                let cellWidth = availableWidth / CGFloat(numberOfCells)
                collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: CGFloat(numbersStringArray.count) * (cellWidth + 6).scale)
            } else {
                collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: CGFloat(numbersStringArray.count) * (40 + 10).scale)
            }
            collectionViewHeightConstraint.isActive = true
            
            collectionView.reloadData()
        }
    }
    
    private func presentDeleteConfirmationAlert() {
        let alertVC = LuckyNumbersAlertViewController()
        
        alertVC.onConfirmDelete = { [weak self] in
            guard let self = self else { return }
            // Code to remove the ticket here
            self.parentVC?.numbersStringArray = []
            self.parentVC?.removeTicketButtonTapped()
        }
        
        alertVC.onCancel = {
            // Code to handle cancellation (if any)
        }
        
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        
        if let parentVC = self.parentViewController {
            parentVC.present(alertVC, animated: true, completion: nil)
        }
    }
    
    private func removeTicket() {
        numbersStringArray.removeAll()
        collectionView.reloadData()
    }
    
    // Implementing sizeForItemAt to dynamically set item size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Default size for the cell
        let defaultSize = CGSize(width: 40.scale, height: 40.scale)

        // Check if there are numbers in the numbersStringArray
        guard let lastRow = numbersStringArray.last else {
            // Return default size if numbersStringArray is empty or nil
            return defaultSize
        }
        
        // Get the number of cells in the last row
        let numberOfCells = lastRow.count + 1
        
        // Calculate the available width based on the given constraints
        let totalWidth: CGFloat = 343.scale
        let sideMargins: CGFloat = 40.scale
        let cellSpacing: CGFloat = 3.scale * CGFloat(numberOfCells)
        
        // Calculate the width for each cell
        let availableWidth = totalWidth - sideMargins - cellSpacing
        let cellWidth = availableWidth / CGFloat(numberOfCells)
        
        // Return the size for the cell
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

extension TicketLuckyNumbersEditCell: EditNumberCellDelegate {
    func numberCell(_ cell: EditNumberCell, didUpdateNumber number: String, at indexPath: IndexPath) {
           guard indexPath.section < numbersStringArray.count,
                 indexPath.item < numbersStringArray[indexPath.section].count else { return }
           
           // Update the number in the array if it contains exactly two digits
           if number.count == 2 {
               numbersStringArray[indexPath.section][indexPath.item] = number
               
               // Find the next index path
               var nextItem = indexPath.item + 1
               var nextSection = indexPath.section
               
               if nextItem >= numbersStringArray[indexPath.section].count {
                   // Move to the next section if available
                   nextItem = 0
                   nextSection += 1
               }
               
               // Check if the next section exists
               if nextSection < numbersStringArray.count {
                   let nextIndexPath = IndexPath(item: nextItem, section: nextSection)
                   
                   // Scroll to the next cell and make its text field the first responder
                   collectionView.scrollToItem(at: nextIndexPath, at: .centeredVertically, animated: true)
                   
                   // Select the next cell
                   collectionView.selectItem(at: nextIndexPath, animated: true, scrollPosition: [])
                   
                   // Get the next cell and make its text field the first responder
                   DispatchQueue.main.async {
                       if let nextCell = self.collectionView.cellForItem(at: nextIndexPath) as? EditNumberCell {
                           nextCell.numberTextField.becomeFirstResponder()
                       }
                   }
               }
           } else {
               // Update the number in the array without moving to the next cell
               numbersStringArray[indexPath.section][indexPath.item] = number
           }
       }
       
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           if indexPath.item < (numbersStringArray[safe: indexPath.section]?.count ?? 0) {
               if let cell = collectionView.cellForItem(at: indexPath) as? EditNumberCell {
                   cell.numberTextField.becomeFirstResponder()
               }
           }
       }
    func doesURLContain(_ urlString: String, word: String) -> Bool {
        return urlString.lowercased().contains(word)
    }
}
