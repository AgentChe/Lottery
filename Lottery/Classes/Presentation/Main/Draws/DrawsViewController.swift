//
//  DrawsViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/6/24.
//
import UIKit
 
class DrawsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var segmentedControl: SSSegmentedControl = SSSegmentedControl()
    private var nextDrawsCollectionView: UICollectionView!
    private var pastDrawsCollectionView: UICollectionView!
    
    private var nextDraws: [Game] = [] {
        didSet {
            
        }
    }
    private var pastDraws: [Game] = []
    
    private let gamesManager: GamesManagerProtocol = GamesManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.main600
        setupSegmentedControl()
        setupCollectionViews()
        setupLayoutConstraints()
        
        fetchNextGames()
        fetchPastGames()
    }
}

// MARK: - UI Setup
private extension DrawsViewController {
    func setupSegmentedControl() {
        segmentedControl.currentIndexTitleColor = UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1)
        segmentedControl.otherIndexTitleColor = UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1)
        segmentedControl.currentIndexBackgroundColor = UIColor(red: 0.9, green: 0.9, blue: 1, alpha: 1)
        segmentedControl.cornerRadius = 30
        segmentedControl.buttonPadding = 10
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
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 40, height: 200)
        layout.minimumLineSpacing = 20
        
        nextDrawsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        nextDrawsCollectionView.backgroundColor = .white
        nextDrawsCollectionView.delegate = self
        nextDrawsCollectionView.dataSource = self
        nextDrawsCollectionView.register(NextGameCell.self, forCellWithReuseIdentifier: "NextGameCell")
        nextDrawsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextDrawsCollectionView)
        
        pastDrawsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
            segmentedControl.heightAnchor.constraint(equalToConstant: 50),
            
            nextDrawsCollectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            nextDrawsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextDrawsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextDrawsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            pastDrawsCollectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            pastDrawsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pastDrawsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pastDrawsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
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
            cell.configure(game: game)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PastGameCell", for: indexPath) as! PastGameCell
            let game = pastDraws[indexPath.item]
            cell.configure(game: game)
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
    
    func fetchNextGames() {
        gamesManager.fetchNextGames(stateId: nil) { [weak self] result in
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
    
    func fetchPastGames() {
        gamesManager.fetchPastGames(stateId: nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let games):
                    self?.pastDraws = games
                    self?.pastDrawsCollectionView.reloadData()
                case .failure(let error):
                    print("Failed to fetch past games: \(error)")
                }
            }
        }
    }
}
