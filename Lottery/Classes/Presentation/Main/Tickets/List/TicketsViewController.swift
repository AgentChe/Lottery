//
//  TicketsViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/11/24.
//

import UIKit

class TicketsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TicketCellDelegate {

    private var tickets = [Ticket]()
    private var collectionView: UICollectionView!
    private let ticketsManager: TicketsManagerProtocol = TicketsManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupNavigationBarTitle()
        setupNavigationBarAppearance()
        setupCollectionView()
        fetchTickets()
    }
    private func setupNavigationBarAppearance() {
          // Set the navigation bar to a solid color
        navigationController?.navigationBar.barTintColor = Appearance.main400 // Set to your desired color
          
          // Disable translucency
          navigationController?.navigationBar.isTranslucent = false
          
          // Optionally remove the shadow image for a cleaner look
          navigationController?.navigationBar.shadowImage = UIImage()
          
          // Set the navigation bar title color to ensure visibility
          navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
          
          // Ensure the custom navigation items like title and right bar button appear as intended
          setupNavigationBarTitle()
      }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20.scale
        layout.minimumInteritemSpacing = 20.scale
        layout.itemSize = CGSize(width: view.frame.width - 20.scale, height: 150.scale)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(TicketCell.self, forCellWithReuseIdentifier: TicketCell.reuseIdentifier)

        collectionView.contentInset = UIEdgeInsets(top: 30.scale, left: 0, bottom: 30.scale, right: 0)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupNavigationBarTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "MY TICKETS"
        titleLabel.textColor = Appearance.mono200
        titleLabel.font = Fonts.Inter.bold(size: 20.scale)
        
        titleLabel.sizeToFit()
        
        let leftBarItem = UIBarButtonItem(customView: titleLabel)
        
        navigationItem.leftBarButtonItem = leftBarItem
        
        if let menuImage = UIImage(named: "Menu") {
            let menuImageView = UIImageView(image: menuImage)
            menuImageView.contentMode = .scaleAspectFit
            
            let titleHeight = titleLabel.intrinsicContentSize.height
            menuImageView.frame = CGRect(x: 0, y: 0, width: titleHeight, height: titleHeight)
            
            let menuContainerView = UIView(frame: menuImageView.frame)
            menuContainerView.addSubview(menuImageView)
            
            let rightBarItem = UIBarButtonItem(customView: menuContainerView)
            navigationItem.rightBarButtonItem = rightBarItem
            
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
                    self?.tickets = tickets.sorted(by: { $0.date > $1.date })
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
        
        present(navController, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tickets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TicketCell.reuseIdentifier, for: indexPath) as! TicketCell
        cell.configure(with: tickets[indexPath.item])
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let ticket = tickets[indexPath.item]
        let ticketDate = Date(timeIntervalSince1970: ticket.date)
        let now = Date()
        let numbersCount = ticket.numbers.count

        let isNextDraw = ticketDate > now
        let baseHeight: CGFloat = isNextDraw ? 256.scale : 196.scale
        let additionalHeight: CGFloat = 58.scale * CGFloat(max(0, numbersCount - 1))

        let cellHeight = baseHeight + additionalHeight

        return CGSize(width: view.frame.width - 20.scale, height: cellHeight)
    }

    func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - TicketCellDelegate Method

    func editButtonTapped(for cell: TicketCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let ticket = tickets[indexPath.item]
        
        let editVC = EditTicketViewController()
        editVC.ticket = ticket
        
        navigationController?.pushViewController(editVC, animated: true)
    }
}
