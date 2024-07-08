//
//  SelectTheGameViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/26/24.
//

import UIKit

final class SelectTheGameViewController: UIViewController {
    
    private var profileManager: ProfileManagerProtocol = ProfileManager()
    private var contentManager: ContentManagerProtocol = ContentManager()
    private let gamesManager: GamesManagerProtocol = GamesManager()
    private var nextDraws: [Game] = []
    private var lotteries: [Lottery] = []
    
    // Declare UI elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SelectTheGameViewController.Title".localized
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = Appearance.main300
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 343.scale, height: 74.scale)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let selectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SelectTheGameViewController.SelectButton".localized, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.backgroundColor = Appearance.lightGrayBorderTicket
        button.layer.cornerRadius = 20.scale
        button.setTitleColor(Appearance.mono100, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    private var selectedIndexPath: IndexPath? // Keep track of selected cell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.main400
        setupNavigationBackButton()
        setupViews()
        fetchStateAndGames()
        
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
    }
    
    func setupNavigationBackButton() {
        // Create a custom back button
        let backButton = UIButton(type: .custom)
        
        // Set the custom image for the button
        if let image = UIImage(named: "Scan.SelectLottery") {
            backButton.setImage(image, for: .normal)
        }
        
        // Set the frame or size of the button as needed
        backButton.frame = CGRect(x: 0, y: 0, width: 50.scale, height: 45.scale)
        backButton.imageView?.contentMode = .scaleAspectFit
        
        // Add a target to handle back navigation
        backButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Create a UIBarButtonItem with the custom button
        let backButtonItem = UIBarButtonItem(customView: backButton)
        
        // Replace the default back button with the custom button
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.hidesBackButton = true // Hide the default back button
    }
    
    @objc private func customBackButtonTapped() {
        // Perform back navigation
        navigationController?.popViewController(animated: true)
    }
    
    private func setupViews() {
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(selectButton)
        
        // Register cell for collection view
        collectionView.register(SelectGameCell.self, forCellWithReuseIdentifier: "SelectGameCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Collection view constraints
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: selectButton.topAnchor, constant: -20),
            
            // Select button constraints
            selectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            selectButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
    }
    
    @objc private func selectButtonTapped() {
        guard let selectedIndexPath = selectedIndexPath else { return }
        let selectedGame = nextDraws[selectedIndexPath.row]
        let pictureUrl = URL(string: "https://example.com")
        
        let ticket: Ticket = Ticket(id: 0,
                                    lotteryId: selectedGame.lotteryId,
                                    pictureUrl: pictureUrl,
                                    date: selectedGame.date,
                                    numbers: [])
        
        let editLuckyNumbersVC = EditLuckyNumbersViewController(ticket: ticket, game: selectedGame, lotteries: lotteries)
        navigationController?.pushViewController(editLuckyNumbersVC, animated: true)
    }
    
    func doesURLContain(_ urlString: String, word: String) -> Bool {
        return urlString.lowercased().contains(word)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension SelectTheGameViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nextDraws.count // Adjust this based on your data
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectGameCell", for: indexPath) as! SelectGameCell
        // Configure your cell here
        let timeInterval = nextDraws[indexPath.item].date
        
        // Convert TimeInterval to Date
        let date = Date(timeIntervalSince1970: timeInterval)
        
        // Convert Date to String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy" // Use the desired date format
        let dateString = dateFormatter.string(from: date)
        
        cell.configure(with: dateString,
                       game: nextDraws[indexPath.item],
                       lotteries: lotteries)
        
        // Update the cell's appearance based on selection state
        if indexPath == selectedIndexPath {
            cell.layer.borderColor = Appearance.main100.cgColor
        } else {
            cell.layer.borderColor = Appearance.lightGrayBorderTicket.cgColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Deselect the previous selected cell
        if let selectedIndexPath = selectedIndexPath {
            let previousCell = collectionView.cellForItem(at: selectedIndexPath) as! SelectGameCell
            previousCell.layer.borderColor = Appearance.lightGrayBorderTicket.cgColor
        }
        
        // Select the new cell
        selectedIndexPath = indexPath
        let selectedCell = collectionView.cellForItem(at: indexPath) as! SelectGameCell
        selectedCell.layer.borderColor = Appearance.main100.cgColor
        
        // Enable and update the select button
        selectButton.isEnabled = true
        selectButton.backgroundColor = Appearance.main100
        
        collectionView.reloadData()
    }
}

extension SelectTheGameViewController {
    func fetchStateAndGames() {
        profileManager.getProfile(forceUpdate: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    if let stateId = profile.state {
                        self?.fetchLotteries(for: stateId)
                    } else {
                        self?.showErrorAlert(message: "SelectTheGameViewController.ErrorStateIdUnavailable".localized)
                    }
                case .failure:
                    self?.showErrorAlert(message: "SelectTheGameViewController.ErrorFetchProfile".localized)
                }
            }
        }
    }
    
    func fetchNextGames(for stateId: Int) {
        gamesManager.fetchNextGames(stateId: stateId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let games):
                    self?.nextDraws = games
                    delay(0.05) {
                        self?.collectionView.reloadData()
                    }
                case .failure:
                    self?.showErrorAlert(message: "SelectTheGameViewController.ErrorFetchGames".localized)
                }
            }
        }
    }
    
    func fetchLotteries(for stateId: Int) {
        contentManager.fetchLotteries(forceUpdate: false, stateId: nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lotteries):
                    self?.lotteries = lotteries
                    self?.fetchNextGames(for: stateId)
                case .failure:
                    self?.showErrorAlert(message: "SelectTheGameViewController.ErrorFetchLotteries".localized)
                }
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error".localized, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
