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
    private var latestMonth: Date

    private let headerLabel = UILabel()
    private let daysOfWeekStackView = UIStackView()
    private let collectionView: UICollectionView
    private let saveButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)

    var onDateSelected: ((Date) -> Void)?
    var onClose: (() -> Void)?

    override init(frame: CGRect) {
        self.currentMonth = Date()
        self.latestMonth = Date()
        
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
        headerLabel.textAlignment = .center
        headerLabel.textColor = Appearance.mono200
        addSubview(headerLabel)

        let previousButton = UIButton(type: .system)
        if let chevronBackward = UIImage(systemName: "chevron.backward") {
            previousButton.setImage(chevronBackward, for: .normal)
        }
        previousButton.tintColor = Appearance.mono200
        previousButton.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
        previousButton.tag = 1
        addSubview(previousButton)

        let nextButton = UIButton(type: .system)
        if let chevronForward = UIImage(systemName: "chevron.forward") {
            nextButton.setImage(chevronForward, for: .normal)
        }
        nextButton.tintColor = Appearance.mono200
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        nextButton.tag = 2
        addSubview(nextButton)

        let days = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        for day in days {
            let label = UILabel()
            label.text = day
            label.font = Fonts.Inter.semiBold(size: 14.scale)
            label.textAlignment = .center
            label.textColor = Appearance.mono200
            daysOfWeekStackView.addArrangedSubview(label)
        }

        daysOfWeekStackView.axis = .horizontal
        daysOfWeekStackView.distribution = .fillEqually
        daysOfWeekStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(daysOfWeekStackView)

        addSubview(collectionView)

        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = Appearance.main100
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 22.scale
        saveButton.layer.masksToBounds = true
        saveButton.titleLabel?.font = Fonts.Inter.bold(size: 16.scale)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        addSubview(saveButton)

        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = .clear
        closeButton.setTitleColor(Appearance.mono200, for: .normal)
        closeButton.layer.borderWidth = 1.scale
        closeButton.layer.borderColor = Appearance.main300Calendar.cgColor
        closeButton.layer.cornerRadius = 22.scale
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
            headerLabel.widthAnchor.constraint(equalToConstant: 150.scale),
            
            previousButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            previousButton.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -20.scale),
            
            nextButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),

            daysOfWeekStackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8.scale),
            daysOfWeekStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            daysOfWeekStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            daysOfWeekStackView.heightAnchor.constraint(equalToConstant: 20.scale),
            
            collectionView.topAnchor.constraint(equalTo: daysOfWeekStackView.bottomAnchor, constant: 8.scale),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
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
        
        let nextButton = viewWithTag(2) as! UIButton
        
        // Always enable the next button
        nextButton.tintColor = Appearance.mono200
        nextButton.isUserInteractionEnabled = true
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        let firstWeekday = firstWeekdayOfMonth() - 1
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let numDays = range.count

        if indexPath.item < firstWeekday {
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
            let previousMonthRange = calendar.range(of: .day, in: .month, for: previousMonth)!
            let day = previousMonthRange.count - firstWeekday + indexPath.item + 1
            cell.dateLabel.text = "\(day)"
            cell.dateLabel.textColor = Appearance.main300
            cell.backgroundColor = Appearance.main600
            cell.isUserInteractionEnabled = false
        } else if indexPath.item >= firstWeekday && indexPath.item < numDays + firstWeekday {
            let day = indexPath.item - firstWeekday + 1
            cell.dateLabel.text = "\(day)"
         
            if calendar.isDate(selectedDate, inSameDayAs: calendar.date(byAdding: .day, value: day - 1, to: startOfMonth(for: currentMonth))!) {
                cell.backgroundColor = Appearance.main100
                cell.dateLabel.textColor = .white
            } else {
                cell.backgroundColor = Appearance.mono100
                cell.dateLabel.textColor = Appearance.mono200
            }
            cell.isUserInteractionEnabled = true
        } else {
            let day = indexPath.item - numDays - firstWeekday + 1
            cell.dateLabel.text = "\(day)"
            cell.dateLabel.textColor = Appearance.main300
            cell.backgroundColor = Appearance.main600
            cell.isUserInteractionEnabled = false
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let firstWeekday = firstWeekdayOfMonth() - 1
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let numDays = range.count
        
        if indexPath.item >= firstWeekday && indexPath.item < numDays + firstWeekday {
            let day = indexPath.item - firstWeekday + 1
            var dateComponents = calendar.dateComponents([.year, .month], from: currentMonth)
            dateComponents.day = day
            if let date = calendar.date(from: dateComponents) {
                selectedDate = date
                collectionView.reloadData()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 44.5.scale, height: 44.scale)
    }
}
