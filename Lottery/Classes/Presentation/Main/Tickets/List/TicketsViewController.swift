//
//  TicketsViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/11/24.
//

import UIKit

class TicketsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TicketCellDelegate {

    private var tickets = [Ticket]()
    private var scratchoffs = [ScratchOff]()
    private var ticketsCollectionView: UICollectionView!
    private var scratchoffsCollectionView: UICollectionView!
    private var scanButton: UIButton! // Adding the scan button
    private var noTicketsImageView: UIImageView! // Adding the no tickets image view
    private var noScratchOffsImageView: UIImageView! // Adding the no tickets image view
    private let ticketsManager: TicketsManagerProtocol = TicketsManager()

    private let scanScratchOffTicketButton: UIButton = {
        let button = UIButton()
        button.setTitle("Scan scratch-off ticket", for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.layer.cornerRadius = 22.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        button.isEnabled = true // Initially disabled
        button.isHidden = true
        return button
    }()
    
    private let scanLotteryTicketButton: UIButton = {
        let button = UIButton()
        button.setTitle("Scan lottery ticket", for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.layer.cornerRadius = 22.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        button.isEnabled = true // Initially disabled
        button.isHidden = true
        return button
    }()
    
    private var segmentedControl: SSSegmentedControl = SSSegmentedControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.main400
        setupNoTicketsImageView()
        setupNoScratchOffsImageView()
        setupNavigationBarTitle()
        view.addSubview(scanScratchOffTicketButton)
        view.addSubview(scanLotteryTicketButton)
   
        setupTicketsCollectionView()
        setupScratchoffsCollectionView()
        setupScanButton()  // Setup scan button
        setupSegmentedControl()
        
        setupLayoutConstraints()  // Apply layout constraints including scan button and no tickets image view
        fetchTickets()
        fetchScratchoffs()
    }
    // MARK: - Segmented Control Setup
      private func setupSegmentedControl() {
          segmentedControl.currentIndexTitleColor = UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1)
          segmentedControl.otherIndexTitleColor = UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1)
          segmentedControl.currentIndexBackgroundColor = Appearance.main400
          segmentedControl.cornerRadius = 20.scale
          segmentedControl.buttonPadding = 5.scale
          segmentedControl.buttonCornerRadius = 17.scale
          segmentedControl.numberOfSegments = 2
          segmentedControl.segmentsTitle = "Draws,Scratch-offs"
          segmentedControl.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
          segmentedControl.layer.borderColor = UIColor.clear.cgColor
          
          segmentedControl.didTapSegment = { [weak self] index in
              self?.segmentedControlChanged(index: index)
          }
          
          segmentedControl.translatesAutoresizingMaskIntoConstraints = false
          view.addSubview(segmentedControl)
      }
    private func fetchScratchoffs() {
            // Mock data fetch for scratch-offs, implement real logic as needed
            // scratchoffs = [ScratchOff]  // Fetch scratch-offs data here
        noScratchOffsImageView.alpha = 0
        scanScratchOffTicketButton.isHidden = true
            scratchoffsCollectionView.reloadData()
        
    }
      // Function to switch between collection views based on the selected segment
      private func segmentedControlChanged(index: Int) {
          if index == 0 {
              ticketsCollectionView.isHidden = false
              scratchoffsCollectionView.isHidden = true
              noScratchOffsImageView.alpha = 0
              noTicketsImageView.alpha = 1
              scanLotteryTicketButton.isHidden = false
              scanScratchOffTicketButton.isHidden = true
              
          } else {
              ticketsCollectionView.isHidden = true
              scratchoffsCollectionView.isHidden = false
              noTicketsImageView.alpha = 0
              noScratchOffsImageView.alpha = 1
              scanLotteryTicketButton.isHidden = true
              scanScratchOffTicketButton.isHidden = false
          }
      }
   
    private func setupScratchoffsCollectionView() {
           let layout = UICollectionViewFlowLayout()
           layout.scrollDirection = .vertical
           layout.minimumLineSpacing = 20.scale
           layout.minimumInteritemSpacing = 20.scale
           layout.itemSize = CGSize(width: view.frame.width - 20.scale, height: 150.scale)

           scratchoffsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
           scratchoffsCollectionView.translatesAutoresizingMaskIntoConstraints = false
           scratchoffsCollectionView.dataSource = self
           scratchoffsCollectionView.delegate = self
           scratchoffsCollectionView.backgroundColor = .clear
           scratchoffsCollectionView.register(ScratchOffCell.self, forCellWithReuseIdentifier: "ScratchOffCell") // Use a custom cell
           scratchoffsCollectionView.contentInset = UIEdgeInsets(top: 30.scale, left: 0, bottom: 30.scale, right: 0)

           view.addSubview(scratchoffsCollectionView)
           scratchoffsCollectionView.isHidden = true // Initially hidden
       }
    private func setupTicketsCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20.scale
        layout.minimumInteritemSpacing = 20.scale
        layout.itemSize = CGSize(width: view.frame.width - 20.scale, height: 150.scale)

        ticketsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        ticketsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        ticketsCollectionView.dataSource = self
        ticketsCollectionView.delegate = self
        ticketsCollectionView.backgroundColor = .clear
        ticketsCollectionView.register(TicketCell.self, forCellWithReuseIdentifier: TicketCell.reuseIdentifier)

        ticketsCollectionView.contentInset = UIEdgeInsets(top: 30.scale, left: 0, bottom: 30.scale, right: 0)

        view.addSubview(ticketsCollectionView)

        NSLayoutConstraint.activate([
            ticketsCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            ticketsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ticketsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ticketsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
        scanButton.alpha = 0
        view.addSubview(scanButton)
    }

    private func setupNoTicketsImageView() {
        noTicketsImageView = UIImageView(image: UIImage(named: "Tickets.NoSavedTickets"))
        noTicketsImageView.translatesAutoresizingMaskIntoConstraints = false
        noTicketsImageView.contentMode = .scaleAspectFit
        
        view.addSubview(noTicketsImageView)
        
        
    }
    private func setupNoScratchOffsImageView() {
        noScratchOffsImageView = UIImageView(image: UIImage(named: "NoScratchoffs"))
        noScratchOffsImageView.translatesAutoresizingMaskIntoConstraints = false
        noScratchOffsImageView.contentMode = .scaleAspectFit
        
        view.addSubview(noScratchOffsImageView)
        
        
    }

    private func setupLayoutConstraints() {
         NSLayoutConstraint.activate([
             segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.scale),
             segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             segmentedControl.widthAnchor.constraint(equalToConstant: 285.scale),
             segmentedControl.heightAnchor.constraint(equalToConstant: 48.scale),

             ticketsCollectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20.scale),
             ticketsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             ticketsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             ticketsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             
             scratchoffsCollectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20.scale),
             scratchoffsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             scratchoffsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             scratchoffsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

             scanButton.heightAnchor.constraint(equalToConstant: 70.scale),
             scanButton.widthAnchor.constraint(equalToConstant: 70.scale),
             scanButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -13.scale),
             scanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),

             noTicketsImageView.widthAnchor.constraint(equalToConstant: 344.scale),
             noTicketsImageView.heightAnchor.constraint(equalToConstant: 209.scale),
             noTicketsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             noTicketsImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
             
             noScratchOffsImageView.widthAnchor.constraint(equalToConstant: 344.scale),
             noScratchOffsImageView.heightAnchor.constraint(equalToConstant: 209.scale),
             noScratchOffsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             noScratchOffsImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
         
             scanScratchOffTicketButton.topAnchor.constraint(equalTo: noScratchOffsImageView.bottomAnchor, constant: 20.scale),
             scanScratchOffTicketButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60.scale),
             scanScratchOffTicketButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60.scale),
             scanScratchOffTicketButton.heightAnchor.constraint(equalToConstant: 44.scale),
             
             
             
             scanLotteryTicketButton.topAnchor.constraint(equalTo: noTicketsImageView.bottomAnchor, constant: 20.scale),
             scanLotteryTicketButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60.scale),
             scanLotteryTicketButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60.scale),
             scanLotteryTicketButton.heightAnchor.constraint(equalToConstant: 44.scale),
            
             
             
         ])
     }
    var scanButtonIsTapped: Bool = false
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if scanButtonIsTapped {
            self.navigationController?.navigationBar.barTintColor = .clear
            self.navigationController?.navigationBar.isTranslucent = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scanButtonIsTapped = false
       // navigationController?.navigationBar.barTintColor = Appearance.main400
       // navigationController?.navigationBar.isTranslucent = false
        if let navigationController = getRootViewController() as? NavigationController,
           let mainViewController = navigationController.viewControllers.first as? MainViewController {
            updateMainViewControllerConstraints(for: mainViewController, newConstant: 0.scale)
            fetchTickets()
        }
    }

    private func setupNavigationBarTitle() {
        // Create a custom back button
        let backButton = UIButton(type: .custom)
        
        // Set the custom image for the button
        if let image = UIImage(named: "TicketsNavBackButton") {
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
    private func fetchTickets() {
        ticketsManager.listTickets() { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tickets):
                    self?.tickets = tickets.sorted(by: { $0.date > $1.date })
                    self?.ticketsCollectionView.reloadData()
                    if self?.tickets.count != 0 {
                        self?.ticketsCollectionView.isHidden = false
                        self?.noTicketsImageView.isHidden = true
                        self?.scanLotteryTicketButton.isHidden = true
                    } else {
                        self?.ticketsCollectionView.isHidden = true
                        self?.noTicketsImageView.isHidden = false
                        self?.scanLotteryTicketButton.isHidden = false
                    }
                case .failure:
                    if self?.tickets.count != 0 {
                        self?.ticketsCollectionView.isHidden = false
                        self?.noTicketsImageView.isHidden = true
                        self?.scanLotteryTicketButton.isHidden = true
                    } else {
                        self?.ticketsCollectionView.isHidden = true
                        self?.noTicketsImageView.isHidden = false
                        self?.scanLotteryTicketButton.isHidden = false
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
          if collectionView == ticketsCollectionView {
              return tickets.count
          } else if collectionView == scratchoffsCollectionView {
              return scratchoffs.count
          }
          return 0
      }

      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          if collectionView == ticketsCollectionView {
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TicketCell.reuseIdentifier, for: indexPath) as! TicketCell
              cell.configure(with: tickets[indexPath.item])
              cell.delegate = self
              return cell
          } else {
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScratchOffCell", for: indexPath) as! ScratchOffCell
              cell.configure(with: scratchoffs[indexPath.item]) // Assuming a `configure` method
              return cell
          }
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
        guard let indexPath = ticketsCollectionView.indexPath(for: cell) else { return }
        let ticket = tickets[indexPath.item]
        let editVC = EditTicketViewController(ticket: ticket)
        navigationController?.pushViewController(editVC, animated: true)
    }

    @objc func scanButtonTapped() {
        if SessionManager().hasActiveSubscriptions() {
            scanButtonIsTapped = true
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
        } else {
            let vc = PaygateViewController.make()
            present(vc, animated: true)
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
