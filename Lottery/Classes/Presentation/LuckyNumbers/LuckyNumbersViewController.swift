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
    // Declare all views as class properties
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "LuckyNumbers.Add"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
        return label
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
        return button
    }()
    private var nextDrawsCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.main400
        setupNavigationBarTitle()
        setupViews()
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
                    self?.nextDraws = games
                    delay(0.05) {
                      //  self?.nextDrawsCollectionView.reloadData()
                    }
                case .failure(let error):
                    print("Failed to fetch next games: \(error)")
                }
            }
        }
    }
    func setupNavigationBarTitle() {
        // Create the title label
        let titleLabel = UILabel()
        titleLabel.text = "LUCKY NUMBERS"
        titleLabel.textColor = Appearance.mono200
        titleLabel.font = Fonts.Inter.bold(size: 20.scale)
        
        // Set intrinsic size for proper layout
        titleLabel.sizeToFit()
        
        // Create a UIBarButtonItem with the custom label
        let leftBarItem = UIBarButtonItem(customView: titleLabel)
        
        navigationItem.leftBarButtonItem = leftBarItem
        
        // Create a right bar button item for the menu
        if let menuImage = UIImage(named: "Menu") {
            // Create the UIImageView with aspect fit
            let menuImageView = UIImageView(image: menuImage)
            menuImageView.contentMode = .scaleAspectFit
            
            // Set the height of the image view to match the title label's height
            let titleHeight = titleLabel.intrinsicContentSize.height
            menuImageView.frame = CGRect(x: 0.scale, y: 0.scale, width: titleHeight, height: titleHeight)
            
            // Wrap the image view in a UIView to manage its layout
            let menuContainerView = UIView(frame: menuImageView.frame)
            menuContainerView.addSubview(menuImageView)
            
            // Create the UIBarButtonItem with the custom view
            let rightBarItem = UIBarButtonItem(customView: menuContainerView)
            navigationItem.rightBarButtonItem = rightBarItem
            
            // Add tap gesture to the image view for menu action
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMenuTap))
            menuContainerView.isUserInteractionEnabled = true
            menuContainerView.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func handleMenuTap() {
        let menuVC = MenuViewController()
        let navController = NavigationController(rootViewController: menuVC)
        navController.modalPresentationStyle = .fullScreen
        
        // Present the navigation controller
        present(navController, animated: true, completion: nil)
    }
    
    func setupViews() {
        // Add subviews to the main view
        view.addSubview(imageView)
        view.addSubview(firstLabel)
        view.addSubview(secondLabel)
        view.addSubview(addButton)
        
        // Layout the views using Auto Layout
        NSLayoutConstraint.activate([
            // Center the image view horizontally and vertically
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: 130.scale),
            imageView.heightAnchor.constraint(equalToConstant: 130.scale),
            
            // Place the first label below the image view
            firstLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20.scale),
            firstLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Place the second label below the first label
            secondLabel.topAnchor.constraint(equalTo: firstLabel.bottomAnchor, constant: 8.scale),
            secondLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Place the button below the second label
            addButton.topAnchor.constraint(equalTo: secondLabel.bottomAnchor, constant: 20.scale),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func addButtonTapped() {
        // Handle the add button tap
     let selectTheGameViewController = SelectTheGameViewController()
        if let navigationController = navigationController {
            navigationController.pushViewController(selectTheGameViewController, animated: true)
        } else {
            // If not in a navigation controller, present it modally
            present(selectTheGameViewController, animated: true, completion: nil)
        }
    }
}
