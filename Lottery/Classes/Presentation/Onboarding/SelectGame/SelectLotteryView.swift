//  SelectLotteryView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit

final class SelectLotteryView: UIView {
    
    // MARK: - UI Components
    
    let continueButton: UIButton = {
        let button = UIButton()
        let attrs = TextAttributes()
            .textColor(.white)
            .font(Fonts.Inter.medium(size: 17.scale))
        let attributedTitle = "Continue".localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 22.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = true // Initially disabled
        button.alpha = 1.0 //0.5 // Initially pale
        return button
    }()
    
    let preloader: UIActivityIndicatorView = {
        let preloader = UIActivityIndicatorView(style: .medium)
        preloader.translatesAutoresizingMaskIntoConstraints = false
        preloader.hidesWhenStopped = true
        return preloader
    }()
    
    let addAnotherGameButton: UIButton = {
        let button = UIButton()
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.medium(size: 17.scale))
        let attributedTitle = "Add another game".localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        button.layer.borderWidth = 1.scale
        button.layer.cornerRadius = 22.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let headerLabel: UILabel = {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.bold(size: 19.scale))
            .lineHeight(22.8.scale)
            .textAlignment(.left)
        let label = UILabel()
        label.attributedText = "SELECT THE GAME".localized.attributed(with: attrs)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let attrs = TextAttributes()
            .textColor(Appearance.main300)
            .font(Fonts.Inter.medium(size: 15.scale))
            .lineHeight(18.scale)
            .textAlignment(.left)
        let label = UILabel()
        label.attributedText = "Please choose the game to monitor. You can add another game if it is not on the list.".localized.attributed(with: attrs)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gameTableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsMultipleSelection = true
        tableView.backgroundColor = Appearance.main500
        tableView.separatorInset = UIEdgeInsets(top: 0.scale, left: 20.scale, bottom: 0.scale, right: 20.scale)
        tableView.separatorColor = .lightGray
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var lotteries: [Lottery] = []
    private var selectedLotteries: Set<Int> = []
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods

extension SelectLotteryView {
    func getSelectedLotteries() -> [Int] {
        var selectedIds : [Int] = []
        for sl in Array(selectedLotteries) {
            selectedIds.append(lotteries[sl].id)
        }
        return selectedIds
    }
    
    func updateGames(_ lotteries: [Lottery]) {
        DispatchQueue.main.async {
            self.lotteries = lotteries
            self.gameTableView.reloadData()
        }
    }
}

// MARK: - Private Methods

private extension SelectLotteryView {
    func setupView() {
        backgroundColor = Appearance.main500
        addSubview(headerLabel)
        addSubview(descriptionLabel)
        addSubview(gameTableView)
        addSubview(continueButton)
        addSubview(preloader) // Add preloader to the view
        addSubview(addAnotherGameButton)
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 83.scale : 70.scale),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10.scale),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            
            gameTableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20.scale),
            gameTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gameTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gameTableView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20.scale),
            
            continueButton.bottomAnchor.constraint(equalTo: addAnotherGameButton.topAnchor, constant: -10.scale),
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 44.scale),
            
            // Constraints for preloader
            preloader.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor),
            
            addAnotherGameButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant:  ScreenSize.isIphoneXFamily ? -50.scale : -20.scale),
            addAnotherGameButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            addAnotherGameButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            addAnotherGameButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
    }
    
    func setupTableView() {
        gameTableView.dataSource = self
        gameTableView.delegate = self
        gameTableView.register(LotteryCell.self, forCellReuseIdentifier: "LotteryCell")
    }
    
    func updateContinueButtonState() {
        continueButton.isEnabled = true //!selectedLotteries.isEmpty
        continueButton.alpha = 1.0 //selectedLotteries.isEmpty ? 0.5 : 1.0
    }
}

// MARK: - UITableViewDataSource

extension SelectLotteryView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lotteries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LotteryCell", for: indexPath) as? LotteryCell else {
            return UITableViewCell()
        }
        let lottery = lotteries[indexPath.row]
        let isSelected = selectedLotteries.contains(indexPath.row)
        cell.configure(with: lottery, isSelected: isSelected)
        
        cell.selectionStyle = .none 
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SelectLotteryView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedLotteries.contains(indexPath.row) {
            selectedLotteries.remove(indexPath.row)
        } else {
            selectedLotteries.insert(indexPath.row)
        }
        updateContinueButtonState()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if selectedLotteries.contains(indexPath.row) {
            selectedLotteries.remove(indexPath.row)
        } else {
            selectedLotteries.insert(indexPath.row)
        }
        updateContinueButtonState()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.scale
    }
}
