//
//  EditLuckyNumbersViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/26/24.
//

import UIKit

class EditLuckyNumbersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var lotteryPatterns: [LotteryPattern] = []
    private var contentManager: ContentManagerProtocol = ContentManager()
    var ticket: Ticket?
    var numbersStringArray: [[String]] = [] {
        didSet {
            updateSaveButtonState()
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    var collectionView: UICollectionView!
    func fetchLotteriesPatterns(for stateId: Int? = nil) {
        contentManager.fetchLotteriesPattern(forceUpdate: false, stateId: nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let patterns):
                    self?.lotteryPatterns = patterns
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print("Failed to fetch lottery patterns: \(error)")
                }
            }
        }
    }
    private let saveTicketButton: UIButton = {
        let button = UIButton()
        button.setTitle("EditLuckyNumbersViewController.SaveButton".localized, for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.layer.cornerRadius = 22.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTicketButtonTapped), for: .touchUpInside)
        button.isEnabled = false // Initially disabled
        return button
    }()
    
    // Add an activity indicator
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // Bottom constraint for the save button
    private var saveButtonBottomConstraint: NSLayoutConstraint!
    
    // Custom
    var game: Game!
    var lotteries: [Lottery]!
    init(ticket: Ticket, game: Game, lotteries: [Lottery]) {
        super.init(nibName: nil, bundle: nil)
        self.ticket = ticket
        self.game = game
        self.lotteries = lotteries
        
        numbersStringArray = convertIntArrayToStringArray(game.myLuckyNumbers ?? [])
    }
    
    func convertIntArrayToStringArray(_ intArray: [[Int]]) -> [[String]] {
        return intArray.map { $0.map { String($0) } }
    }
    
    // Required initializer for compatibility with storyboards
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.main400
        setupNavigationBar()
        setupNavigationBarTitle()
        fetchLotteriesPatterns()
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = Appearance.main400
        collectionView.register(TicketLuckyNumbersEditCell.self, forCellWithReuseIdentifier: "TicketLuckyNumbersEditCellId")
        
        collectionView.contentInset = UIEdgeInsets(top: 15.scale, left: 0, bottom: 30.scale, right: 0)
        
        view.addSubview(collectionView)
        view.addSubview(saveTicketButton)
        
        // Add activity indicator to save button
        saveTicketButton.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: saveTicketButton.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: saveTicketButton.centerYAnchor).isActive = true
        
        setupConstraints()
        updateSaveButtonState() // Initial check to set the button state based on initial data
        
        // Add keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        fetchLotteriesPatterns()

    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // CollectionView constraints
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10.scale),
            collectionView.bottomAnchor.constraint(equalTo: saveTicketButton.topAnchor, constant: -10.scale),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            saveTicketButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            saveTicketButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            saveTicketButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
        
        // Initialize the bottom constraint
        saveButtonBottomConstraint = saveTicketButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -17.5.scale)
        saveButtonBottomConstraint.isActive = true
    }
    
    @objc func saveTicketButtonTapped() {
        // Hide the title and show the activity indicator
        saveTicketButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        
        // Convert numbersStringArray to [[Int]]
        var numbersArray: [[Int]] = []
        for section in numbersStringArray {
            var intSection: [Int] = []
            for numberString in section {
                if let number = Int(numberString) {
                    intSection.append(number)
                }
            }
            numbersArray.append(intSection)
        }
        
        
        // Ensure we have a ticket to modify
        guard var existingTicket = ticket else { return }
        
        // Update the ticket's numbers
        existingTicket.numbers = numbersArray
        
        let lotteryId = game.lotteryId
        let date = game.date
        
        let gamesManager = GamesManager()
        gamesManager.addLuckyNumbers(lotteryId: lotteryId, date: date, numbers: numbersArray) { [weak self] result in
            DispatchQueue.main.async {
                // Stop the activity indicator and show the title
                self?.activityIndicator.stopAnimating()
                self?.saveTicketButton.setTitle("EditLuckyNumbersViewController.SaveButton".localized, for: .normal)
            }
            switch result {
            case .success(let success):
                if success {
                    let gamesManager = GamesManager()
                    gamesManager.fetchNextGames(stateId: nil, forceUpdate: true) { [weak self] result in
                        DispatchQueue.main.async {
                            if let luckyNumbersViewController = self?.navigationController?.viewControllers[1] {
                                self?.navigationController?.popToViewController(luckyNumbersViewController, animated: true)
                            }
                        }
                    }
                    gamesManager.fetchPastGames(stateId: nil, forceUpdate: true) { [weak self] result in
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self?.showErrorAlert(message: "EditLuckyNumbersViewController.ErrorMessage".localized)
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    self?.showErrorAlert(message: "EditLuckyNumbersViewController.ErrorMessage".localized)
                }
            }
        }
    }
    
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "EditLuckyNumbersViewController.ErrorTitle".localized, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func setupNavigationBarTitle() {
        guard let backButtonImage = UIImage(named: "luckyNumberEmptyHeader") else { return }
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.backgroundColor = .clear
        backButton.frame = CGRect(x: 0, y: 0, width: 140, height: 26)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = barButtonItem
    }
    
    @objc func handleBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = Appearance.mono200
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Appearance.mono200]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TicketLuckyNumbersEditCellId", for: indexPath) as! TicketLuckyNumbersEditCell
        if let ticket = self.ticket {
            if let pattern : LotteryPattern = lotteryPatterns.filter {$0.id == ticket.lotteryId }.first {
                cell.bonusIdx = pattern.bonusIdx
            }
            cell.lotteryPatterns = lotteryPatterns
            cell.lotteries = self.lotteries
            cell.configure(ticket: ticket)
        }
        cell.delegate = self
        cell.parentvc = self
        cell.layer.cornerRadius = 20.scale
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
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
            
            return CGSize(width: 343.scale,
                          height: CGFloat(numbersStringArray.count) * (cellWidth + 6).scale + 41.scale + 15.scale + 50.scale + 30.scale + 85.scale )
        } else {
            return CGSize(width: 343.scale,
                          height: CGFloat(numbersStringArray.count) * (40 + 10).scale + 41.scale + 61.scale + 50.scale + 30.scale + 85.scale )
        }
    }
    
    // Validation method to check if all numbers are valid
    private func areAllNumbersValid() -> Bool {
        for section in numbersStringArray {
            for i in 1..<section.count {
                if Int(section[i]) == nil {
                    return false
                }
            }
        }
        if numbersStringArray.count == 0 {
            return false
        }
        return true
    }
    
    // Method to update save button state based on validation
    private func updateSaveButtonState() {
        let allNumbersValid = areAllNumbersValid()
        saveTicketButton.isEnabled = allNumbersValid
        saveTicketButton.backgroundColor = allNumbersValid ? Appearance.main100 : .gray // Change the color to gray if not valid
    }
    
    // Handle keyboard appearance
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height  - view.safeAreaInsets.bottom
            saveButtonBottomConstraint.constant = -keyboardHeight * 0.75
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // Handle keyboard disappearance
    @objc private func keyboardWillHide(_ notification: Notification) {
        saveButtonBottomConstraint.constant = -30.scale
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension EditLuckyNumbersViewController: EditTicketViewControllerDelegate {
    func updateSizeOfEditCell(numbersStringArray: [[String]]) {
        self.numbersStringArray = numbersStringArray
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension EditLuckyNumbersViewController {
    func removeTicketButtonTapped() {
        // Convert numbersStringArray to [[Int]]
        var numbersArray: [[Int]] = []
        for section in numbersStringArray {
            var intSection: [Int] = []
            for numberString in section {
                if let number = Int(numberString) {
                    intSection.append(number)
                }
            }
            numbersArray.append(intSection)
        }
        
        // Ensure we have a ticket to modify
        guard var existingTicket = ticket else { return }
        
        // Update the ticket's numbers
        existingTicket.numbers = numbersArray
        
        let lotteryId = game.lotteryId
        let date = game.date
        
        let gamesManager = GamesManager()
        gamesManager.addLuckyNumbers(lotteryId: lotteryId, date: date, numbers: numbersArray) { [weak self] result in
            switch result {
            case .success(let success):
                if success {
                    DispatchQueue.main.async {
                        self?.navigationController?.popViewController(animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showErrorAlert(message: "EditLuckyNumbersViewController.ErrorMessage".localized)
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    self?.showErrorAlert(message: "EditLuckyNumbersViewController.ErrorMessage".localized)
                }
            }
        }
    }
}
