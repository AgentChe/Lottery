//
//  TicketLuckyNumbersEditCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/27/24.
//

import UIKit

class TicketLuckyNumbersEditCell: UICollectionViewCell, RemoveCellDelegate {
    var lotteries: [Lottery] = []
    var lotteryPatterns : [LotteryPattern] = []
    var bonusIdx: [Int] = [] {
        didSet {
            for i in 0..<bonusIdx.count {
                bonusIdx[i] = bonusIdx[i] + 1
            }
        }
    }
    var ticket: Ticket?
    var numbersStringArray: [[String]] = [] {
        didSet {
            delegate?.updateSizeOfEditCell(numbersStringArray: numbersStringArray)
        }
    }
    
    weak var delegate: EditTicketViewControllerDelegate?
    weak var parentvc: EditLuckyNumbersViewController?
    
    private let rightArrowImageView: UIImageView = {
         let imageView = UIImageView()
         imageView.image = UIImage(named: "EditTickets.RightArrow")
         imageView.translatesAutoresizingMaskIntoConstraints = false
         imageView.contentMode = .scaleAspectFit
         imageView.alpha = 0
         return imageView
     }()

    private let containerBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16.scale // Optional corner radius for rounded edges
        view.layer.masksToBounds = true
        view.backgroundColor = Appearance.main400 // Set the desired background color
        return view
    }()
    
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
        layout.minimumLineSpacing = 6.scale
        layout.minimumInteritemSpacing = 6.scale
        layout.sectionInset = UIEdgeInsets(top: 6.scale, left: 0.scale, bottom: 0.scale, right: 0.scale)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(EditScanNumberCell.self, forCellWithReuseIdentifier: EditScanNumberCell.reuseIdentifier)
        collectionView.register(RemoveCell.self, forCellWithReuseIdentifier: "RemoveCell") // Register RemoveCell
        collectionView.register(EditTicketRowCollectionCell.self, forCellWithReuseIdentifier: EditTicketRowCollectionCell.reuseIdentifier) //
        collectionView.layer.masksToBounds = false

        return collectionView
    }()
    var collectionViewHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayoutConstraints()
        addDateLabelTapGesture()
        addContainerBackgroundViewTapGesture()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupLayoutConstraints()
        addDateLabelTapGesture()
        addContainerBackgroundViewTapGesture()
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    private func addContainerBackgroundViewTapGesture() {
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerBackgroundViewTapped))
           containerBackgroundView.isUserInteractionEnabled = true
           containerBackgroundView.addGestureRecognizer(tapGesture)
       }

       @objc private func containerBackgroundViewTapped() {
           dateLabelTapped()
       }
    func configure(ticket: Ticket) {
        self.ticket = ticket
        numbersStringArray = convertTo2DStringArray(ticket.numbers) //ticket.numbers.map { $0.map { "\($0)" } }
        
        var lotteryLogoUrlString = lotteries.filter { $0.id == ticket.lotteryId }.first?.logoUrl
        if let url = lotteryLogoUrlString {
            self.logoImageView.kf.setImage(with: url)
        } else {
            logoImageView.image = nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: ticket.date))
        dateLabel.text = formattedDate.uppercased()
        
        pencilEditImageView.image = UIImage(named: "vEditTickets.Pencil")
        collectionViewHeightConstraint.isActive = false
        
        // Get the number of cells in the last row
        if let firstNumberArray = numbersStringArray.first {
            let numberOfCells = firstNumberArray.count + 1
            // Calculate the available width based on the given constraints
            let totalWidth: CGFloat = 343.scale
            let sideMargins: CGFloat = 40.scale
            let cellSpacing: CGFloat = 3.scale * CGFloat(numberOfCells )
            
            // Calculate the width for each cell
            let availableWidth = totalWidth - sideMargins - cellSpacing
            let cellWidth = availableWidth / CGFloat(numberOfCells)
            collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: CGFloat(numbersStringArray.count) * (40 + 16).scale)
        } else {
            collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: CGFloat(numbersStringArray.count) * (40 + 10 + 10).scale)
            }
        collectionViewHeightConstraint.isActive = true
        collectionView.reloadData()
    }
}

private extension TicketLuckyNumbersEditCell {
    @objc private func plusButtonTapped() {
        // Determine the first element of the last section
        var lastSection = numbersStringArray.last
         
        var nextRowFirstElement = ""
        
        if let lastSectionFirstElement = lastSection?.first, !lastSectionFirstElement.isEmpty {
            nextRowFirstElement = getNextLabel(from: lastSectionFirstElement)
        } else {
            nextRowFirstElement = "A" // Default to "A" if last section is empty or not defined
        }
        
        // Create a new row with the first element as calculated and the rest as empty strings
        var itemCount = lotteryPatterns.first?.itemCount
        let numberOfElementsInLastSection = lastSection?.count  ?? ((itemCount != nil) ? (itemCount! + 1) : 0)
        var newSection = Array(repeating: "", count: numberOfElementsInLastSection)
        if !newSection.isEmpty {
            newSection[0] = nextRowFirstElement
        }
        
        numbersStringArray.append(newSection)
        
        // Update the collection view height constraint
        collectionViewHeightConstraint.constant = CGFloat(numbersStringArray.count) * (40 + 16).scale + 5.scale
        
        collectionView.reloadData()
        
        delegate?.updateSizeOfEditCell(numbersStringArray: numbersStringArray)
    }

    // Helper function to calculate the next label in sequence
    private func getNextLabel(from currentLabel: String) -> String {
        // If currentLabel is empty, start with "A"
        if currentLabel.isEmpty {
            return "A"
        }
        
        // Separate the letters and numbers from the current label
        let letters = currentLabel.prefix { $0.isLetter }
        let numbers = currentLabel.drop { $0.isLetter }
        
        let letterStr = String(letters).uppercased()
        let numberStr = String(numbers)
        
        // Ensure there's at least one letter
        guard let lastLetter = letterStr.last, let asciiValue = lastLetter.asciiValue else {
            return "A"
        }
        
        // Logic to compute the next label
        if numberStr.isEmpty {
            if letterStr == "Z" {
                // From "Z" to "A1"
                return "A1"
            } else {
                // Increment the letter
                let nextAscii = asciiValue + 1
                let nextLetter = UnicodeScalar(nextAscii)
                return "\(Character(nextLetter))"
            }
        } else {
            if letterStr == "Z" {
                // From "Z<number>" to "A<next_number>"
                if let number = Int(numberStr) {
                    let nextNumber = number + 1
                    return "A\(nextNumber)"
                } else {
                    // If number parsing fails, start from "A1"
                    return "A1"
                }
            } else {
                // Increment the letter, keep the same number
                let nextAscii = asciiValue + 1
                let nextLetter = UnicodeScalar(nextAscii)
                return "\(Character(nextLetter))\(numberStr)"
            }
        }
        
        // Default fallback
        return "A"
    }


    func setupUI() {
        backgroundColor = Appearance.mono100
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabelContainer.translatesAutoresizingMaskIntoConstraints = false
//        dateLabelContainer.layer.shadowColor = Appearance.dropShadowColor?.cgColor
//        dateLabelContainer.layer.shadowOpacity = 0.5
//        dateLabelContainer.layer.shadowRadius = 3.scale
//        dateLabelContainer.layer.shadowOffset = CGSize(width: 0, height: 2.scale)
        
        dateLabel.font = Fonts.Inter.medium(size: 12.5.scale)
        dateLabel.textAlignment = .center
        dateLabel.textColor = Appearance.main300
        dateLabel.backgroundColor = .clear//Appearance.mono100
        dateLabel.layer.cornerRadius = 17.scale
        dateLabel.layer.masksToBounds = true
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        pencilEditImageView.contentMode = .scaleAspectFit
        pencilEditImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerBackgroundView) // Add container background view
        containerBackgroundView.addSubview(rightArrowImageView)
        containerBackgroundView.addSubview(logoImageView)
        containerBackgroundView.addSubview(dateLabelContainer)
        dateLabelContainer.addSubview(dateLabel)
        dateLabelContainer.addSubview(pencilEditImageView)
        addSubview(collectionView)
        addSubview(plusButton)
        
        customDatePicker.onDateSelected = { [weak self] selectedDate in
            self?.updateDateLabel(with: selectedDate)
            self?.ticket?.date = selectedDate.timeIntervalSince1970
            self?.parentvc?.ticket?.date = selectedDate.timeIntervalSince1970
            self?.dismissDatePicker()
            
        }
        
        customDatePicker.onClose = { [weak self] in
            self?.dismissDatePicker()
        }
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    func setupLayoutConstraints() {
           collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: CGFloat((ticket?.numbers.count ?? 0)) * (40 + 6 + 10).scale)

           NSLayoutConstraint.activate([
               // Container Background View Constraints
               containerBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale),
               containerBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
               containerBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
               containerBackgroundView.heightAnchor.constraint(equalToConstant: 92.scale),

               // logoImageView Constraints inside containerBackgroundView
               logoImageView.topAnchor.constraint(equalTo: containerBackgroundView.topAnchor, constant: 10.scale),
               logoImageView.leadingAnchor.constraint(equalTo: containerBackgroundView.leadingAnchor, constant: 10.scale),
               logoImageView.widthAnchor.constraint(equalToConstant: 138.scale),
               logoImageView.heightAnchor.constraint(equalToConstant: 48.scale),

               // dateLabelContainer Constraints inside containerBackgroundView
               dateLabelContainer.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 4.scale),
               dateLabelContainer.leadingAnchor.constraint(equalTo: logoImageView.leadingAnchor, constant: 8.scale),
               dateLabelContainer.widthAnchor.constraint(equalToConstant: 122.scale),
               dateLabelContainer.heightAnchor.constraint(equalToConstant: 24.scale),

               dateLabel.leadingAnchor.constraint(equalTo: dateLabelContainer.leadingAnchor, constant: -10.scale),
               dateLabel.centerYAnchor.constraint(equalTo: dateLabelContainer.centerYAnchor),
               dateLabel.widthAnchor.constraint(equalTo: dateLabelContainer.widthAnchor, constant: 10.scale),
               dateLabel.heightAnchor.constraint(equalTo: dateLabelContainer.heightAnchor),

               pencilEditImageView.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: -33.scale),
               pencilEditImageView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
               pencilEditImageView.widthAnchor.constraint(equalToConstant: 24.scale),
               pencilEditImageView.heightAnchor.constraint(equalToConstant: 24.scale),

               // Right Arrow Image View Constraints
               rightArrowImageView.centerYAnchor.constraint(equalTo: containerBackgroundView.centerYAnchor),
               rightArrowImageView.trailingAnchor.constraint(equalTo: containerBackgroundView.trailingAnchor, constant: -16.scale),
               rightArrowImageView.widthAnchor.constraint(equalToConstant: 24.scale),
               rightArrowImageView.heightAnchor.constraint(equalToConstant: 24.scale),

               // CollectionView Constraints
               collectionView.topAnchor.constraint(equalTo: containerBackgroundView.bottomAnchor, constant: 10.scale),
               collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.scale),
               collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.scale),
               collectionViewHeightConstraint,

               // Plus Button Constraints
               plusButton.centerXAnchor.constraint(equalTo: centerXAnchor),
               plusButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 18.scale),
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
       //  presentDatePicker()
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
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            // If the index is the last one, return a RemoveCell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RemoveCell", for: indexPath) as? RemoveCell else {
                return UICollectionViewCell()
            }
            cell.indexPath = indexPath
            cell.numberOfCells = numbersStringArray.last?.count
            cell.delegate = self

            return cell
        }
        if indexPath.item == 1  {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditTicketRowCollectionCell.reuseIdentifier, for: indexPath) as? EditTicketRowCollectionCell else {
                return UICollectionViewCell()
            }
           // cell.parent = self
            cell.parentDelegate = self // Set the delegate
            cell.section = indexPath.section
            cell.numbers = numbersStringArray[indexPath.section]
            cell.bonusIdx = bonusIdx
            cell.collectionView.reloadData()

            return cell
        }
        fatalError()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if numbersStringArray.count == 1 {
            return UIEdgeInsets(top: 16.scale,
                                left: numbersStringArray[0].count == 6 ? 0.scale : 0.scale, bottom: 0.scale,
                                right:  numbersStringArray[0].count == 6 ? 0.scale : 0.scale)
        } else {
            return UIEdgeInsets(top: 16.scale, left: 0.scale, bottom: 0.scale, right: 0.scale)
        }
    }
    
   
    func removeItem(at indexPath: IndexPath) {
        // Check if it's the only row left
        if numbersStringArray.count == 1 && indexPath.section == 0 {
          //  presentDeleteConfirmationAlert()
            removeTicket()
        } else {
            // Normal removal process
            numbersStringArray.remove(at: indexPath.section)
            print("numbersStringArray: \(numbersStringArray.count)")
            collectionViewHeightConstraint.isActive = false
            // Get the number of cells in the last row
            if let firstNumberArray = numbersStringArray.first {
                let numberOfCells = firstNumberArray.count + 1
                // Calculate the available width based on the given constraints
                let totalWidth: CGFloat = 343.scale
                let sideMargins: CGFloat = 40.scale
                let cellSpacing: CGFloat = 3.scale * CGFloat(numberOfCells )
                
                // Calculate the width for each cell
                let availableWidth = totalWidth - sideMargins - cellSpacing
                let cellWidth = availableWidth / CGFloat(numberOfCells)
                collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: CGFloat(numbersStringArray.count) * (40 + 16).scale)
            } else {
              collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: CGFloat(numbersStringArray.count) * (40 + 16).scale)
              }
            collectionViewHeightConstraint.isActive = true
            
            collectionView.reloadData()

        }
    }
    private func presentDeleteConfirmationAlert() {
        let alertVC = CustomAlertViewController()
        
        alertVC.onConfirmDelete = { [weak self] in
            guard let self = self else { return }
            // Code to remove the ticket here
            self.removeTicket()
        }
        
        alertVC.onCancel = {
            // Code to handle cancellation (if any)
        }
        
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        
        if let parentVC = self.parentViewController {
            parentVC.present(alertVC, animated: true, completion: nil)
            return
        }
        
    }
    
    private func removeTicket() {
        parentvc?.luckyNumbersCell?.removeButtonTapped()
    }
    // Implementing sizeForItemAt to dynamically set item size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
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
            let cellSpacing: CGFloat = 3.scale * CGFloat(numberOfCells )
            
            // Calculate the width for each cell
            let availableWidth = totalWidth - sideMargins - cellSpacing
            let cellWidth = availableWidth / CGFloat(numberOfCells)
            
            // Return the size for the cell
            return CGSize(width:40.scale , height: 40.scale)
        } else {
            let collectionViewWidth = collectionView.bounds.width
            let resWidth = collectionViewWidth - 40.scale - 6.scale - 2.scale
            print("resWiddth \(resWidth) \(indexPath)")
            return CGSize(width: resWidth, height: 40.scale)
        }
    }
}
extension TicketLuckyNumbersEditCell: EditTicketRowCollectionCellDelegate {
    func editTicketRowCollectionCell(_ cell: EditTicketRowCollectionCell, didUpdateNumbers numbers: [String], inSection section: Int) {
        // Update 'numbersStringArray' with the new numbers
        numbersStringArray[section] = numbers
    }

    func editTicketRowCollectionCellDidFinishEnteringNumbers(_ cell: EditTicketRowCollectionCell) {
        // Move focus to the first cell of the next row
        guard let currentSection = collectionView.indexPath(for: cell)?.section else { return }
        let nextSectionIndex = currentSection + 1

        if nextSectionIndex < numbersStringArray.count {
            // Move focus to the first cell of the next row
            let nextIndexPath = IndexPath(item: 1, section: nextSectionIndex)
            collectionView.scrollToItem(at: nextIndexPath, at: .centeredVertically, animated: true)

            DispatchQueue.main.async {
                if let nextRowCell = self.collectionView.cellForItem(at: nextIndexPath) as? EditTicketRowCollectionCell {
                    let nestedCollectionView = nextRowCell.collectionView
                    let nestedIndexPath = IndexPath(item: 0, section: 0)
                    nestedCollectionView.scrollToItem(at: nestedIndexPath, at: .centeredHorizontally, animated: true)

                    DispatchQueue.main.async {
                        if let nextCell = nestedCollectionView.cellForItem(at: nestedIndexPath) as? EditNumberCell {
                            nextCell.numberTextField.becomeFirstResponder()
                        } else {
                            nestedCollectionView.layoutIfNeeded()
                            if let nextCell = nestedCollectionView.cellForItem(at: nestedIndexPath) as? EditNumberCell {
                                nextCell.numberTextField.becomeFirstResponder()
                            }
                        }
                    }
                }
            }
        } else {
            // No more rows; delay dismissing the keyboard
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                cell.endEditing(true)
            }
        }
    }
    func editTicketRowCollectionCell(_ cell: EditTicketRowCollectionCell, moveToNextUnfilledCellFrom indexPath: IndexPath) {
        guard let currentRowIndexPath = collectionView.indexPath(for: cell) else { return }
        var currentSection = currentRowIndexPath.section
        var currentItem = indexPath.item

        // Start searching from the next item
        var foundNextCell = false

        while !foundNextCell {
            currentItem += 1

            // If we reach the end of the current row, move to the next row
            if currentItem >= numbersStringArray[currentSection].count {
                currentSection += 1
                currentItem = 0

                // If we reach the end of the sections, stop searching
                if currentSection >= numbersStringArray.count {
                    break
                }
            }

            let nextNumber = numbersStringArray[currentSection][currentItem]
            let containsNonDigit = nextNumber.contains { !$0.isNumber }

            // Skip cells that have at least one character that is not a number
            if containsNonDigit {
                continue
            }

            // Skip cells that have two numbers
            if nextNumber.count >= 2 {
                continue
            }

            // Found a cell that has no number or one number
            foundNextCell = true
            break
        }

        if foundNextCell {
            // Scroll to the next cell and make it the first responder
            let nextRowIndexPath = IndexPath(item: 1, section: currentSection) // Assuming item 1 is EditTicketRowCollectionCell
            collectionView.scrollToItem(at: nextRowIndexPath, at: .centeredVertically, animated: true)

            DispatchQueue.main.async {
                if let nextRowCell = self.collectionView.cellForItem(at: nextRowIndexPath) as? EditTicketRowCollectionCell {
                    let nestedCollectionView = nextRowCell.collectionView
                    let nestedIndexPath = IndexPath(item: currentItem, section: 0)
                    nestedCollectionView.scrollToItem(at: nestedIndexPath, at: .centeredHorizontally, animated: true)

                    DispatchQueue.main.async {
                        if let nextCell = nestedCollectionView.cellForItem(at: nestedIndexPath) as? EditNumberCell {
                            nextCell.numberTextField.becomeFirstResponder()
                        } else {
                            nestedCollectionView.layoutIfNeeded()
                            if let nextCell = nestedCollectionView.cellForItem(at: nestedIndexPath) as? EditNumberCell {
                                nextCell.numberTextField.becomeFirstResponder()
                            }
                        }
                    }
                }
            }
        } else {
            // No next unfilled cell found; optionally dismiss keyboard
            cell.endEditing(true)
        }
    }


}

extension TicketLuckyNumbersEditCell {
    func convertTo2DStringArray(_ input: [[Int]]) -> [[String]] {
        let alphabet = (65...90).map { String(UnicodeScalar($0)!) } // "A" to "Z"
        
        var result = [[String]]()
        var letterIndex = 0
        var repeatIndex = 0
        
        for array in input {
            // Generate the label (e.g., "A", "B", ..., "Z", "A1", "B1", ...)
            let label: String
            if letterIndex < alphabet.count {
                label = alphabet[letterIndex]
            } else {
                let baseIndex = (letterIndex % alphabet.count)
                label = alphabet[baseIndex] + "\(repeatIndex)"
            }
            
            // Convert the current array to [String] and prepend the label
            let newArray = [label] + array.map { String($0) }
            result.append(newArray)
            
            // Update the indices for next label
            letterIndex += 1
            if letterIndex == alphabet.count {
                letterIndex = 0
                repeatIndex += 1
            }
        }
        
        return result
    }
}
