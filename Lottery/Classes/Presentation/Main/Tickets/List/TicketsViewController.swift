//
//  TicketsViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/11/24.
//

import UIKit
import AVFoundation
 
extension Notification.Name {
    static let ticketDeleted = Notification.Name("TicketDeletedNotification")
}


class TicketsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TicketCellDelegate,UIScrollViewDelegate {
   
    var customTransitionManager: FullTicketCustomTransitionManager?

    var pushDriven: Bool = false
    var ticketIDFromPush: Int? = 0
    var ticketViewCompletion: (() -> Void)?

    func viewAllButtonTapped(for cell: TicketCell, ticket: Ticket, bonusIdx: [Int], completion: (() -> Void)? = nil) {
        let fullTicketVC = FullTicketViewController()
        fullTicketVC.bonusIdx = bonusIdx
        fullTicketVC.ticket = ticket
        fullTicketVC.lotteries = lotteries

        // Embed in a UINavigationController
        let navController = UINavigationController(rootViewController: fullTicketVC)
        navController.modalPresentationStyle = .overFullScreen

        // Initialize and set up the custom transition manager
        let customTransitionManager = FullTicketCustomTransitionManager()
        navController.transitioningDelegate = customTransitionManager
        customTransitionManager.setupGestureRecognizer(in: navController)

        // Retain the transition manager
        self.customTransitionManager = customTransitionManager

        // Present the navigation controller
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?() // Call the completion handler here after presentation completes
        }
        present(navController, animated: true, completion: nil)
        CATransaction.commit()
    }

    
    private var lotteries: [Lottery] = []
    
    var lotteryPatterns: [LotteryPattern] = []
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
    
    private var buttonsStackViewHeightConstraint: NSLayoutConstraint?
    private var ticketsCollectionViewTopConstraint: NSLayoutConstraint?
    private var scratchoffsCollectionViewTopConstraint: NSLayoutConstraint?
    
    private let allButton: UIButton = {
        let button = UIButton()
        button.setTitle("All", for: .normal)
        button.titleLabel?.font = Fonts.Inter.medium(size: 14.scale)
        button.backgroundColor = UIColor.clear
        button.layer.borderWidth = 1.scale
        button.layer.borderColor = Appearance.ticketsBorderColor.cgColor
        button.setTitleColor(Appearance.mono200, for: .normal)
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let upcomingButton: UIButton = {
        let button = UIButton()
        button.setTitle("Upcoming", for: .normal)
        button.titleLabel?.font = Fonts.Inter.medium(size: 14.scale)
        button.setTitleColor(Appearance.mono200, for: .normal)
        button.backgroundColor = UIColor.clear
        button.layer.borderWidth = 1.scale
        button.layer.borderColor = Appearance.ticketsBorderColor.cgColor
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let winnersButton: UIButton = {
        let button = UIButton()
        button.setTitle("Winners", for: .normal)
        button.setTitleColor(Appearance.mono200, for: .normal)
        button.titleLabel?.font = Fonts.Inter.medium(size: 14.scale)
        button.backgroundColor = UIColor.clear
        button.layer.borderWidth = 1.scale
        button.layer.borderColor = Appearance.ticketsBorderColor.cgColor
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nonWinnersButton: UIButton = {
        let button = UIButton()
        button.setTitle("Non-winners", for: .normal)
        button.setTitleColor(Appearance.mono200, for: .normal)
        button.titleLabel?.font = Fonts.Inter.regular(size: 14.scale)
        button.backgroundColor = UIColor.clear
        button.layer.borderWidth = 1.scale
        button.layer.borderColor = Appearance.ticketsBorderColor.cgColor
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8.scale
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
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
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(
            string: NSLocalizedString("No scratch-off tickets\n", comment: "No scratch-off tickets title"),
            attributes: [
                .font: Fonts.Inter.semiBold(size: 16.scale),
                .foregroundColor: Appearance.mono200
            ]
        ))
        text.append(NSAttributedString(
            string: "\n",
            attributes: [
                .font: Fonts.Inter.regular(size: 9.scale),
                .foregroundColor: Appearance.mono200
            ]
        ))
        text.append(NSAttributedString(
            string: NSLocalizedString("Scan a ticket to analyze the\nresult", comment: "Subtitle for no scratch-off tickets"),
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
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8.scale
        let text = NSMutableAttributedString(
            string: NSLocalizedString("No saved lottery tickets\n", comment: "No saved lottery tickets title"),
            attributes: [
                .font: Fonts.Inter.semiBold(size: 16.scale),
                .foregroundColor: Appearance.mono200,
                .paragraphStyle: paragraphStyle
            ]
        )
        text.append(NSAttributedString(
            string: NSLocalizedString("Scan a ticket to track the game", comment: "Subtitle for no saved lottery tickets"),
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
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    private let backgroundfullView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "TicketsVCBackgroundImage")
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    
    var segmentedControl: SSSegmentedControl = SSSegmentedControl()
    
    // Top constraints for adjusting positions
    var segmentedControlTopConstraint: NSLayoutConstraint!
    var buttonsStackViewTopConstraint: NSLayoutConstraint!
    let initialSegmentedControlTopConstant: CGFloat = 10.scale
    let initialButtonsStackViewTopConstant: CGFloat = 20.scale
  
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        // Calculate new positions
        var newSegmentedControlTopConstant = initialSegmentedControlTopConstant - offsetY
        var newButtonsStackViewTopConstant = initialButtonsStackViewTopConstant + 48.scale + initialSegmentedControlTopConstant - offsetY

        // Limit the top constants
        let minSegmentedControlTopConstant = -segmentedControl.frame.height - initialSegmentedControlTopConstant
        let minButtonsStackViewTopConstant = -buttonsStackView.frame.height - initialButtonsStackViewTopConstant

        newSegmentedControlTopConstant =  max(newSegmentedControlTopConstant, minSegmentedControlTopConstant)
        newButtonsStackViewTopConstant = max(newButtonsStackViewTopConstant, minButtonsStackViewTopConstant)

        // Update the constraints
        segmentedControlTopConstraint.constant = newSegmentedControlTopConstant
        buttonsStackViewTopConstraint.constant = newButtonsStackViewTopConstant

        // Force layout update
        //view.layoutIfNeeded()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundfullView)
        view.backgroundColor = Appearance.main400
        NSLayoutConstraint.activate([
            backgroundfullView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundfullView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundfullView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundfullView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        // Add backgroundView to self.view
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupNavigationBarTitle()
        
        // Add buttons to the stack view
        buttonsStackView.addArrangedSubview(allButton)
        buttonsStackView.addArrangedSubview(upcomingButton)
        buttonsStackView.addArrangedSubview(winnersButton)
        buttonsStackView.addArrangedSubview(nonWinnersButton)
        
        // Add the stack view to the backgroundView
        backgroundView.addSubview(buttonsStackView)
        
        setupTicketsCollectionView()
        setupScratchoffsCollectionView()
        setupScanButton()
        setupSegmentedControl()
        
        setupNoTicketsImageView()
        setupNoScratchOffsImageView()
        backgroundView.addSubview(noScratchoffLabel)
        backgroundView.addSubview(noTicketsLabel)
        backgroundView.addSubview(scanScratchOffTicketButton)
        backgroundView.addSubview(scanLotteryTicketButton)
        
        setupLayoutConstraints()
        noScratchOffsImageView.isHidden = true
        scanScratchOffTicketButton.isHidden = true
        noScratchoffLabel.isHidden = true
        
        fetchLotteries()
        backgroundView.bringSubviewToFront(scanScratchOffTicketButton)
        backgroundView.bringSubviewToFront(scanLotteryTicketButton)
        
        fetchLotteriesPatterns()
        NotificationCenter.default.addObserver(self, selector: #selector(handleTicketDeleted), name: .ticketDeleted, object: nil)
        
    }
    @objc private func handleTicketDeleted() {
            // Call fetchTickets to refresh the UI
            fetchTickets()
        }
    deinit {
           // Remove observer when the view controller is deinitialized
           NotificationCenter.default.removeObserver(self, name: .ticketDeleted, object: nil)
       }
    func fetchLotteriesPatterns(for stateId: Int? = nil) {
        contentManager.fetchLotteriesPattern(forceUpdate: false, stateId: nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let patterns):
                    self?.lotteryPatterns = patterns
                    // Reload any UI or update any data structures as necessary
                    self?.ticketsCollectionView.reloadData()
                    //  print("Successfully fetched lottery patterns: \(patterns)")
                case .failure(let error):
                    print("Failed to fetch lottery patterns: \(error)")
                }
            }
        }
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
        backgroundView.addSubview(segmentedControl)
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
    func segmentedControlChanged(index: Int) {
        if index == 0 {
            
            buttonsStackViewHeightConstraint?.constant = 40.scale
            
            // Update collection views' top constraints
            ticketsCollectionViewTopConstraint?.isActive = false
            ticketsCollectionViewTopConstraint = ticketsCollectionView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 0.scale)
            ticketsCollectionViewTopConstraint?.isActive = true
            
            scratchoffsCollectionViewTopConstraint?.isActive = false
            scratchoffsCollectionViewTopConstraint = scratchoffsCollectionView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 0.scale)
            scratchoffsCollectionViewTopConstraint?.isActive = true
            
            
            buttonsStackView.isHidden = false
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
            
            buttonsStackViewHeightConstraint?.constant = 0.scale
            
            
            // Update collection views' top constraints
            ticketsCollectionViewTopConstraint?.isActive = false
            ticketsCollectionViewTopConstraint = ticketsCollectionView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 0.scale)
            ticketsCollectionViewTopConstraint?.isActive = true
            
            scratchoffsCollectionViewTopConstraint?.isActive = false
            scratchoffsCollectionViewTopConstraint = scratchoffsCollectionView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 0.scale)
            scratchoffsCollectionViewTopConstraint?.isActive = true
            
            
            buttonsStackView.isHidden = true
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
        self.view.layoutIfNeeded()
        
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
        scratchoffsCollectionView.layer.masksToBounds = false
        scratchoffsCollectionView.register(ScratchOffCell.self, forCellWithReuseIdentifier: "ScratchOffCell") // Use a custom cell
        scratchoffsCollectionView.contentInset = UIEdgeInsets(top: 0.scale, left: 0, bottom: 30.scale, right: 0)
        
        backgroundView.addSubview(scratchoffsCollectionView)
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
        ticketsCollectionView.layer.masksToBounds = false
        ticketsCollectionView.register(TicketCell.self, forCellWithReuseIdentifier: TicketCell.reuseIdentifier)
        
        ticketsCollectionView.contentInset = UIEdgeInsets(top: 0.scale, left: 0, bottom: 30.scale, right: 0)
        
        backgroundView.addSubview(ticketsCollectionView)
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
        backgroundView.addSubview(scanButton)
    }
    
    private func setupNoTicketsImageView() {
        noTicketsImageView = UIImageView(image: UIImage(named: "Tickets.NoSavedTickets"))
        noTicketsImageView.translatesAutoresizingMaskIntoConstraints = false
        noTicketsImageView.contentMode = .scaleAspectFit
        
        backgroundView.addSubview(noTicketsImageView)
        
        
    }
    private func setupNoScratchOffsImageView() {
        noScratchOffsImageView = UIImageView(image: UIImage(named: "NoScratchoffs"))
        noScratchOffsImageView.translatesAutoresizingMaskIntoConstraints = false
        noScratchOffsImageView.contentMode = .scaleAspectFit
        
        backgroundView.addSubview(noScratchOffsImageView)
        
        
    }
    
    private func setupLayoutConstraints() {
        // Segmented control constraints
        segmentedControlTopConstraint = segmentedControl.topAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.topAnchor, constant: initialSegmentedControlTopConstant)

        NSLayoutConstraint.activate([
            segmentedControlTopConstraint,
            segmentedControl.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: 258.scale),
            segmentedControl.heightAnchor.constraint(equalToConstant: 48.scale)
        ])
        
        // Buttons stack view constraints
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackViewTopConstraint = buttonsStackView.topAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.topAnchor, constant: initialSegmentedControlTopConstant + 48.scale + initialButtonsStackViewTopConstant)
        buttonsStackViewTopConstraint.isActive = true
        buttonsStackView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        buttonsStackViewHeightConstraint = buttonsStackView.heightAnchor.constraint(equalToConstant: 40.scale)
        buttonsStackViewHeightConstraint?.isActive = true
        buttonsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundView.leadingAnchor, constant: 20.scale).isActive = true
        buttonsStackView.trailingAnchor.constraint(lessThanOrEqualTo: backgroundView.trailingAnchor, constant: -20.scale).isActive = true
        
        // Set constraints for buttons inside the stack view
        NSLayoutConstraint.activate([
            allButton.widthAnchor.constraint(equalToConstant: 41.scale),
            allButton.heightAnchor.constraint(equalToConstant: 40.scale),
            upcomingButton.widthAnchor.constraint(equalToConstant: 90.scale),
            upcomingButton.heightAnchor.constraint(equalToConstant: 40.scale),
            winnersButton.widthAnchor.constraint(equalToConstant: 80.scale),
            winnersButton.heightAnchor.constraint(equalToConstant: 40.scale),
            nonWinnersButton.widthAnchor.constraint(equalToConstant: 111.scale),
            nonWinnersButton.heightAnchor.constraint(equalToConstant: 40.scale)
        ])
        
        // Tickets collection view constraints
        ticketsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        ticketsCollectionViewTopConstraint = ticketsCollectionView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 0.scale)
        ticketsCollectionViewTopConstraint?.isActive = true
        ticketsCollectionView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        ticketsCollectionView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        ticketsCollectionView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        
        // Scratch-offs collection view constraints
        scratchoffsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        scratchoffsCollectionViewTopConstraint = scratchoffsCollectionView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 0.scale)
        scratchoffsCollectionViewTopConstraint?.isActive = true
        scratchoffsCollectionView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        scratchoffsCollectionView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        scratchoffsCollectionView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        
        // Scan button constraints
        NSLayoutConstraint.activate([
            scanButton.heightAnchor.constraint(equalToConstant: 70.scale),
            scanButton.widthAnchor.constraint(equalToConstant: 70.scale),
            scanButton.bottomAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.bottomAnchor, constant: -13.scale),
            scanButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20.scale)
        ])
        
        // No tickets image and label constraints
        NSLayoutConstraint.activate([
            noTicketsImageView.widthAnchor.constraint(equalToConstant: 130.scale),
            noTicketsImageView.heightAnchor.constraint(equalToConstant: 130.scale),
            noTicketsImageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            noTicketsImageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -60.scale),
            noTicketsLabel.topAnchor.constraint(equalTo: noTicketsImageView.bottomAnchor, constant: 30.scale),
            noTicketsLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 40.scale),
            noTicketsLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -40.scale),
            scanLotteryTicketButton.topAnchor.constraint(equalTo: noTicketsLabel.bottomAnchor, constant: 30.scale),
            scanLotteryTicketButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 60.scale),
            scanLotteryTicketButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -60.scale),
            scanLotteryTicketButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
        
        // No scratch-offs image and label constraints
        NSLayoutConstraint.activate([
            noScratchOffsImageView.widthAnchor.constraint(equalToConstant: 130.scale),
            noScratchOffsImageView.heightAnchor.constraint(equalToConstant: 130.scale),
            noScratchOffsImageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            noScratchOffsImageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -60.scale),
            noScratchoffLabel.topAnchor.constraint(equalTo: noScratchOffsImageView.bottomAnchor, constant: 23.scale),
            noScratchoffLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 40.scale),
            noScratchoffLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -40.scale),
            scanScratchOffTicketButton.topAnchor.constraint(equalTo: noScratchoffLabel.bottomAnchor, constant: 30.scale),
            scanScratchOffTicketButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 60.scale),
            scanScratchOffTicketButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -60.scale),
            scanScratchOffTicketButton.heightAnchor.constraint(equalToConstant: 44.scale)
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
           // updateMainViewControllerConstraints(for: mainViewController)
            fetchLotteries()
            
        }
        if pushDriven, let ticketID = ticketIDFromPush {
               viewTicket(withId: ticketID) {
                   // Call the completion handler after the ticket is viewed
                   self.ticketViewCompletion?()
                   self.ticketViewCompletion = nil // Prevent potential retain cycles
               }
               pushDriven = false
               ticketIDFromPush = nil
           }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = getRootViewController() as? NavigationController,
           let mainViewController = navigationController.viewControllers.first as? MainViewController {
            updateMainViewControllerConstraints(for: mainViewController)
          //  fetchLotteries()
            
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
        // Perform back navigation
        navigationController?.popViewController(animated: true)
    }
    private func fetchTickets(forceUpdate: Bool = false) {
        ticketsManager.listTickets(forceUpdate: forceUpdate) { [weak self] result in
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == ticketsCollectionView {
            return UIEdgeInsets(top: initialSegmentedControlTopConstant + 48.scale + initialButtonsStackViewTopConstant + 40.scale + 20.scale , left: 0, bottom: 0, right: 0)
        } else if collectionView == scratchoffsCollectionView {
            return UIEdgeInsets(top: initialSegmentedControlTopConstant + 48.scale + 20.scale , left: 0, bottom: 0, right: 0)
        }
        fatalError()
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
            if let pattern : LotteryPattern = lotteryPatterns.filter { $0.id == tickets[indexPath.item].lotteryId }.first {
                cell.bonusIdx = pattern.bonusIdx
            }
            cell.lotteries = self.lotteries
            cell.ticket = tickets[indexPath.item]
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
        
            let baseHeight: CGFloat =  225.scale
            var additionalHeight: CGFloat = 0.scale
            if numbersCount < 2 {
                 additionalHeight = 61.scale * CGFloat(max(0, numbersCount)) + 5.scale
            } else {
                additionalHeight = 61.scale * CGFloat(max(0, 2))
            }
             
            
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
        //   if SessionManager().hasActiveSubscriptions() {
        
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
        
        //        } else {
        //            let vc = PaygateViewController.make()
        //            present(vc, animated: true)
        //        }
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
            
            if  let drawsViewController = self.navigationController?.viewControllers[0] as? DrawsViewController {
                drawsViewController.isDrawScan = true
            }
            
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
        tabView.alpha = 0
//        if mainView.tabViewBottomConstraint?.constant != newConstant {
//            // Deactivate and nil the old constraint if it's different
//            if let oldTabViewBottomConstraint = mainView.tabViewBottomConstraint {
//                oldTabViewBottomConstraint.isActive = false
//                mainView.tabViewBottomConstraint = nil
//            }
//            
//            // Create and activate the new constraint
//            let newTabViewBottomConstraint = tabView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: newConstant)
//            mainView.tabViewBottomConstraint = newTabViewBottomConstraint
//            newTabViewBottomConstraint.isActive = true
//            
//            // Call layoutIfNeeded to apply the changes
//            mainView.layoutIfNeeded()
//        }
    }
}


extension TicketsViewController {
    func indexOfTicket(withId id: Int) -> Int? {
        return tickets.firstIndex { $0.id == id }
    }
    func viewTicket(withId id: Int, completion: @escaping () -> Void) {
            let indexOfTicket = indexOfTicket(withId: id)
            if let indexOfTicket {
                let indexPath = IndexPath(item: indexOfTicket, section: 0)
                ticketsCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
                ticketsCollectionView.layoutIfNeeded()
                if let ticketCell = ticketsCollectionView.cellForItem(at: indexPath) as? TicketCell {
                    ticketCell.delegate = self
                    var bonusIdx: [Int] = []
                    if let pattern = lotteryPatterns.first(where: { $0.id == tickets[indexPath.item].lotteryId }) {
                        bonusIdx = pattern.bonusIdx
                    }
                    for i in 0..<bonusIdx.count {
                        bonusIdx[i] = bonusIdx[i] + 1
                    }
                    self.viewAllButtonTapped(for: ticketCell, ticket: tickets[indexPath.item], bonusIdx: bonusIdx) {
                        completion()
                    }
                } else {
                    // The cell might not be loaded yet
                    ticketsCollectionView.performBatchUpdates(nil) { _ in
                        if let ticketCell = self.ticketsCollectionView.cellForItem(at: indexPath) as? TicketCell {
                            ticketCell.delegate = self
                            var bonusIdx: [Int] = []
                            if let pattern = self.lotteryPatterns.first(where: { $0.id == self.tickets[indexPath.item].lotteryId }) {
                                bonusIdx = pattern.bonusIdx
                            }
                            
                            self.viewAllButtonTapped(for: ticketCell, ticket: self.tickets[indexPath.item], bonusIdx: bonusIdx) {
                                completion()
                            }
                        } else {
                            completion()
                        }
                    }
                }
            } else {
                completion()
            }
            ticketIDFromPush = nil
            pushDriven = false
        }
}
