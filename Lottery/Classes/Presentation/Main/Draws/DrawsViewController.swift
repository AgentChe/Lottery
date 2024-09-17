//
//  DrawsViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/6/24.
//

import UIKit
import AVFoundation
import Lottie

class DrawsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var profile: Profile!
    var games: [Game] = []
    var dimView: UIView!
    var isDrawScan: Bool = false
    var isScratchScan: Bool = false
    private var previousVC: UIViewController?
    var menuButton: UIButton!
    var scanOptionButton: UIButton!
    var luckyNumbersButton: UIButton!
    var ticketsButton: UIButton!
    private var upperMenuView: UIImageView!
    private var upperMenuHeightConstraint: NSLayoutConstraint!
    private var segmentTopConstraint : NSLayoutConstraint!
    private var premiumAnimationView: LottieAnimationView!
    let maxUpperMenuHeight: CGFloat = 165.scale // Maximum height of upperMenuView
    let minUpperMenuHeight: CGFloat = 115.scale
    
    lazy var luckyNumbersVC = NavigationController(rootViewController: luckyNumbersController)
    lazy var myTicketsVC = NavigationController(rootViewController: myTicketsController)
    private lazy var luckyNumbersController = LuckyNumbersViewController()
    private lazy var myTicketsController = TicketsViewController()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = getRootViewController() as? NavigationController,
           let mainViewController = navigationController.viewControllers.first as? MainViewController {
            
            updateMainViewControllerConstraints(for: mainViewController, newConstant: 0.scale)
            
        }
       setupNavigationBarTitle()
       fetchStateAndGames()
        isDrawScan = false
        isScratchScan = false
        
        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()
    }
    
    private var segmentedControl: SSSegmentedControl = SSSegmentedControl()
    private var profileManager: ProfileManagerProtocol = ProfileManager()
    private var contentManager: ContentManagerProtocol = ContentManager()
    private var nextDrawsCollectionView: UICollectionView!
    private var pastDrawsCollectionView: UICollectionView!
    private var scanButton: UIButton! // Adding the scan button
    private var noGamesAddedImageView: UIImageView! // Adding the NoGamesAdded image view
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to settings", for: .normal)
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
    @objc func addButtonTapped() {
        if SessionManager().hasActiveSubscriptions() {
            let scanOnboardingViewController = ScanOnboardingViewController.make()
            scanOnboardingViewController.immediateGameChoose = true
            scanOnboardingViewController.fromMenu = true
            let profileManager = ProfileManager()
            profileManager.getProfile(forceUpdate: false) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let profile):
                        if let stateId = profile.state {
                            scanOnboardingViewController.selectedState = stateId
                            
                            scanOnboardingViewController.showSelectLotteriesViewController()
                        } else {
                            print("State ID is not available in profile")
                        }
                    case .failure(let error):
                        print("Failed to fetch profile: \(error)")
                    }
                }
            }
            
            // Check if the current view controller is embedded in a navigation controller
            if let navigationController = self.navigationController {
                navigationController.pushViewController(scanOnboardingViewController, animated: false)
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
    
    
    private var nextDraws: [Game] = [] {
        didSet {
            nextDraws.sort { $0.date > $1.date }
            noGamesAddedImageView.isHidden =  profile.lotteries?.count != 0
            addButton.isHidden = profile.lotteries?.count != 0
        }
    }
    
    private var pastDraws: [Game] = [] {
        didSet {
            pastDraws.sort { $0.date > $1.date }
            nextDrawsCollectionView.reloadData()
        }
    }
    private var lotteries: [Lottery] = []
    
    private let gamesManager: GamesManagerProtocol = GamesManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.main400
        
        setupCollectionViews()
        setupSegmentedControl()
        setupUpperMenuView()
        //setupScanButton()  // Setup scan button
        setupNoGamesAddedImageView() // Setup NoGamesAdded image view
        setupLayoutConstraints()
        setupPremiumAnimationView()
        
       //  setupNavigationBarTitle()
    }
    
    private var previousScrollOffset: CGFloat = .zero
    private var initialContentOffset: CGFloat = 0.0 // To store the initial contentOffset
    private var hasRecordedInitialOffset = false // Flag to track the first scroll event
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        
        if !hasRecordedInitialOffset {
            initialContentOffset = currentOffset
            hasRecordedInitialOffset = true
        }
        
        
        guard currentOffset >= initialContentOffset else {
            if UIApplication.shared.statusBarFrame.height > 40 {
                segmentTopConstraint.constant =  topPadding + maxUpperMenuHeight + 20.scale
            } else {
                segmentTopConstraint.constant =  topPadding + maxUpperMenuHeight + 10.scale
            }
            return
        }
        
        
        let deltaY = currentOffset - previousScrollOffset
        print("currentOffset \(currentOffset),init: \(initialContentOffset), \(segmentTopConstraint.constant)")
        print(currentOffset < 40.scale)
        if deltaY > 0 { //shrink
            if upperMenuHeightConstraint.constant < topPadding + maxUpperMenuHeight - 10.scale {
                menuButton.alpha = 0
            }
            upperMenuHeightConstraint.constant = max( topPadding + minUpperMenuHeight, upperMenuHeightConstraint.constant - abs(deltaY))
            
            
            if initialContentOffset < currentOffset && currentOffset < 50.scale{
                segmentTopConstraint.constant = segmentTopConstraint.constant - abs(deltaY)
            } else {
                if UIApplication.shared.statusBarFrame.height < 40 {
                    segmentTopConstraint.constant = 80.scale
                } else {
                    segmentTopConstraint.constant = 100.scale
                }
            }
        } else if deltaY < 0 {
            if upperMenuHeightConstraint.constant > topPadding + minUpperMenuHeight + 35.scale{
                menuButton.alpha = 1
            }
            upperMenuHeightConstraint.constant = min(topPadding + maxUpperMenuHeight, upperMenuHeightConstraint.constant + abs(deltaY))
            
            if currentOffset < 50.scale {
                if segmentTopConstraint.constant + abs(deltaY) <= topPadding + maxUpperMenuHeight  + ( (UIApplication.shared.statusBarFrame.height < 40) ? 10.scale : 20.scale) {
                    print("here \( segmentTopConstraint.constant)")
                    segmentTopConstraint.constant = segmentTopConstraint.constant + abs(deltaY)
                } else {
                    if UIApplication.shared.statusBarFrame.height > 40 {
                        segmentTopConstraint.constant =  topPadding + maxUpperMenuHeight + 20.scale
                    } else {
                        segmentTopConstraint.constant =  topPadding + maxUpperMenuHeight + 10.scale
                    }
                }
            }
            
        }
        
        view.layoutIfNeeded()
        previousScrollOffset = currentOffset
    }
}

// MARK: - UI Setup
 extension DrawsViewController {
     private func setupPremiumAnimationView() {
           // Initialize the Lottie animation view with the specified JSON file
           premiumAnimationView = LottieAnimationView(name: "Premium")
           premiumAnimationView.translatesAutoresizingMaskIntoConstraints = false
           premiumAnimationView.contentMode = .scaleAspectFit
           premiumAnimationView.loopMode = .playOnce // Ensure the animation loops
           premiumAnimationView.play() // Start the animation
           
           // Add the animation view to the main view
           view.addSubview(premiumAnimationView)
           
           // Set up the constraints to position the animation at the bottom-right
           NSLayoutConstraint.activate([
               premiumAnimationView.widthAnchor.constraint(equalToConstant: 199.scale),
               premiumAnimationView.heightAnchor.constraint(equalToConstant: 66.scale),
               premiumAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale), // Adjust padding as needed
               premiumAnimationView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20.scale) // Adjust bottom padding as needed
           ])
           
           // Make the animation view tappable
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePremiumAnimationTap))
           premiumAnimationView.isUserInteractionEnabled = true
           premiumAnimationView.addGestureRecognizer(tapGesture)
       }
       
       // MARK: - Handle Tap Gesture
       @objc private func handlePremiumAnimationTap() {
           // Present the PaygateViewController when the animation view is tapped
           let vc = PaygateViewController.make()
           present(vc, animated: true)
       }
    func setupUpperMenuView() {
        // Set up upperMenuView as an image view
        upperMenuView = UIImageView()
        upperMenuView.contentMode = .scaleAspectFill
        upperMenuView.layer.masksToBounds = true
        if let image = UIImage(named: "upperMenuButtonImageView") {
            upperMenuView.image = image
        }
        upperMenuView.isUserInteractionEnabled = true
        upperMenuView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(upperMenuView)
        
        // Add buttons with respective images
        scanOptionButton = createButton(imageName: "ScanButtonImage")
        luckyNumbersButton = createButton(imageName: "NumbersButtonImage")
        ticketsButton = createButton(imageName: "MyTicketsButtonImage")
        menuButton = createMenuButton(imageName: "whiteBurger")
        scanOptionButton.addTarget(self, action: #selector(chooseScanOption), for: .touchUpInside)
        luckyNumbersButton.addTarget(self, action: #selector(numbersButtonTapped), for: .touchUpInside)
        ticketsButton.addTarget(self, action: #selector(myTicketsButtonTapped), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(handleMenuTap), for: .touchUpInside)
        
        // Add labels for the buttons
        let label1 = createLabel(text: "DrawsViewController.Scan".localized)
        let label2 = createLabel(text: "DrawsViewController.Numbers".localized)
        let label3 = createLabel(text: "DrawsViewController.MyTickets".localized)
        
        // Add the menu button
        
        
        
        upperMenuView.addSubview(scanOptionButton)
        upperMenuView.addSubview(luckyNumbersButton)
        upperMenuView.addSubview(ticketsButton)
        upperMenuView.addSubview(menuButton)
        upperMenuView.addSubview(label1)
        upperMenuView.addSubview(label2)
        upperMenuView.addSubview(label3)
        
        
        // Set up constraints for upperMenuView
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top ?? 0
            
            upperMenuHeightConstraint = upperMenuView.heightAnchor.constraint(equalToConstant: topPadding + maxUpperMenuHeight)
            
            NSLayoutConstraint.activate([
                upperMenuView.topAnchor.constraint(equalTo: view.topAnchor),
                upperMenuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                upperMenuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                upperMenuHeightConstraint
            ])
        }
        
        // Set constraints for the buttons and labels with reduced horizontal spacing
        NSLayoutConstraint.activate([
            // Button 1
            scanOptionButton.leadingAnchor.constraint(equalTo: upperMenuView.leadingAnchor, constant: 16.scale * 2.2),
            scanOptionButton.bottomAnchor.constraint(equalTo: upperMenuView.bottomAnchor, constant: -34.scale),
            scanOptionButton.widthAnchor.constraint(equalToConstant: 68.scale),
            scanOptionButton.heightAnchor.constraint(equalToConstant: 68.scale),
            
            // Label 1
            label1.centerXAnchor.constraint(equalTo: scanOptionButton.centerXAnchor),
            label1.topAnchor.constraint(equalTo: scanOptionButton.bottomAnchor, constant: 4.scale),
            
            // Button 2 (center button)
            ticketsButton.centerXAnchor.constraint(equalTo: upperMenuView.centerXAnchor, constant: 0),
            ticketsButton.bottomAnchor.constraint(equalTo: upperMenuView.bottomAnchor, constant: -34.scale),
            ticketsButton.widthAnchor.constraint(equalToConstant: 68.scale),
            ticketsButton.heightAnchor.constraint(equalToConstant: 68.scale),
           
            label2.centerXAnchor.constraint(equalTo: luckyNumbersButton.centerXAnchor),
            label2.topAnchor.constraint(equalTo: luckyNumbersButton.bottomAnchor, constant: 4.scale),
            
        
            
            // Button 3
            luckyNumbersButton.trailingAnchor.constraint(equalTo: upperMenuView.trailingAnchor, constant: -16.scale * 2.2),
            luckyNumbersButton.bottomAnchor.constraint(equalTo: upperMenuView.bottomAnchor, constant: -34.scale),
            luckyNumbersButton.widthAnchor.constraint(equalToConstant: 68.scale),
            luckyNumbersButton.heightAnchor.constraint(equalToConstant: 68.scale),
          
            label3.centerXAnchor.constraint(equalTo: ticketsButton.centerXAnchor),
            label3.topAnchor.constraint(equalTo: ticketsButton.bottomAnchor, constant: 4.scale),
            
            //
            // Menu Button
            menuButton.trailingAnchor.constraint(equalTo: upperMenuView.trailingAnchor, constant: -0.scale),
            menuButton.topAnchor.constraint(equalTo: ticketsButton.topAnchor, constant: -66.scale),
            menuButton.widthAnchor.constraint(equalToConstant: 60.scale),
            menuButton.heightAnchor.constraint(equalToConstant: 60.scale)
        ])
    }
    @objc func chooseScanOption() {
        if SessionManager().hasActiveSubscriptions() {
            // Create the dim view to darken the background
            dimView = UIView(frame: self.view.bounds)
            dimView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            dimView.alpha = 0 // Initially invisible
            view.addSubview(dimView)
            
            // Add tap gesture to dismiss the scan option when tapping the dimmed area
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissScanOption))
            dimView.addGestureRecognizer(tapGesture)
            
            let chooseScanOptionView = ChooseScanOptionView()
            
            // Set initial off-screen position (bottom of the screen)
            chooseScanOptionView.translatesAutoresizingMaskIntoConstraints = false
            chooseScanOptionView.layer.cornerRadius = 20.scale
            view.addSubview(chooseScanOptionView)
            
            // Set constraints for the width and height of ChooseScanOptionView
            NSLayoutConstraint.activate([
                chooseScanOptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.scale),
                chooseScanOptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.scale),
                chooseScanOptionView.heightAnchor.constraint(equalToConstant: 200.scale),  // Adjust height as needed
                chooseScanOptionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 200.scale)  // Start off-screen
            ])
            
            view.layoutIfNeeded()
            
            // Animate the dim view and the ChooseScanOptionView upwards onto the screen
            UIView.animate(withDuration: 0.3) {
                self.dimView.alpha = 1 // Make the dim view visible
                chooseScanOptionView.transform = CGAffineTransform(translationX: 0, y: -250.scale)  // Move up onto the screen
                self.view.layoutIfNeeded()
            }
            
            // Add a dismiss action for dismissButton
            chooseScanOptionView.dismissButton.addTarget(self, action: #selector(dismissChooseScanOptionView(_:)), for: .touchUpInside)
        } else {
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
      }

      @objc func dismissChooseScanOptionView(_ sender: UIButton) {
          if let chooseScanOptionView = sender.superview as? ChooseScanOptionView {
              // Animate the view back down off-screen
              UIView.animate(withDuration: 0.3, animations: {
                  chooseScanOptionView.transform = .identity  // Reset to the original off-screen position
                  self.dimView.alpha = 0 // Fade out the dim view
              }, completion: { _ in
                  chooseScanOptionView.removeFromSuperview()  // Remove the ChooseScanOptionView after the animation completes
                  self.dimView.removeFromSuperview() // Remove the dim view after animation
              })
          }
      }

      @objc func dismissScanOption() {
          // Call the dismiss function when the dim view is tapped
          dismissChooseScanOptionView(scanOptionButton)
      }
     func dismissAndPresentreScanDraw(chooseScanOptionView: UIView) {
         
         // Animate the view back down off-screen
         UIView.animate(withDuration: 0.3, animations: {
             chooseScanOptionView.transform = .identity  // Reset to the original off-screen position
             self.dimView.alpha = 0 // Fade out the dim view
         }, completion: { _ in
             chooseScanOptionView.removeFromSuperview()  // Remove the ChooseScanOptionView after the animation completes
             self.dimView.removeFromSuperview() // Remove the dim view after animation
             self.rescanButtonTapped()
         })
         
     }
    func dismissAndPresentScanDraw(chooseScanOptionView: UIView) {
        
        // Animate the view back down off-screen
        UIView.animate(withDuration: 0.3, animations: {
            chooseScanOptionView.transform = .identity  // Reset to the original off-screen position
            self.dimView.alpha = 0 // Fade out the dim view
        }, completion: { _ in
            chooseScanOptionView.removeFromSuperview()  // Remove the ChooseScanOptionView after the animation completes
            self.dimView.removeFromSuperview() // Remove the dim view after animation
            self.scanButtonTapped()
        })
        
    }
    @objc func numbersButtonTapped() {
        print("Numbers button tapped")
        
        // Push the luckyNumbersVC when Numbers button is tapped
        if let navigationController = self.navigationController {
            navigationController.pushViewController(luckyNumbersController, animated: true)
        } else {
            // Present modally if not embedded in a navigation controller
            present(luckyNumbersVC, animated: true, completion: nil)
        }
    }
    
    // Action method for the My Tickets button (pushes myTicketsVC)
    @objc func myTicketsButtonTapped() {
        print("My Tickets button tapped")
        
        // Push the myTicketsVC when My Tickets button is tapped
        if let navigationController = self.navigationController {
            navigationController.pushViewController(myTicketsController, animated: true)
        } else {
            // Present modally if not embedded in a navigation controller
            present(myTicketsVC, animated: true, completion: nil)
        }
    }
    
    // Helper function to create a circular button with an image
    func createButton(imageName: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        button.layer.cornerRadius = 34.scale // Half of the width and height to make it circular
        button.clipsToBounds = true
        
        // Create an image view for the button image
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(imageView)
        
        // Set imageView constraints to center it within the button
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24.scale), // Adjust size of the image
            imageView.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // Helper function to create the menu button with an image
    func createMenuButton(imageName: String) -> UIButton {
        let button = UIButton(type: .custom)
        // Create an image view for the button image
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(imageView)
        
        // Set imageView constraints to center it within the button
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24.scale), // Adjust size of the image
            imageView.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // Helper function to create a label with specific styles
    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = Fonts.Inter.medium(size: 14.scale)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .clear // Transparent background
        label.layer.cornerRadius = 5.scale
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    
    func setupSegmentedControl() {
        segmentedControl.currentIndexTitleColor = UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1)
        segmentedControl.otherIndexTitleColor = UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1)
        segmentedControl.currentIndexBackgroundColor = Appearance.main400
        segmentedControl.cornerRadius = 24.scale
        segmentedControl.buttonPadding = 5.scale
        segmentedControl.buttonCornerRadius = 20.scale
        segmentedControl.numberOfSegments = 2
        segmentedControl.segmentsTitle = "\("DrawsViewController.NextDraws".localized),\("DrawsViewController.PastDraws".localized)"
        segmentedControl.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        segmentedControl.layer.borderColor = UIColor.clear.cgColor
        
        segmentedControl.didTapSegment = { [weak self] index in
            self?.segmentedControlChanged(index: index)
            self?.fetchStateAndGames()
        }
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(segmentedControl)
    }
    
    
    
    func setupCollectionViews() {
        let nextDrawsCollectionViewLayout = UICollectionViewFlowLayout()
        nextDrawsCollectionViewLayout.scrollDirection = .vertical
        nextDrawsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: nextDrawsCollectionViewLayout)
        nextDrawsCollectionView.backgroundColor = .clear
        nextDrawsCollectionView.delegate = self
        nextDrawsCollectionView.dataSource = self
        nextDrawsCollectionView.register(NextGameCell.self, forCellWithReuseIdentifier: "NextGameCell")
        nextDrawsCollectionView.showsVerticalScrollIndicator = false
        nextDrawsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        nextDrawsCollectionView.layer.masksToBounds = false
        view.addSubview(nextDrawsCollectionView)
        
        let pastDrawsCollectionViewLayout = UICollectionViewFlowLayout()
        pastDrawsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: pastDrawsCollectionViewLayout)
        pastDrawsCollectionView.backgroundColor = .clear
        pastDrawsCollectionView.delegate = self
        pastDrawsCollectionView.dataSource = self
        pastDrawsCollectionView.register(PastGameCell.self, forCellWithReuseIdentifier: "PastGameCell")
        pastDrawsCollectionView.showsVerticalScrollIndicator = false
        pastDrawsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pastDrawsCollectionView.layer.masksToBounds = false
        view.addSubview(pastDrawsCollectionView)
        
        pastDrawsCollectionView.isHidden = true
    }
    
    func setupScanButton() {
        scanButton = UIButton(type: .custom)
        if let scanImage = UIImage(named: "Scan.BeginButton") {
            scanButton.setImage(scanImage, for: .normal)
        }
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.backgroundColor = .clear
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        
        view.addSubview(scanButton)
    }
    
    func setupNoGamesAddedImageView() {
        noGamesAddedImageView = UIImageView(image: UIImage(named: "NextDraws.NoGames"))
        noGamesAddedImageView.translatesAutoresizingMaskIntoConstraints = false
        noGamesAddedImageView.contentMode = .scaleAspectFit
        noGamesAddedImageView.isHidden = true
        
        view.addSubview(noGamesAddedImageView)
        view.addSubview(addButton)
    }
    
    
    func setupLayoutConstraints() {
        if UIApplication.shared.statusBarFrame.height > 40 {
            segmentTopConstraint = segmentedControl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: upperMenuHeightConstraint.constant + 20.scale)
        } else {
            segmentTopConstraint = segmentedControl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: upperMenuHeightConstraint.constant + 10.scale)
        }
        NSLayoutConstraint.activate([
            segmentTopConstraint,
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: 285.scale),
            segmentedControl.heightAnchor.constraint(equalToConstant: 48.scale),
            
            nextDrawsCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            nextDrawsCollectionView.widthAnchor.constraint(equalToConstant: 343.scale),
            nextDrawsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            nextDrawsCollectionView.centerXAnchor.constraint(equalTo: segmentedControl.centerXAnchor),
            
            pastDrawsCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            pastDrawsCollectionView.widthAnchor.constraint(equalToConstant: 343.scale),
            pastDrawsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            pastDrawsCollectionView.centerXAnchor.constraint(equalTo: segmentedControl.centerXAnchor),
            
//            scanButton.heightAnchor.constraint(equalToConstant: 70.scale),
//            scanButton.widthAnchor.constraint(equalToConstant: 70.scale),
//            scanButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -13.scale),
//            scanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            
            noGamesAddedImageView.widthAnchor.constraint(equalToConstant: 344.scale),
            noGamesAddedImageView.heightAnchor.constraint(equalToConstant: 235.scale),
            noGamesAddedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noGamesAddedImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30.scale),
            
            addButton.widthAnchor.constraint(equalToConstant: 195.scale),
            addButton.heightAnchor.constraint(equalToConstant: 44.scale),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: noGamesAddedImageView.bottomAnchor, constant: 30.scale)
        ])
    }
}

// MARK: - CollectionView Delegate FlowLayout
extension DrawsViewController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = 343.scale // Width is fixed to the collection view width with padding
        
        var cellHeight: CGFloat
        
        if collectionView == nextDrawsCollectionView {
            let game = nextDraws[indexPath.item]
            for lottery in lotteries {
                if lottery.id == game.lotteryId {
                    if  doesURLContain(lottery.logoUrl.absoluteString, word: "power") ||  doesURLContain(lottery.logoUrl.absoluteString, word: "cash4") {
                        return CGSize(width: cellWidth, height: 204.scale)
                    } else {
                        return CGSize(width: cellWidth, height: 232.scale)
                    }
                }
            }
            return CGSize(width: cellWidth, height: 232.scale)
            
        } else {
            // For Past Draws
            let game = pastDraws[indexPath.item]
            cellHeight = 176.scale  // Default height
            if let myLuckyNumbers = game.myLuckyNumbers, let winningNumbers = game.winningNumbers {
                for lottery in lotteries {
                    if lottery.id == game.lotteryId {
                        if  doesURLContain(lottery.logoUrl.absoluteString, word: "power") ||  doesURLContain(lottery.logoUrl.absoluteString, word: "cash4") {
                            if myLuckyNumbers.isEmpty {
                                cellHeight = 150.scale + 80.scale
                            } else {
                                cellHeight = 70.scale + 110.scale + CGFloat(max(0, winningNumbers.count)) * CGFloat(40 + 10.scale) + CGFloat(max(0, myLuckyNumbers.count)) * CGFloat(40 + 14.scale) + 90.scale
                            }
                        } else {
                            if myLuckyNumbers.isEmpty {
                                cellHeight = 150.scale + 108.scale
                            } else {
                                cellHeight = 98.scale + 110.scale + CGFloat(max(0, winningNumbers.count)) * CGFloat(40 + 10.scale) + CGFloat(max(0, myLuckyNumbers.count)) * CGFloat(40 + 14.scale) + 90.scale
                            }
                        }
                    }
                }
                
            }
        }
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40.scale // Adjust as needed for spacing between rows
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let bottomInset: CGFloat =  SessionManager().hasActiveSubscriptions() ? 10.scale : 100.scale
        return UIEdgeInsets(top:  upperMenuHeightConstraint.constant, left: 0, bottom: bottomInset, right: 0) // Adjust insets as needed
    }
}

// MARK: - Public Extension
extension DrawsViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == nextDrawsCollectionView {
            return nextDraws.count
        } else {
            return pastDraws.count //> 100 ? 100 : pastDraws.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == nextDrawsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NextGameCell", for: indexPath) as! NextGameCell
            let game = nextDraws[indexPath.item]
            for pastDraw in self.pastDraws {
                if pastDraw.lotteryId == game.lotteryId {
                    cell.winningNumbers = pastDraw.winningNumbers ?? []
                    cell.winningNumbersCollectionView.reloadData()
                    
                }
            }
            
            cell.configure(game: game, lotteries: lotteries)
            cell.layer.cornerRadius = 20.scale
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PastGameCell", for: indexPath) as! PastGameCell
            let game = pastDraws[indexPath.item]
            cell.configure(game: game, lotteries: lotteries)
            cell.layer.cornerRadius = 20.scale
            cell.layer.masksToBounds = true
            if let myLuckyNumbers = game.myLuckyNumbers {
                if myLuckyNumbers.isEmpty {
                    cell.dashedLineImageView.alpha = 0
                    cell.myLuckyNumbersTitleLabel.alpha = 0
                } else {
                    cell.dashedLineImageView.alpha = 1
                    cell.myLuckyNumbersTitleLabel.alpha = 1
                }
            }
            
            return cell
        }
    }
}

// MARK: - Private Extension
private extension DrawsViewController {
    func setupNavigationBarTitle() {
        // Remove all elements from the navigation bar
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.titleView = nil

        // Make the navigation bar transparent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isUserInteractionEnabled = false

        // Optional: If you want to hide the navigation bar completely
        // navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc func handleMenuTap() {
        let menuVC = MenuViewController()
        let navController = NavigationController(rootViewController: menuVC)
        navController.modalPresentationStyle = .fullScreen
        
        // Present the navigation controller
        present(navController, animated: true, completion: nil)
    }
    
    func segmentedControlChanged(index: Int) {
        if index == 0 {
            nextDrawsCollectionView.isHidden = false
            pastDrawsCollectionView.isHidden = true
        } else {
            nextDrawsCollectionView.isHidden = true
            pastDrawsCollectionView.isHidden = false
        }
    }
    
    func fetchStateAndGames() {
        
        profileManager.getProfile(forceUpdate: false) { [weak self] result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    if let stateId = profile.state {
                        self?.profile = profile
                        self?.fetchLotteries(for: stateId)
                    } else {
                        print("State ID is not available in profile")
                    }
                case .failure(let error):
                    print("Failed to fetch profile: \(error)")
                }
            }
        }
    }
    
    func fetchNextGames(for stateId: Int) {
        
        gamesManager.fetchNextGames(stateId: nil, forceUpdate: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let games):
                    
                    //                    var selectedGames: [Game] = []
                    //                    if let profile = self?.profile{
                    //                        if let profileLotteries = profile.lotteries {
                    //                            for lottery in profileLotteries {
                    //                                for game in games {
                    //                                    if game.lotteryId == lottery {
                    //                                        selectedGames.append(game)
                    //                                    }
                    //                                }
                    //                            }
                    //                        }
                    //                    }
                    self?.nextDraws = games
                    if games.count != 0{
                        self?.noGamesAddedImageView.isHidden = true
                        self?.addButton.isHidden = true
                    }
                    
                    delay(0.05) {
                        self?.nextDrawsCollectionView.reloadData()
                    }
                case .failure(let error):
                    print("Failed to fetch next games: \(error)")
                }
            }
        }
    }
    
    func fetchPastGames(for stateId: Int) {
        gamesManager.fetchPastGames(stateId: nil, forceUpdate: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let games):
                    
                    //                    var selectedGames: [Game] = []
                    //                    if let profile = self?.profile{
                    //                        if let profileLotteries = profile.lotteries {
                    //                            for lottery in profileLotteries {
                    //                                for game in games {
                    //                                    if game.lotteryId == lottery {
                    //                                        selectedGames.append(game)
                    //                                    }
                    //                                }
                    //                            }
                    //                        }
                    //                    }
                    self?.pastDraws = games//selectedGames
                    delay(0.09) {
                        self?.pastDrawsCollectionView.reloadData()
                    }
                case .failure(let error):
                    print("Failed to fetch past games: \(error)")
                }
            }
        }
    }
    
    func fetchLotteries(for stateId: Int) {
        
        contentManager.fetchLotteries(forceUpdate: false, stateId: nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lotteries):
                    self?.lotteries = lotteries
                    self?.fetchNextGames(for: stateId)
                    self?.fetchPastGames(for: stateId)
                case .failure(let error):
                    print("Failed to fetch lotteries: \(error)")
                }
            }
        }
    }
}
private extension DrawsViewController {
    @objc func scanButtonTapped() {
        
        let scanOnboardingViewController = ScanOnboardingViewController.make()
        
        if let navigationController = self.navigationController {
            
            navigationController.pushViewController(scanOnboardingViewController, animated: true)
            
            if let navigationController = getRootViewController() as? NavigationController,
               let mainViewController = navigationController.viewControllers.first as? MainViewController {
                
                updateMainViewControllerConstraints(for: mainViewController)
                
            }
        }
    }
    
    @objc func rescanButtonTapped() {
        let scanViewController = ScanMenuViewController()
        scanViewController.stateId = 888
        scanViewController.lotteryId = 888
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if granted {
                        print("Camera access granted.")
                        let scanViewController = ScanViewController()
                        scanViewController.stateId = 888
                        scanViewController.lotteryId = 888
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
                scanViewController.stateId = 888
                scanViewController.lotteryId = 888
                if let navigationController = self.navigationController {
                    navigationController.pushViewController(scanViewController, animated: true)
                } else {
                    self.present(scanViewController, animated: true, completion: nil)
                }
            }
        @unknown default:
            fatalError("Unknown camera authorization status.")
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
    func updateMainViewControllerConstraints(for mainViewController: MainViewController, newConstant : CGFloat = ScreenSize.isIphoneXFamily ? 100.scale : 80.scale ) {
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

private extension DrawsViewController {
    func doesURLContain(_ urlString: String, word: String) -> Bool {
        return urlString.lowercased().contains(word)
    }
}

