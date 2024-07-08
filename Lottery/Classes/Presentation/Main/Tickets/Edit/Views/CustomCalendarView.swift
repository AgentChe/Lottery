//
//  CustomCalendarView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/13/24.
//

import UIKit

class CustomCalendarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    private var selectedDate = Date()
    private var currentMonth: Date
    private var latestMonth: Date // Add this property

    private let headerLabel = UILabel()
    private let daysOfWeekStackView = UIStackView()
    private let collectionView: UICollectionView
    private let saveButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)

    var onDateSelected: ((Date) -> Void)?
    var onClose: (() -> Void)?

    override init(frame: CGRect) {
        self.currentMonth = Date()
        self.latestMonth = Date() // Initialize the latest month to the current date
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.scale
        layout.minimumLineSpacing = 0.scale

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Appearance.mono100
        collectionView.layer.borderWidth = 1.scale
        collectionView.layer.borderColor = Appearance.main300Calendar.cgColor

        super.init(frame: frame)

        setupUI()
        setupConstraints()
        updateHeader()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = Appearance.mono100
        layer.cornerRadius = 20.scale
        layer.masksToBounds = true

        headerLabel.font = Fonts.Inter.bold(size: 20.scale)
        headerLabel.textAlignment = .left
        headerLabel.textColor = Appearance.mono200
        addSubview(headerLabel)

        let previousButton = UIButton(type: .system)
        if let chevronBackward = UIImage(systemName: "chevron.backward") {
            previousButton.setImage(chevronBackward, for: .normal)
        }
        previousButton.tintColor = Appearance.mono200 // Set the color of the icon
        previousButton.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
        previousButton.tag = 1 // Assign a tag to identify the button later
        addSubview(previousButton)

        let nextButton = UIButton(type: .system)
        if let chevronForward = UIImage(systemName: "chevron.forward") {
            nextButton.setImage(chevronForward, for: .normal)
        }
        nextButton.tintColor = Appearance.mono200 // Set the color of the icon
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        nextButton.tag = 2 // Assign a tag to identify the button later
        addSubview(nextButton)

        // Setup days of the week
        let days = [
            "CustomCalendarView.Days.Sunday".localized,
            "CustomCalendarView.Days.Monday".localized,
            "CustomCalendarView.Days.Tuesday".localized,
            "CustomCalendarView.Days.Wednesday".localized,
            "CustomCalendarView.Days.Thursday".localized,
            "CustomCalendarView.Days.Friday".localized,
            "CustomCalendarView.Days.Saturday".localized
        ]
        for day in days {
            let label = UILabel()
            label.text = day
            label.font = Fonts.Inter.semiBold(size: 14.scale)
            label.textAlignment = .center
            label.textColor = Appearance.mono200 // Dark color for day labels
            daysOfWeekStackView.addArrangedSubview(label)
        }

        daysOfWeekStackView.axis = .horizontal
        daysOfWeekStackView.distribution = .fillEqually
        daysOfWeekStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(daysOfWeekStackView)

        addSubview(collectionView)

        // Setup buttons
        saveButton.setTitle("CustomCalendarView.Save".localized, for: .normal)
        saveButton.backgroundColor = Appearance.main100 // Custom red color
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 22.scale // Half the height for rounded effect
        saveButton.layer.masksToBounds = true
        saveButton.titleLabel?.font = Fonts.Inter.bold(size: 16.scale)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        addSubview(saveButton)

        closeButton.setTitle("CustomCalendarView.Close".localized, for: .normal)
        closeButton.backgroundColor = .clear
        closeButton.setTitleColor(Appearance.mono200, for: .normal) // Dark color for close button text
        closeButton.layer.borderWidth = 1.scale
        closeButton.layer.borderColor = Appearance.main300Calendar.cgColor // Border matching the text color
        closeButton.layer.cornerRadius = 22.scale // Half the height for rounded effect
        closeButton.layer.masksToBounds = true
        closeButton.titleLabel?.font = Fonts.Inter.bold(size: 16.scale)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSubview(closeButton)
    }

    private func setupConstraints() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        let previousButton = viewWithTag(1) as! UIButton
        let nextButton = viewWithTag(2) as! UIButton

        previousButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16.scale),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            headerLabel.widthAnchor.constraint(equalToConstant: 190.scale),
            
            previousButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            previousButton.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -20.scale), // Adjust spacing as needed
            
            nextButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale), // Adjust if needed

            daysOfWeekStackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8.scale),
            daysOfWeekStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            daysOfWeekStackView.widthAnchor.constraint(equalToConstant: 312.scale),
            daysOfWeekStackView.heightAnchor.constraint(equalToConstant: 20.scale),
            
            collectionView.topAnchor.constraint(equalTo: daysOfWeekStackView.bottomAnchor, constant: 8.scale),
            collectionView.centerXAnchor.constraint(equalTo: centerXAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: 312.scale),
            collectionView.heightAnchor.constraint(equalToConstant: 308.scale - 44.scale),
            
            saveButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16.scale),
            saveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            saveButton.heightAnchor.constraint(equalToConstant: 44.scale),
            
            closeButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 8.scale),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 44.scale),
            closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.scale)
        ])
    }

    private func updateHeader() {
        dateFormatter.dateFormat = "MMMM yyyy"
        headerLabel.text = dateFormatter.string(from: currentMonth)
        
        let previousButton = viewWithTag(1) as! UIButton
        
        if calendar.isDate(currentMonth, equalTo: latestMonth, toGranularity: .month) &&
           calendar.isDate(currentMonth, equalTo: latestMonth, toGranularity: .year) {
            previousButton.tintColor = Appearance.main300
            previousButton.isUserInteractionEnabled = false
        } else {
            previousButton.tintColor = Appearance.mono200
            previousButton.isUserInteractionEnabled = true
        }
    }

    @objc private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
        updateHeader()
        collectionView.reloadData()
    }

    @objc private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
        updateHeader()
        collectionView.reloadData()
    }

    @objc private func saveTapped() {
        onDateSelected?(selectedDate)
    }

    @objc private func closeTapped() {
        onClose?()
    }

    private func startOfMonth(for date: Date) -> Date {
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
    }

    private func firstWeekdayOfMonth() -> Int {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        let firstDay = calendar.date(from: components)!
        return calendar.component(.weekday, from: firstDay)
    }

    private func lastWeekdayOfMonth() -> Int {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let lastDay = calendar.date(byAdding: .day, value: range.count - 1, to: startOfMonth(for: currentMonth))!
        return calendar.component(.weekday, from: lastDay) - 1
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42 // Always show 6 rows * 7 columns = 42 items
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        let firstWeekday = firstWeekdayOfMonth() - 1 // Zero-indexed
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let numDays = range.count

        if indexPath.item < firstWeekday {
            // Dates from the previous month
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
            let previousMonthRange = calendar.range(of: .day, in: .month, for: previousMonth)!
            let day = previousMonthRange.count - firstWeekday + indexPath.item + 1
            cell.dateLabel.text = "\(day)"
            cell.dateLabel.textColor = Appearance.main300 // Gray color for non-current month dates
            cell.backgroundColor = Appearance.main600
            cell.isUserInteractionEnabled = false // Disable interaction for non-current month dates
        } else if indexPath.item >= firstWeekday && indexPath.item < numDays + firstWeekday {
            // Dates from the current month
            let day = indexPath.item - firstWeekday + 1
            cell.dateLabel.text = "\(day)"
         
            if calendar.isDate(selectedDate, inSameDayAs: calendar.date(byAdding: .day, value: day - 1, to: startOfMonth(for: currentMonth))!) {
                cell.backgroundColor = Appearance.main100 // Highlight color
                cell.dateLabel.textColor = .white
            } else {
                cell.backgroundColor = Appearance.mono100
                cell.dateLabel.textColor = Appearance.mono200
            }
            cell.isUserInteractionEnabled = true // Enable interaction for current month dates
        } else {
            // Dates from the next month
            let day = indexPath.item - numDays - firstWeekday + 1
            cell.dateLabel.text = "\(day)"
            cell.dateLabel.textColor = Appearance.main300 // Gray color for non-current month dates
            cell.backgroundColor = Appearance.main600
            cell.isUserInteractionEnabled = false // Disable interaction for non-current month dates
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let firstWeekday = firstWeekdayOfMonth() - 1 // Zero-indexed
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let numDays = range.count
        
        if let cell = collectionView.cellForItem(at: indexPath) as? DateCell, let dayText = cell.dateLabel.text, let day = Int(dayText) {
            var dateComponents = calendar.dateComponents([.year, .month], from: currentMonth)
            
            if indexPath.item < firstWeekday {
                // Date from the previous month
                let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
                dateComponents = calendar.dateComponents([.year, .month], from: previousMonth)
                dateComponents.day = day
            } else if indexPath.item >= firstWeekday && indexPath.item < numDays + firstWeekday {
                // Date from the current month
                dateComponents.day = day
            } else {
                // Date from the next month
                let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
                dateComponents = calendar.dateComponents([.year, .month], from: nextMonth)
                dateComponents.day = day
            }
            
            if let date = calendar.date(from: dateComponents) {
                selectedDate = date
                collectionView.reloadData() // Update the selection
            }
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 44.13.scale, height: 44.scale)
    }
}
