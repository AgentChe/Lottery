 

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

    private let headerLabel = UILabel()
    private let daysOfWeekStackView = UIStackView()
    private let collectionView: BorderedCollectionView
    private let saveButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)

    var onDateSelected: ((Date) -> Void)?
    var onClose: (() -> Void)?

    override init(frame: CGRect) {
        self.currentMonth = Date()

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        collectionView = BorderedCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Appearance.mono100

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
        layer.cornerRadius = 20
        layer.masksToBounds = true

        headerLabel.font = Fonts.Inter.bold(size: 20)
        headerLabel.textAlignment = .center
        headerLabel.textColor = Appearance.mono200
        addSubview(headerLabel)

        let previousButton = UIButton(type: .system)
        previousButton.setTitle("<", for: .normal)
        previousButton.titleLabel?.font = Fonts.Inter.medium(size: 16)
        previousButton.setTitleColor(Appearance.mono200, for: .normal)
        previousButton.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
        addSubview(previousButton)

        let nextButton = UIButton(type: .system)
        nextButton.setTitle(">", for: .normal)
        nextButton.titleLabel?.font = Fonts.Inter.medium(size: 16)
        nextButton.setTitleColor(Appearance.mono200, for: .normal)
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        addSubview(nextButton)

        // Setup days of the week
        let days = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        for day in days {
            let label = UILabel()
            label.text = day
            label.font = Fonts.Inter.semiBold(size: 14)
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
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = Appearance.main100 // Custom red color
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 22 // Half the height for rounded effect
        saveButton.layer.masksToBounds = true
        saveButton.titleLabel?.font = Fonts.Inter.bold(size: 16)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        addSubview(saveButton)

        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = .clear
        closeButton.setTitleColor(Appearance.mono200, for: .normal) // Dark color for close button text
        closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = Appearance.main300.cgColor // Border matching the text color
        closeButton.layer.cornerRadius = 22 // Half the height for rounded effect
        closeButton.layer.masksToBounds = true
        closeButton.titleLabel?.font = Fonts.Inter.bold(size: 16)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSubview(closeButton)
    }

    private func setupConstraints() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        let previousButton = subviews.first(where: { $0 is UIButton && ($0 as! UIButton).currentTitle == "<" })!
        let nextButton = subviews.first(where: { $0 is UIButton && ($0 as! UIButton).currentTitle == ">" })!

        previousButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            previousButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            previousButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            nextButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            daysOfWeekStackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            daysOfWeekStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            daysOfWeekStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            daysOfWeekStackView.heightAnchor.constraint(equalToConstant: 20),
            
            collectionView.topAnchor.constraint(equalTo: daysOfWeekStackView.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 270),
            
            saveButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            saveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            
            closeButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 8),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    private func updateHeader() {
        dateFormatter.dateFormat = "MMMM yyyy"
        headerLabel.text = dateFormatter.string(from: currentMonth)
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
            cell.backgroundColor = Appearance.mono100
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
            cell.backgroundColor = Appearance.mono100
            cell.isUserInteractionEnabled = false // Disable interaction for non-current month dates
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let firstWeekday = firstWeekdayOfMonth() - 1 // Zero-indexed
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let numDays = range.count
        
        if indexPath.item >= firstWeekday && indexPath.item < numDays + firstWeekday {
            let day = indexPath.item - firstWeekday + 1
            var dateComponents = calendar.dateComponents([.year, .month], from: currentMonth)
            dateComponents.day = day
            if let date = calendar.date(from: dateComponents) {
                selectedDate = date
                collectionView.reloadData() // Update the selection
            }
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7
        return CGSize(width: width, height: width)
    }
}
