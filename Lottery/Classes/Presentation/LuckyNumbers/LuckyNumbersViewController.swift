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
        button.isEnabled = true // Initially disabled
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
    
    private lazy var nextDrawsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16.scale
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        if #available(iOS 17.4, *) {
            collectionView.bouncesVertically = true
        } else {
            // Fallback on earlier versions
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
                    self?.nextDrawsCollectionView.isHidden = self?.nextDraws.isEmpty ?? true
                    self?.addLuckyNumbersButton.isHidden = self?.nextDraws.isEmpty ?? true
                    self?.imageView.isHidden = !(self?.nextDraws.isEmpty ?? false)
                    self?.firstLabel.isHidden = !(self?.nextDraws.isEmpty ?? false)
                    self?.secondLabel.isHidden = !(self?.nextDraws.isEmpty ?? false)
                    self?.addButton.isHidden = !(self?.nextDraws.isEmpty ?? false)
                    self?.nextDrawsCollectionView.reloadData()
                case .failure:
                    print("LuckyNumbersViewController.ErrorFetchGames".localized)
                    self?.nextDrawsCollectionView.isHidden = true
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
        // Create a custom back button
        let backButton = UIButton(type: .custom)
        
        // Set the custom image for the button
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
        // Replace the default back button with the custom button
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.hidesBackButton = true // Hide the default back button
    }
    @objc private func customBackButtonTapped() {
        // Perform back navigation
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleMenuTap() {
        let menuVC = MenuViewController()
        let navController = NavigationController(rootViewController: menuVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    func setupViews() {
        view.addSubview(imageView)
        view.addSubview(firstLabel)
        view.addSubview(secondLabel)
        view.addSubview(addButton)
        view.addSubview(nextDrawsCollectionView)
        view.addSubview(addLuckyNumbersButton)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50.scale),
            imageView.widthAnchor.constraint(equalToConstant: 130.scale),
            imageView.heightAnchor.constraint(equalToConstant: 130.scale),
            
            firstLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20.scale),
            firstLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            secondLabel.topAnchor.constraint(equalTo: firstLabel.bottomAnchor, constant: 8.scale),
            secondLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addButton.topAnchor.constraint(equalTo: secondLabel.bottomAnchor, constant: 20.scale),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nextDrawsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nextDrawsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nextDrawsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nextDrawsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            addLuckyNumbersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            addLuckyNumbersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            addLuckyNumbersButton.heightAnchor.constraint(equalToConstant: 44.scale),
            addLuckyNumbersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.scale)
            
            
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
        cell.configure(game: game, lotteries: lotteries)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.scale, left: 16.scale, bottom: 70.scale, right: 16.scale)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let game = nextDraws[indexPath.item]
        var cellHeight = 210.scale
        if let myLuckyNumbers = game.myLuckyNumbers {
            if myLuckyNumbers.isEmpty {
                cellHeight = 155.scale
            } else {
                cellHeight = 270.scale + CGFloat(max(0, myLuckyNumbers.count)) * CGFloat(54.scale)
            }
        }
        return CGSize(width: collectionView.frame.width - 32, height: cellHeight)
    }
}

extension LuckyNumbersViewController {
    func updateMainViewControllerConstraints(for mainViewController: MainViewController, newConstant: CGFloat = ScreenSize.isIphoneXFamily ? 100.scale : 80.scale) {
        let mainView = mainViewController.mainView
        let tabView = mainView.tabView
        
        if mainView.tabViewBottomConstraint?.constant != newConstant {
            // Deactivate and nil the old constraint if it's different
            if let oldTabViewBottomConstraint = mainView.tabViewBottomConstraint {
                oldTabViewBottomConstraint.isActive = false
                mainView.tabViewBottomConstraint = nil
            }
            
            // Create and activate the new constraint
            let newTabViewBottomConstraint = tabView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: newConstant)
            mainView.tabViewBottomConstraint = newTabViewBottomConstraint
            newTabViewBottomConstraint.isActive = true
            
            // Call layoutIfNeeded to apply the changes
            mainView.layoutIfNeeded()
        }
    }
}
