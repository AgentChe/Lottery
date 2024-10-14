//
//  ScanSelectLotteryView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/24/24.
//


import UIKit

final class ScanSelectLotteryView: UIView {
    
    // MARK: - UI Components
    var fromMenu = false
    lazy var continueButton: UIButton = {
        let button = UIButton()
        let attrs = TextAttributes()
            .textColor(.white)
            .font(Fonts.Inter.medium(size: 17.scale))
        let attributedTitle = "Continue".localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 22.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = fromMenu ? true : false // Initially disabled
        button.alpha = fromMenu ? 1:0.5 // Initially pale
        return button
    }()
    let profileManager = ProfileManager()
    let preloader: UIActivityIndicatorView = {
        let preloader = UIActivityIndicatorView(style: .medium)
        preloader.translatesAutoresizingMaskIntoConstraints = false
        preloader.hidesWhenStopped = true
        preloader.color = Appearance.mono100
        return preloader
    }()
    
    
    private let descriptionLabel: UILabel = {
        let attrs = TextAttributes()
            .textColor(Appearance.main300)
            .font(Fonts.Inter.medium(size: 14.scale))
            .lineHeight(25.scale)
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
    
    private var lotteries: [Lottery] = []
    private var selectedLotteries: Set<Int> = [] {
        didSet {
            updateContinueButtonState()
        }
    }
    
    // MARK: - Initializers
    
     func getAlreadySelectedLotteriesId() {
        if fromMenu {
            profileManager.getProfile(forceUpdate: false) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let profile):
                        if let selfLotteries = self?.lotteries {
                            if let pLotteriesIds = profile.lotteries {
                                for i in 0..<selfLotteries.count {
                                    for plotteryId in pLotteriesIds {
                                        if selfLotteries[i].id == plotteryId {
                                            self?.selectedLotteries.insert(i)
                                        }
                                    }
                                }
                            }
                            self?.gameTableView.reloadData()
                        } else {
                            print("Lotteries are not available in profile")
                        }
                    case .failure(let error):
                        print("Failed to fetch profile: \(error)")
                    }
                }
            }
        }
    }
    init(fromMenu: Bool = false, frame: CGRect = .zero) {
            self.fromMenu = fromMenu
            super.init(frame: frame)
            setupView()
            setupTableView()
            getAlreadySelectedLotteriesId()
        }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTableView()
        
        getAlreadySelectedLotteriesId()
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods

extension ScanSelectLotteryView {
    func getSelectedLotteries() -> [Int] {
         
        return Array(selectedLotteries)
    }
    
    func updateGames(_ lotteries: [Lottery]) {
        DispatchQueue.main.async {
            self.lotteries = lotteries
            self.gameTableView.reloadData()
        }
    }
}

// MARK: - Private Methods

private extension ScanSelectLotteryView {
    func setupView() {
        backgroundColor = Appearance.main400
        addSubview(descriptionLabel)
        addSubview(gameTableView)
        addSubview(continueButton)
        addSubview(preloader) // Add preloader to the view
        if fromMenu {
            addSubview(addAnotherGameButton)
        }
        setupConstraints()
        
        
    }
    
    func setupConstraints() {
        if fromMenu {
            NSLayoutConstraint.activate([
                
                descriptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 95.scale),
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
        } else {
            NSLayoutConstraint.activate([
                  
                  descriptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 95.scale),
                  descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
                  descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
                  
                  gameTableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20.scale),
                  gameTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                  gameTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                  gameTableView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20.scale),
                  
                  continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50.scale),
                  continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
                  continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
                  continueButton.heightAnchor.constraint(equalToConstant: 44.scale),
                  
                  // Constraints for preloader
                  preloader.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
                  preloader.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor),
               
              ])
        }
    }
    
    func setupTableView() {
        gameTableView.dataSource = self
        gameTableView.delegate = self
        gameTableView.register(LotteryCell.self, forCellReuseIdentifier: "LotteryCell")
        gameTableView.backgroundColor = Appearance.main400
    }
    
    func updateContinueButtonState() {
        if !fromMenu {
            continueButton.isEnabled = !selectedLotteries.isEmpty
            continueButton.alpha = selectedLotteries.isEmpty ? 0.5 : 1.0
        } else {
            continueButton.isEnabled = true
            continueButton.alpha =  1.0
        }
    }
}

// MARK: - UITableViewDataSource

extension ScanSelectLotteryView: UITableViewDataSource {
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

// MARK: - UITableViewDelegate

extension ScanSelectLotteryView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Clear all other selections
        for index in selectedLotteries {
            tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: true)
        }
        
        // Clear the selectedLotteries set and add the new selection
        
        if !fromMenu {
            selectedLotteries.removeAll()
            
            selectedLotteries.insert(indexPath.row)
        } else {
            if selectedLotteries.contains(indexPath.row) {
                selectedLotteries.remove(indexPath.row)
            } else {
                selectedLotteries.insert(indexPath.row)
            }
        }
       
        
        updateContinueButtonState()
        tableView.reloadData()
    }
//    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        // Ensure the selected row remains selected until another row is chosen
//       
//            selectedLotteries.removeAll()
//            selectedLotteries.insert(indexPath.row)
//      
//        
//        updateContinueButtonState()
//        tableView.reloadData()
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.scale
    }
}
