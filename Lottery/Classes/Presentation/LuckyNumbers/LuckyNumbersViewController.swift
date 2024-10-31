//
//  LuckyNumbersViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/26/24.
//

import UIKit

final class LuckyNumbersViewController: UIViewController {
    let gamesManager = GamesManager()
    private var contentManager: ContentManagerProtocol = ContentManager()
    private var nextDraws: [Game] = []
    private var lotteries: [Lottery] = []
    var lotteryPatterns: [LotteryPattern] = []
    
    private let backgroundfullView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "TicketsVCBackgroundImage")
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "LuckyNumbers.Add"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private let firstLabel: UILabel = {
        let label = UILabel()
        label.text = "LuckyNumbersViewController.AddLuckyNumbers".localized
        label.textColor = Appearance.mono200
        label.font = Fonts.Inter.bold(size: 16.scale)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 200.scale).isActive = true
        label.heightAnchor.constraint(equalToConstant: 23.scale).isActive = true
        label.isHidden = true
        return label
    }()
    
    private let secondLabel: UILabel = {
        let label = UILabel()
        label.text = "LuckyNumbersViewController.NoLuckyNumbers".localized
        label.textColor = Appearance.main300
        label.font = Fonts.Inter.regular(size: 14.scale)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 200.scale).isActive = true
        label.heightAnchor.constraint(equalToConstant: 40.scale).isActive = true
        label.isHidden = true
        return label
    }()
    
    private let addLuckyNumbersButton: UIButton = {
        let button = UIButton()
        button.setTitle("LuckyNumbersViewController.AddLuckyNumbersButton".localized, for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.layer.cornerRadius = 22.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("LuckyNumbersViewController.AddButton".localized, for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 16.scale)
        button.layer.cornerRadius = 22.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 195.scale).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44.scale).isActive = true
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var luckyNumbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16.scale
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        if #available(iOS 17.4, *) {
            collectionView.bouncesVertically = true
        }
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isHidden = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(LuckyNumbersCell.self, forCellWithReuseIdentifier: "LuckyNumbersCell")
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.main400
        setupNavigationBarTitle()
        setupViews()
        fetchLotteries(for: nil)
        fetchLotteriesPatterns()
    }
    
    func fetchLotteriesPatterns(for stateId: Int? = nil) {
        contentManager.fetchLotteriesPattern(forceUpdate: false, stateId: nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let patterns):
                    self?.lotteryPatterns = patterns
                    self?.luckyNumbersCollectionView.reloadData()
                case .failure(let error):
                    print("Failed to fetch lottery patterns: \(error)")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLotteries(for: nil)
        
        if let navigationController = getRootViewController() as? NavigationController,
           let mainViewController = navigationController.viewControllers.first as? MainViewController {
            updateMainViewControllerConstraints(for: mainViewController, newConstant: 0.scale)
        }
    }
    
    func fetchLotteries(for stateId: Int?) {
        contentManager.fetchLotteries(forceUpdate: false, stateId: nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lotteries):
                    self?.lotteries = lotteries
                    self?.fetchNextGames(for: stateId ?? nil)
                case .failure:
                    print("LuckyNumbersViewController.ErrorFetchLotteries".localized)
                }
            }
        }
    }
    
    func fetchNextGames(for stateId: Int?) {
        gamesManager.fetchNextGames(stateId: stateId ?? nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let games):
                    self?.nextDraws = games.filter { $0.myLuckyNumbers?.isEmpty == false }
                    let isEmpty = self?.nextDraws.isEmpty ?? true
                    self?.luckyNumbersCollectionView.isHidden = isEmpty
                    self?.addLuckyNumbersButton.isHidden = isEmpty
                    self?.imageView.isHidden = !isEmpty
                    self?.firstLabel.isHidden = !isEmpty
                    self?.secondLabel.isHidden = !isEmpty
                    self?.addButton.isHidden = !isEmpty
                    self?.luckyNumbersCollectionView.reloadData()
                case .failure:
                    print("LuckyNumbersViewController.ErrorFetchGames".localized)
                    self?.luckyNumbersCollectionView.isHidden = true
                    self?.addLuckyNumbersButton.isHidden = true
                    self?.imageView.isHidden = false
                    self?.firstLabel.isHidden = false
                    self?.secondLabel.isHidden = false
                    self?.addButton.isHidden = false
                }
            }
        }
    }
    
    func setupNavigationBarTitle() {
        let backButton = UIButton(type: .custom)
        if let image = UIImage(named: "luckyNumbersBackButtonImage") {
            backButton.setImage(image, for: .normal)
        }
        // Disable autoresizing mask translation
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.imageView?.contentMode = .scaleAspectFit
        
        // Add a target to handle back navigation
        backButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Create a container view to hold the button
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(backButton)
        
        // Set constraints for the button within the container
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 341.scale),
            backButton.heightAnchor.constraint(equalToConstant: 26.scale),
            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: -35.scale),
            backButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        // Set constraints for the container view
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: backButton.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: backButton.heightAnchor)
        ])
        
        // Create a UIBarButtonItem with the container view
        let backButtonItem = UIBarButtonItem(customView: containerView)
      
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear
        
        // Replace the default back button with the custom button
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.hidesBackButton = true // Hide the default back button
    }
    
    @objc private func customBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupViews() {
        view.addSubview(backgroundfullView)
        
        [imageView, firstLabel, secondLabel, addButton, luckyNumbersCollectionView, addLuckyNumbersButton].forEach {
            backgroundfullView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            backgroundfullView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundfullView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundfullView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundfullView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: backgroundfullView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: backgroundfullView.centerYAnchor, constant: -50.scale),
            imageView.widthAnchor.constraint(equalToConstant: 130.scale),
            imageView.heightAnchor.constraint(equalToConstant: 130.scale),
            
            firstLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20.scale),
            firstLabel.centerXAnchor.constraint(equalTo: backgroundfullView.centerXAnchor),
            
            secondLabel.topAnchor.constraint(equalTo: firstLabel.bottomAnchor, constant: 8.scale),
            secondLabel.centerXAnchor.constraint(equalTo: backgroundfullView.centerXAnchor),
            
            addButton.topAnchor.constraint(equalTo: secondLabel.bottomAnchor, constant: 20.scale),
            addButton.centerXAnchor.constraint(equalTo: backgroundfullView.centerXAnchor),
            
            luckyNumbersCollectionView.topAnchor.constraint(equalTo: backgroundfullView.safeAreaLayoutGuide.topAnchor),
            luckyNumbersCollectionView.leadingAnchor.constraint(equalTo: backgroundfullView.leadingAnchor),
            luckyNumbersCollectionView.trailingAnchor.constraint(equalTo: backgroundfullView.trailingAnchor),
            luckyNumbersCollectionView.bottomAnchor.constraint(equalTo: backgroundfullView.bottomAnchor),
            
            addLuckyNumbersButton.leadingAnchor.constraint(equalTo: backgroundfullView.leadingAnchor, constant: 20.scale),
            addLuckyNumbersButton.trailingAnchor.constraint(equalTo: backgroundfullView.trailingAnchor, constant: -20.scale),
            addLuckyNumbersButton.heightAnchor.constraint(equalToConstant: 44.scale),
            addLuckyNumbersButton.bottomAnchor.constraint(equalTo: backgroundfullView.safeAreaLayoutGuide.bottomAnchor, constant: -10.scale)
        ])
    }
    
    @objc func addButtonTapped() {
        if !SessionManager().hasActiveSubscriptions() {
            let selectTheGameViewController = SelectTheGameViewController()
            if let navigationController = navigationController {
                navigationController.pushViewController(selectTheGameViewController, animated: true)
            } else {
                present(selectTheGameViewController, animated: true, completion: nil)
            }
        } else {
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
}

extension LuckyNumbersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nextDraws.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LuckyNumbersCell", for: indexPath) as? LuckyNumbersCell else {
            fatalError("Could not dequeue cell with identifier: LuckyNumbersCell")
        }
        
        let game = nextDraws[indexPath.item]
        if let pattern = lotteryPatterns.first(where: { $0.id == game.lotteryId }) {
            cell.bonusIdx = pattern.bonusIdx
        }
        cell.lotteryPatterns = lotteryPatterns
        cell.configure(game: game, lotteries: lotteries)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16.scale, left: 16.scale, bottom: 70.scale, right: 16.scale)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let game = nextDraws[indexPath.item]
        var cellHeight = 210.scale
        if let myLuckyNumbers = game.myLuckyNumbers, !myLuckyNumbers.isEmpty {
            cellHeight = 270.scale + CGFloat(max(0, myLuckyNumbers.count)) * (40.scale + 16.scale)
        } else {
            cellHeight = 155.scale
        }
        return CGSize(width: collectionView.frame.width - 32, height: cellHeight)
    }
}

extension LuckyNumbersViewController {
    func updateMainViewControllerConstraints(for mainViewController: MainViewController, newConstant: CGFloat = ScreenSize.isIphoneXFamily ? 100.scale : 80.scale) {
        let mainView = mainViewController.mainView
        let tabView = mainView.tabView
        
        if mainView.tabViewBottomConstraint?.constant != newConstant {
            mainView.tabViewBottomConstraint?.isActive = false
            mainView.tabViewBottomConstraint = nil
            
            let newTabViewBottomConstraint = tabView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: newConstant)
            mainView.tabViewBottomConstraint = newTabViewBottomConstraint
            newTabViewBottomConstraint.isActive = true
            
            mainView.layoutIfNeeded()
        }
    }
}
