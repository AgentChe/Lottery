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
        label.text = "Add your lucky numbers"
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
        label.text = "You haven’t added any lucky numbers yet"
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
        button.setTitle("Add lucky numbers", for: .normal)
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
        button.setTitle("Add", for: .normal)
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
        layout.itemSize = CGSize(width: view.frame.width - 32, height: 210.scale)
        layout.minimumLineSpacing = 50.scale
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
    }
    func fetchLotteries(for stateId: Int?) {
        contentManager.fetchLotteries(forceUpdate: false, stateId: nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lotteries):
                    self?.lotteries = lotteries
                    self?.fetchNextGames(for: stateId ?? nil)
                case .failure(let error):
                    print("Failed to fetch lotteries: \(error)")
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
                    self?.nextDrawsCollectionView.isHidden = self?.nextDraws.count == 0 ? true : false
                    self?.addLuckyNumbersButton.isHidden = self?.nextDraws.count == 0 ? true : false
                    self?.imageView.isHidden = self?.nextDraws.count == 0 ? false : true
                    self?.firstLabel.isHidden = self?.nextDraws.count == 0 ? false : true
                    self?.secondLabel.isHidden = self?.nextDraws.count == 0 ? false : true
                    self?.addButton.isHidden = self?.nextDraws.count == 0 ? false : true
                    self?.nextDrawsCollectionView.reloadData()
                case .failure(let error):
                    print("Failed to fetch next games: \(error)")
                    self?.nextDrawsCollectionView.isHidden =  true
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
        let titleLabel = UILabel()
        titleLabel.text = "LUCKY NUMBERS"
        titleLabel.textColor = Appearance.mono200
        titleLabel.font = Fonts.Inter.bold(size: 20.scale)
        titleLabel.sizeToFit()
        
        let leftBarItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItem = leftBarItem
        
        if let menuImage = UIImage(named: "Menu") {
            let menuImageView = UIImageView(image: menuImage)
            menuImageView.contentMode = .scaleAspectFit
            let titleHeight = titleLabel.intrinsicContentSize.height
            menuImageView.frame = CGRect(x: 0.scale, y: 0.scale, width: titleHeight, height: titleHeight)
            let menuContainerView = UIView(frame: menuImageView.frame)
            menuContainerView.addSubview(menuImageView)
            let rightBarItem = UIBarButtonItem(customView: menuContainerView)
            navigationItem.rightBarButtonItem = rightBarItem
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMenuTap))
            menuContainerView.isUserInteractionEnabled = true
            menuContainerView.addGestureRecognizer(tapGesture)
        }
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
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
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
        let selectTheGameViewController = SelectTheGameViewController()
        if let navigationController = navigationController {
            navigationController.pushViewController(selectTheGameViewController, animated: true)
        } else {
            present(selectTheGameViewController, animated: true, completion: nil)
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
        return UIEdgeInsets(top: 50.scale, left: 16.scale, bottom: 70.scale, right: 16.scale)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        let game = nextDraws[indexPath.item]
        var cellHeight = 210.scale
        if let myLuckyNumbers = game.myLuckyNumbers {
            if myLuckyNumbers.isEmpty {
                cellHeight = 155.scale
            } else {
                cellHeight = 150.scale + CGFloat(max(0, myLuckyNumbers.count )) * CGFloat(54.scale)
            }
        }
        return CGSize(width: collectionView.frame.width - 32, height: cellHeight)
    }
}
