//
//  TicketsViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/11/24.
//

import UIKit

class TicketsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var tickets = [Ticket]()
    private var collectionView: UICollectionView!
    private let ticketsManager: TicketsManagerProtocol = TicketsManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tickets"
        view.backgroundColor = .red
        setupNavigationBarTitle()
        setupCollectionView()
        fetchTickets()
        
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: view.frame.width - 20, height: 150) // Adjust the height based on your design
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(TicketCell.self, forCellWithReuseIdentifier: TicketCell.reuseIdentifier)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    func setupNavigationBarTitle() {
        // Create the title label
        let titleLabel = UILabel()
        titleLabel.text = "MY TICKETS"
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
            menuImageView.frame = CGRect(x: 0, y: 0, width: titleHeight, height: titleHeight)
            
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
    private func fetchTickets() {
        
        ticketsManager.listTickets() { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tickets):
                    self?.tickets = tickets
                    self?.collectionView.reloadData()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    @objc func handleMenuTap() {
        let menuVC = MenuViewController()
        let navController = NavigationController(rootViewController: menuVC)
        navController.modalPresentationStyle = .fullScreen
        
        // Present the navigation controller
        present(navController, animated: true, completion: nil)
    }
    // MARK: - UICollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tickets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TicketCell.reuseIdentifier, for: indexPath) as! TicketCell
        cell.configure(with: tickets[indexPath.item])
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 20, height: 150) // Adjust the height based on your design
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

