//
//  DrawsViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/6/24.
//


import UIKit

class DrawsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var segmentedControl: SSSegmentedControl = SSSegmentedControl()
    private var profileManager: ProfileManagerProtocol = ProfileManager()
    private var contentManager: ContentManagerProtocol = ContentManager()
    private var nextDrawsCollectionView: UICollectionView!
    private var pastDrawsCollectionView: UICollectionView!
    
    private var nextDraws: [Game] = []
    private var pastDraws: [Game] = []
    private var lotteries: [Lottery] = []
    
    private let gamesManager: GamesManagerProtocol = GamesManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.main600
        setupSegmentedControl()
        setupCollectionViews()
        setupLayoutConstraints()
        
        fetchStateAndGames()
    }
}

// MARK: - UI Setup
private extension DrawsViewController {
    func setupSegmentedControl() {
        segmentedControl.currentIndexTitleColor = UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1)
        segmentedControl.otherIndexTitleColor = UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1)
        segmentedControl.currentIndexBackgroundColor = UIColor(red: 0.9, green: 0.9, blue: 1, alpha: 1)
        segmentedControl.cornerRadius = 38
        segmentedControl.buttonPadding = 10
        segmentedControl.buttonCornerRadius = 32
        segmentedControl.numberOfSegments = 2
        segmentedControl.segmentsTitle = "Next Draws,Past Draws"
        segmentedControl.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        segmentedControl.layer.borderColor = UIColor.clear.cgColor
        
        segmentedControl.didTapSegment = { [weak self] index in
            self?.segmentedControlChanged(index: index)
        }
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(segmentedControl)
    }
    
    func setupCollectionViews() {
        let nextDrawsCollectionViewLayout = UICollectionViewFlowLayout()
        nextDrawsCollectionViewLayout.scrollDirection = .vertical
        nextDrawsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: nextDrawsCollectionViewLayout)
        nextDrawsCollectionView.backgroundColor = .clear
        nextDrawsCollectionView.delegate = self
        nextDrawsCollectionView.dataSource = self
        nextDrawsCollectionView.register(NextGameCell.self, forCellWithReuseIdentifier: "NextGameCell")
        nextDrawsCollectionView.showsVerticalScrollIndicator = false
        nextDrawsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextDrawsCollectionView)
        
        let pastDrawsCollectionViewLayout = UICollectionViewFlowLayout()
        pastDrawsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: pastDrawsCollectionViewLayout)
        pastDrawsCollectionView.backgroundColor = .clear
        pastDrawsCollectionView.delegate = self
        pastDrawsCollectionView.dataSource = self
        pastDrawsCollectionView.register(PastGameCell.self, forCellWithReuseIdentifier: "PastGameCell")
        pastDrawsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pastDrawsCollectionView)
        
        pastDrawsCollectionView.isHidden = true
    }
    
    func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            segmentedControl.heightAnchor.constraint(equalToConstant: 80),
            
            nextDrawsCollectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 0),
            nextDrawsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextDrawsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextDrawsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            
            pastDrawsCollectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 0),
            pastDrawsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pastDrawsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pastDrawsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
}
// MARK: - CollectionView Delegate FlowLayout
extension DrawsViewController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = 343 // Width is fixed to the collection view width with padding
        
        var cellHeight: CGFloat
        
        if collectionView == nextDrawsCollectionView {
            return CGSize(width: 343, height: 147)
        } else {
            print("CV: \(collectionView)")
            // For Past Draws
            let game = pastDraws[indexPath.item]
            cellHeight = 176  // Default height
            if let myLuckyNumbers = game.myLuckyNumbers {
                if myLuckyNumbers.isEmpty {
                    cellHeight = 154
                } else {
                    cellHeight = 200 + CGFloat(max(0, myLuckyNumbers.count - 1) * 30)
                }
            }
        }
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // Set the minimum line spacing (vertical spacing between rows)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40 // Adjust as needed for spacing between rows
    }
    
    // Set the minimum interitem spacing (horizontal spacing between items in the same row)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 40 // Adjust as needed for spacing between columns (usually for multiple columns per row)
    }
    
    // Set the section insets (padding around the section)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 40, left: 0, bottom: 10, right: 0) // Adjust insets as needed
    }
}
// MARK: - Public Extension
extension DrawsViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == nextDrawsCollectionView {
            return nextDraws.count
        } else {
            return pastDraws.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == nextDrawsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NextGameCell", for: indexPath) as! NextGameCell
            let game = nextDraws[indexPath.item]
            cell.configure(game: game, lotteries: lotteries)
            cell.layer.cornerRadius = 30
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PastGameCell", for: indexPath) as! PastGameCell
            let game = pastDraws[indexPath.item]
            cell.configure(game: game, lotteries: lotteries)
            return cell
        }
    }
}

// MARK: - Private Extension
private extension DrawsViewController {
    func segmentedControlChanged(index: Int) {
        if index == 0 {
            nextDrawsCollectionView.isHidden = false
            pastDrawsCollectionView.isHidden = true
        } else {
            nextDrawsCollectionView.isHidden = true
            pastDrawsCollectionView.isHidden = false
        }
    }
    
    func fetchStateAndGames() {
        profileManager.getProfile(forceUpdate: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    if let stateId = profile.state {
                        self?.fetchLotteries(for: stateId)
                        
                    } else {
                        print("State ID is not available in profile")
                    }
                case .failure(let error):
                    print("Failed to fetch profile: \(error)")
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
                        self?.nextDrawsCollectionView.reloadData()
                    }
                case .failure(let error):
                    print("Failed to fetch next games: \(error)")
                }
            }
        }
    }
    
    func fetchPastGames(for stateId: Int) {
        gamesManager.fetchPastGames(stateId: stateId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let games):
                    self?.pastDraws = games
                    delay(0.05) {
                        self?.pastDrawsCollectionView.reloadData()
                    }
                case .failure(let error):
                    print("Failed to fetch past games: \(error)")
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
                    self?.fetchPastGames(for: stateId)
                case .failure(let error):
                    print("Failed to fetch lotteries: \(error)")
                }
            }
        }
    }
}
