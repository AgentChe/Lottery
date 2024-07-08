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
    private var scanButton: UIButton! // Adding the scan button
    private var noTicketsImageView: UIImageView! // Adding the no tickets image view
    private let ticketsManager: TicketsManagerProtocol = TicketsManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.main400
        setupNavigationBarTitle()
        setupNavigationBarAppearance()
        setupNoTicketsImageView()
        setupCollectionView()
        setupScanButton()  // Setup scan button
        setupLayoutConstraints()  // Apply layout constraints including scan button and no tickets image view
        fetchTickets()
    }
    
    private func setupNavigationBarAppearance() {
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

    private func setupScanButton() {
        scanButton = UIButton(type: .custom)
        if let scanImage = UIImage(named: "Scan.BeginButton") {
            scanButton.setImage(scanImage, for: .normal)
        }
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.backgroundColor = .clear
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        
        view.addSubview(scanButton)
    }

    private func setupNoTicketsImageView() {
        noTicketsImageView = UIImageView(image: UIImage(named: "Tickets.NoSavedTickets"))
        noTicketsImageView.translatesAutoresizingMaskIntoConstraints = false
        noTicketsImageView.contentMode = .scaleAspectFit
        
        view.addSubview(noTicketsImageView)
    }

    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            scanButton.heightAnchor.constraint(equalToConstant: 70.scale),
            scanButton.widthAnchor.constraint(equalToConstant: 70.scale),
            scanButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -13.scale),
            scanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),

            noTicketsImageView.widthAnchor.constraint(equalToConstant: 344.scale),
            noTicketsImageView.heightAnchor.constraint(equalToConstant: 209.scale),
            noTicketsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noTicketsImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.isTranslucent = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = .red
        navigationController?.navigationBar.isTranslucent = false
        if let navigationController = getRootViewController() as? NavigationController,
           let mainViewController = navigationController.viewControllers.first as? MainViewController {
            updateMainViewControllerConstraints(for: mainViewController, newConstant: 0.scale)
            fetchTickets()
        }
    }

    private func setupNavigationBarTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "TicketsViewController.MyTickets".localized
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
                    if self?.tickets.count != 0 {
                        self?.collectionView.isHidden = false
                        self?.noTicketsImageView.isHidden = true
                    } else {
                        self?.collectionView.isHidden = true
                        self?.noTicketsImageView.isHidden = false
                    }
                case .failure:
                    if self?.tickets.count != 0 {
                        self?.collectionView.isHidden = false
                        self?.noTicketsImageView.isHidden = true
                    } else {
                        self?.collectionView.isHidden = true
                        self?.noTicketsImageView.isHidden = false
                    }
                    self?.showError()
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
        cell.numbersCollectionView.reloadData()
        cell.setNeedsDisplay()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let ticket = tickets[indexPath.item]
        let ticketDate = Date(timeIntervalSince1970: ticket.date)
        let now = Date()
        let numbersCount = ticket.numbers.count

        let isNextDraw = ticketDate > now
        let baseHeight: CGFloat = isNextDraw ? 266.scale : 210.scale
        let additionalHeight: CGFloat = 55.scale * CGFloat(max(0, numbersCount - 1))

        let cellHeight = baseHeight + additionalHeight

        return CGSize(width: view.frame.width - 20.scale, height: cellHeight)
    }

    func showError() {
        let alert = UIAlertController(title: "TicketsViewController.ErrorTitle".localized, message: "TicketsViewController.ErrorMessage".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - TicketCellDelegate Method
    func editButtonTapped(for cell: TicketCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let ticket = tickets[indexPath.item]
        let editVC = EditTicketViewController(ticket: ticket)
        navigationController?.pushViewController(editVC, animated: true)
    }

    @objc func scanButtonTapped() {
        let scanOnboardingViewController = ScanOnboardingViewController.make()
        
        // Check if the current view controller is embedded in a navigation controller
        if let navigationController = self.navigationController {
            navigationController.pushViewController(scanOnboardingViewController, animated: true)
            
            if let navigationController = getRootViewController() as? NavigationController,
               let mainViewController = navigationController.viewControllers.first as? MainViewController {
                updateMainViewControllerConstraints(for: mainViewController)
            }
        } else {
            // If not, present the view controller modally as a fallback
            present(scanOnboardingViewController, animated: true, completion: nil)
        }
    }

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
