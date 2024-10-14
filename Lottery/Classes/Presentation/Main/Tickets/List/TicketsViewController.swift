//
//  TicketsViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/11/24.
//

import UIKit
import AVFoundation

class TicketsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TicketCellDelegate {
    private var lotteries: [Lottery] = []
    var profile: Profile!
    private var profileManager: ProfileManagerProtocol = ProfileManager()
    private var contentManager: ContentManagerProtocol = ContentManager()
    private var tickets = [Ticket]() {
        didSet {
            if tickets.count > 0 {
                self.noTicketsImageView.isHidden = true
                self.noTicketsLabel.isHidden = true
                self.scanLotteryTicketButton.isHidden = true
            }
        }
    }
    private var scratchoffs = [ScratchOff]() {
        didSet {
            self.scratchoffs = scratchoffs ?? []
            self.noScratchOffsImageView.isHidden = true
            self.noScratchoffLabel.isHidden = true
            self.scanScratchOffTicketButton.isHidden = true
            self.scratchoffsCollectionView.reloadData()
        }
    }
    private var ticketsCollectionView: UICollectionView!
    private var scratchoffsCollectionView: UICollectionView!
    private var scanButton: UIButton! // Adding the scan button
    private var noTicketsImageView: UIImageView! // Adding the no tickets image view
    private var noScratchOffsImageView: UIImageView! // Adding the no tickets image view
    private let ticketsManager: TicketsManagerProtocol = TicketsManager()
    let scanScratchManager : ScanScratchManager = ScanScratchManager()

    private let scanScratchOffTicketButton: UIButton = {
        let button = UIButton()
        button.setTitle("TicketsViewController.ScanScratchOffTicket".localized, for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.layer.cornerRadius = 22.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(scanScratchButtonTapped), for: .touchUpInside)
        button.isEnabled = true // Initially disabled
        button.isHidden = true
        return button
    }()

    private let scanLotteryTicketButton: UIButton = {
        let button = UIButton()
        button.setTitle("TicketsViewController.ScanLotteryTicket".localized, for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.layer.cornerRadius = 22.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        button.isEnabled = true // Initially disabled
        button.isHidden = false
        return button
    }()

    private let noScratchoffLabel: UILabel = {
        let label = UILabel()

        // Create the attributed string with two parts: the title and the subtitle
        let text = NSMutableAttributedString()

        text.append(NSAttributedString(
            string: NSLocalizedString("No scratch-off tickets\n", comment: "No scratch-off tickets title"), // First part: title
            attributes: [
                .font: Fonts.Inter.semiBold(size: 16.scale),
                .foregroundColor: Appearance.mono200
            ]
        ))

        text.append(NSAttributedString(
            string: "\n", // Empty line for spacing
            attributes: [
                .font: Fonts.Inter.regular(size: 9.scale),
                .foregroundColor: Appearance.mono200
            ]
        ))

        // Append the second part of the text: subtitle
        text.append(NSAttributedString(
            string: NSLocalizedString("Scan a ticket to analyze the\nresult", comment: "Subtitle for no scratch-off tickets"), // Second part: subtitle
            attributes: [
                .font: Fonts.Inter.regular(size: 14.scale),
                .foregroundColor: Appearance.mono200
            ]
        ))

        label.attributedText = text
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()



    private let noTicketsLabel: UILabel = {
        let label = UILabel()

        // Create a paragraph style for line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8.scale // Set the line spacing

        // Create the attributed string with two parts: the title and the subtitle
        let text = NSMutableAttributedString(
            string: NSLocalizedString("No saved lottery tickets\n", comment: "No saved lottery tickets title"), // First part: title
            attributes: [
                .font: Fonts.Inter.semiBold(size: 16.scale),
                .foregroundColor: Appearance.mono200,
                .paragraphStyle: paragraphStyle
            ]
        )

        // Append the second part of the text: subtitle
        text.append(NSAttributedString(
            string: NSLocalizedString("Scan a ticket to track the game", comment: "Subtitle for no saved lottery tickets"), // Second part: subtitle
            attributes: [
                .font: Fonts.Inter.regular(size: 14.scale),
                .foregroundColor: Appearance.mono200,
                .paragraphStyle: paragraphStyle
            ]
        ))

        label.attributedText = text
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    
    private var segmentedControl: SSSegmentedControl = SSSegmentedControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.main400
        
        setupNavigationBarTitle()

        setupTicketsCollectionView()
        setupScratchoffsCollectionView()
        setupScanButton()  // Setup scan button
        setupSegmentedControl()
        
        setupNoTicketsImageView()
        setupNoScratchOffsImageView()
        view.addSubview(noScratchoffLabel)
        view.addSubview(noTicketsLabel)
        view.addSubview(scanScratchOffTicketButton)
        view.addSubview(scanLotteryTicketButton)
        
        setupLayoutConstraints()
        noScratchOffsImageView.isHidden = true
        scanScratchOffTicketButton.isHidden = true
        noScratchoffLabel.isHidden = true
        
//        noTicketsImageView.isHidden = true
//        scanLotteryTicketButton.isHidden = true
       
        fetchLotteries()
        view.bringSubviewToFront(scanScratchOffTicketButton)
        view.bringSubviewToFront(scanLotteryTicketButton)
        
    }
  

    func fetchLotteries(for stateId: Int? = nil) {
        contentManager.fetchLotteries(forceUpdate: false, stateId: nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lotteries):
                    self?.lotteries = lotteries
//                    for lottery in lotteries {
//                        if let profile = self?.profile {
//                            if let profileLotteries = profile.lotteries {
//                                if profileLotteries.count > 0 {
//                                    if profileLotteries.contains(lottery.id) {
//                                        self?.lotteries.append(lottery)
//                                    }
//                                } else {
//                                    self?.lotteries.append(lottery)
//                                }
//                            }
//                        }
//                    }
                    self?.fetchTickets()
                    self?.fetchScratchoffs()
                case .failure(let error):
                    print("Failed to fetch lotteries: \(error)")
                }
            }
        }
    }
    
    // MARK: - Segmented Control Setup
      private func setupSegmentedControl() {
          segmentedControl.currentIndexTitleColor = UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1)
          segmentedControl.otherIndexTitleColor = UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1)
          segmentedControl.currentIndexBackgroundColor = Appearance.main400
          segmentedControl.cornerRadius = 24.scale
          segmentedControl.buttonPadding = 4.scale
          segmentedControl.buttonCornerRadius = 20.scale
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
        scanScratchManager.list { scratchoffs in
            DispatchQueue.main.async {
                self.scratchoffs = scratchoffs ?? []
                if self.segmentedControl.currentIndex == 1 {
                    if scratchoffs?.count ?? 0 > 0 {
                        self.noScratchOffsImageView.isHidden = true
                        self.scanScratchOffTicketButton.isHidden = true
                        self.noTicketsLabel.isHidden = true
                        self.noScratchoffLabel.isHidden = true
                        self.noTicketsLabel.isHidden = true
                        self.scanLotteryTicketButton.isHidden = true
                        self.scratchoffsCollectionView.reloadData()
                    } else {
                        self.noScratchOffsImageView.isHidden = false
                        self.scanScratchOffTicketButton.isHidden = false
                        self.noTicketsLabel.isHidden = true
                        self.noScratchoffLabel.isHidden = false
                        self.noTicketsImageView.isHidden = true
                        self.scanLotteryTicketButton.isHidden = true
                        self.view.setNeedsLayout()
                        self.view.setNeedsDisplay()
                    }
                }
            }
        }
        
    }
      // Function to switch between collection views based on the selected segment
      private func segmentedControlChanged(index: Int) {
          if index == 0 {
              ticketsCollectionView.isHidden = false
              scratchoffsCollectionView.isHidden = true
              noScratchOffsImageView.isHidden = true
              self.noTicketsLabel.isHidden = false
              self.noScratchoffLabel.isHidden = true
              scanScratchOffTicketButton.isHidden = true
              noTicketsImageView.isHidden = false
              scanLotteryTicketButton.isHidden = false
              if tickets.count > 0 {
                  noTicketsImageView.isHidden = true
                  self.noTicketsLabel.isHidden = true
                  self.noScratchoffLabel.isHidden = true
                  scanLotteryTicketButton.isHidden = true
                  noScratchOffsImageView.isHidden = true
                  scanScratchOffTicketButton.isHidden = true
              }
             fetchTickets()
              
          } else {
             
              ticketsCollectionView.isHidden = true
              scratchoffsCollectionView.isHidden = false
              noTicketsImageView.isHidden = true
              self.noTicketsLabel.isHidden = true
              self.noScratchoffLabel.isHidden = false
              scanLotteryTicketButton.isHidden = true
              noScratchOffsImageView.isHidden = false
              scanScratchOffTicketButton.isHidden = false
              
              if scratchoffs.count > 0 {
                  noTicketsImageView.isHidden = true
                  self.noTicketsLabel.isHidden = true
                  self.noScratchoffLabel.isHidden = true
                  scanLotteryTicketButton.isHidden = true
                  noScratchOffsImageView.isHidden = true
                  scanScratchOffTicketButton.isHidden = true
              }
              fetchScratchoffs()
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

        ticketsCollectionView.contentInset = UIEdgeInsets(top: 0.scale, left: 0, bottom: 30.scale, right: 0)

        view.addSubview(ticketsCollectionView)
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
            segmentedControl.widthAnchor.constraint(equalToConstant: 258.scale),
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

            noTicketsImageView.widthAnchor.constraint(equalToConstant: 130.scale),
            noTicketsImageView.heightAnchor.constraint(equalToConstant: 130.scale),
            noTicketsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noTicketsImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60.scale),

            // Add the noTicketsLabel below the noTicketsImageView
            noTicketsLabel.topAnchor.constraint(equalTo: noTicketsImageView.bottomAnchor, constant: 30.scale),
            noTicketsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.scale),
            noTicketsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40.scale),

            noScratchOffsImageView.widthAnchor.constraint(equalToConstant: 130.scale),
            noScratchOffsImageView.heightAnchor.constraint(equalToConstant: 130.scale),
            noScratchOffsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noScratchOffsImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60.scale),

            noScratchoffLabel.topAnchor.constraint(equalTo: noScratchOffsImageView.bottomAnchor, constant: 23.scale),
            noScratchoffLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.scale),
            noScratchoffLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40.scale),

            scanScratchOffTicketButton.topAnchor.constraint(equalTo: noScratchoffLabel.bottomAnchor, constant: 30.scale),
            scanScratchOffTicketButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60.scale),
            scanScratchOffTicketButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60.scale),
            scanScratchOffTicketButton.heightAnchor.constraint(equalToConstant: 44.scale),

            scanLotteryTicketButton.topAnchor.constraint(equalTo: noTicketsLabel.bottomAnchor, constant: 30.scale),
            scanLotteryTicketButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60.scale),
            scanLotteryTicketButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60.scale),
            scanLotteryTicketButton.heightAnchor.constraint(equalToConstant: 44.scale)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scanButtonIsTapped = false
       // navigationController?.navigationBar.barTintColor = Appearance.main400
       // navigationController?.navigationBar.isTranslucent = false
        if let navigationController = getRootViewController() as? NavigationController,
           let mainViewController = navigationController.viewControllers.first as? MainViewController {
            updateMainViewControllerConstraints(for: mainViewController, newConstant: 0.scale)
            fetchLotteries()
            
        }
    }

    private func setupNavigationBarTitle() {
        // Create a custom back button
        let backButton = UIButton(type: .custom)
        
        // Set the custom image for the button
        if let image = UIImage(named: "TicketsNavBackButton") {
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
    private func fetchTickets() {
        ticketsManager.listTickets(forceUpdate: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tickets):
                    self?.tickets = tickets.sorted(by: { $0.date > $1.date })
                    self?.ticketsCollectionView.reloadData()
                    if self?.segmentedControl.currentIndex == 0 {
                        self?.noScratchOffsImageView.isHidden = true
                        self?.noScratchoffLabel.isHidden = true
                        self?.scanScratchOffTicketButton.isHidden = true
                        if self?.tickets.count != 0 {
                            self?.ticketsCollectionView.isHidden = false
                            self?.noTicketsImageView.isHidden = true
                            self?.noTicketsLabel.isHidden = true
                            self?.scanLotteryTicketButton.isHidden = true
                         
                          

                        } else {
                            self?.ticketsCollectionView.isHidden = true
                            self?.noTicketsImageView.isHidden = false
                            self?.noTicketsLabel.isHidden = false
                            self?.scanLotteryTicketButton.isHidden = false
                        }
                    }
                case .failure:
                    if self?.segmentedControl.currentIndex == 0 {
                        self?.noScratchOffsImageView.isHidden = true
                        self?.noScratchoffLabel.isHidden = true
                        self?.scanScratchOffTicketButton.isHidden = true
                        if self?.tickets.count != 0 {
                            self?.ticketsCollectionView.isHidden = false
                            self?.noTicketsImageView.isHidden = true
                            self?.noTicketsLabel.isHidden = true
                            self?.scanLotteryTicketButton.isHidden = true
                        } else {
                            self?.ticketsCollectionView.isHidden = true
                            self?.noTicketsImageView.isHidden = false
                            self?.noTicketsLabel.isHidden = false
                            self?.scanLotteryTicketButton.isHidden = false
                        }
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
              cell.lotteries = self.lotteries
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
        if collectionView == ticketsCollectionView {
            let ticket = tickets[indexPath.item]
            let ticketDate = Date(timeIntervalSince1970: ticket.date)
            let now = Date()
            let numbersCount = ticket.numbers.count
            
            let isNextDraw = ticketDate > now
            let baseHeight: CGFloat = isNextDraw ? 266.scale : 210.scale
            let additionalHeight: CGFloat = 55.scale * CGFloat(max(0, numbersCount - 1))
            
            let cellHeight = baseHeight + additionalHeight
            
            return CGSize(width: view.frame.width - 20.scale, height: cellHeight)
        } else {
            
            return CGSize(width: view.frame.width - 20.scale, height: 312.scale)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == scratchoffsCollectionView {
            // Get the selected scratch-off item
            let selectedScratchOff = scratchoffs[indexPath.item]
            
            // Initialize the CheckScratchOffTicketViewController with the selected scratch-off item
            let checkScratchoffViewController = CheckScratchOffTicketViewController(scratchOff: selectedScratchOff)
            checkScratchoffViewController.saveTicketButton.isHidden = true
            checkScratchoffViewController.rescanButton.isHidden = true
            // Push the CheckScratchOffTicketViewController onto the navigation stack
            self.navigationController?.pushViewController(checkScratchoffViewController, animated: true)
        }
    }
    func showError() {
        let alert = UIAlertController(title: "TicketsViewController.ErrorTitle".localized,
                                      message: "TicketsViewController.ErrorMessage".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - TicketCellDelegate Method
    func editButtonTapped(for cell: TicketCell) {
        guard let indexPath = ticketsCollectionView.indexPath(for: cell) else { return }
        let ticket = tickets[indexPath.item]
        let editVC = EditTicketViewController(ticket: ticket)
        editVC.lotteries = self.lotteries
        navigationController?.pushViewController(editVC, animated: true)
    }
    @objc func scanScratchButtonTapped() {
        if !SessionManager().hasActiveSubscriptions() {
            
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if granted {
                        print("Camera access granted.")
                        let scanViewController = ScanViewController()
                        scanViewController.stateId = 999
                        scanViewController.lotteryId = 999
                        if let navigationController = self.navigationController {
                            navigationController.pushViewController(scanViewController, animated: true)
                        } else {
                            self.present(scanViewController, animated: true, completion: nil)
                        }
                    } else {
                        print("Camera access denied.")
                    }
                }
            }
        case .restricted, .denied:
            self.showCameraAccessDeniedAlert()
        case .authorized:
            DispatchQueue.main.async {
                let scanViewController = ScanViewController()
                scanViewController.stateId = 999
                scanViewController.lotteryId = 999
                if let navigationController = self.navigationController {
                    navigationController.pushViewController(scanViewController, animated: true)
                } else {
                    self.present(scanViewController, animated: true, completion: nil)
                }
            }
        @unknown default:
            fatalError("Unknown camera authorization status.")
        }
        
        } else {
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
    func showCameraAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "ScanMenuViewController.CameraAccessNeededTitle".localized,
            message: "ScanMenuViewController.CameraAccessNeededMessage".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ScanMenuViewController.OpenSettingsButton".localized, style: .default, handler: { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "ScanMenuViewController.CancelButton".localized, style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    @objc func scanButtonTapped() {
        if !SessionManager().hasActiveSubscriptions() {
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
