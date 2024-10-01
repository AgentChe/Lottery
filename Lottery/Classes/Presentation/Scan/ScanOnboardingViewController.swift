//
//  ScanOnboardingViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/21/24.
//

import UIKit

final class ScanOnboardingViewController: UIViewController {
    struct Constants {
        static let wasViewedKey = "onboarding_view_controller_was_viewed_key"
    }
    var fromMenu: Bool = false
    var immediateGameChoose: Bool = false
    private let profileManager: ProfileManagerProtocol = ProfileManager()
    var selectedState: Int?
    private var selectedLotteries: [Int] = []
    var selectGameVC: ScanSelectLotteriesViewController!
    //private var stateId: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        //getSavedProfile()
        setupInitialViewControllerToChooseState()
        
    }
    override func loadView() {
        super.loadView()
        //navigationItem.hidesBackButton = true
        setupNavigationBackButton()
        //   navigationController?.view.backgroundColor = Appearance.main500
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupInitialViewControllerToChooseState() {
        // Set up the first view controller in the onboarding flow
        let selectStateVC = ScanSelectStateViewController()
        selectStateVC.onContinue = { [weak self] selectedState in
            guard let self = self else { return }
            
            self.selectedState = selectedState
            self.showSelectLotteriesViewController()
        }
        
        // Add the initial view controller as a child view controller
        addChild(selectStateVC)
        view.addSubview(selectStateVC.view)
        selectStateVC.view.frame = view.bounds
        selectStateVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        selectStateVC.didMove(toParent: self)
    }
    func setupNavigationBackButton() {
        // Create a custom back button
        let backButton = UIButton(type: .custom)
        
        // Set the custom image for the button
        
        if let image = UIImage(named: immediateGameChoose ? "Scan.SelectLottery" : "Scan.ScanTheTicket") {
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
    private func setupInitialViewControllerToScan() {
        // Set up the first view controller in the onboarding flow
        let scanViewController = ScanViewController()
        //        scanViewController.onContinue = { [weak self] selectedState in
        //            guard let self = self else { return }
        //
        //            self.selectedState = selectedState
        //            self.showSelectLotteriesViewController()
        //        }
        
        // Add the initial view controller as a child view controller
        
        addChild(scanViewController)
        view.addSubview(scanViewController.view)
        scanViewController.view.frame = view.bounds
        scanViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scanViewController.didMove(toParent: self)
    }
    
    
    
    func showSelectLotteriesViewController() {
        guard let selectedState = selectedState else { return } // Ensure we have a stateId
        selectGameVC = ScanSelectLotteriesViewController(stateId: selectedState, fromMenu: fromMenu)
        selectGameVC.onContinue = { [weak self] selectedGames in
            guard let self = self else { return }
            self.selectedLotteries = selectedGames
            
            if !fromMenu {
                self.completeOnboarding()
            } else {
               
                saveProfile()
            }
        }
        
        // Push the SelectLotteriesViewController onto the navigation stack
        if let navigationController = navigationController {
            navigationController.pushViewController(selectGameVC, animated: true)
        } else {
            // If not in a navigation controller, present it modally
            present(selectGameVC, animated: true, completion: nil)
        }
    }
    
    private func completeOnboarding() {
        //        markAsViewed()
        //        saveProfile()
        let scanViewController = ScanMenuViewController()
        scanViewController.stateId = selectedState
        if let selectedLottery = self.selectedLotteries.first {
            scanViewController.lotteryId = selectedLottery
        }
        if let navigationController = navigationController {
            navigationController.pushViewController(scanViewController, animated: true)
        } else {
            // If not in a navigation controller, present it modally
            present(scanViewController, animated: true, completion: nil)
        }
        
    }
    
    private func getSavedProfile() {
        profileManager.getProfile(forceUpdate: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    if let stateId = profile.state {
                        // self?.setupInitialViewControllerToChooseState()
                        
                        self?.setupInitialViewControllerToScan()
                        
                    } else {
                        print("State ID is not available in profile")
                        self?.setupInitialViewControllerToChooseState()
                    }
                case .failure(let error):
                    self?.setupInitialViewControllerToChooseState()
                    print("Failed to fetch profile: \(error)")
                    
                }
            }
        }
    }
    private func saveProfile() {
        guard let stateId = selectedState else {
            presentTryAgainViewController(with: ContentError(.notContent))
            return
        }
        
        profileManager.setProfile(lotteries: selectedLotteries, state: stateId, forceUpdate: false) { [weak self] result in
            switch result {
            case .success:
                if !(self?.fromMenu ?? false) {
                    let nextStep = self?.determineNextStep() ?? .main
                    self?.goToNext(at: nextStep)
                } else {
                    self?.selectGameVC.selectLotteryView.preloader.stopAnimating()
                    self?.selectGameVC.selectLotteryView.continueButton.titleLabel?.isHidden = false
                    let rootViewController =  self?.navigationController?.viewControllers.first
                    Task {
                        let gamesManager = GamesManager()
                        
                        async let nextGamesResult = gamesManager.fetchNextGames(stateId: nil, forceUpdate: true) { [weak self] result in
                            
                        }
                        async let pastGamesResult = gamesManager.fetchPastGames(stateId: nil, forceUpdate: true) { [weak self] result in
                            
                        }
                        
                        // Wait for both results to complete
                        do {
                            let nextGames = try await nextGamesResult
                            let pastGames = try await pastGamesResult
                            
                            // Process both results
                            // Handle nextGames and pastGames here
                        } catch {
                            // Handle error
                            self?.presentTryAgainViewController(with: ContentError(.notContent))
                            return
                        }
                    }
                    self?.navigationController?.popToRootViewController(animated: true)
                    //                    delay(0.7) {
                    //                        rootViewController?.dismiss(animated: true)
                    //                    }
                }
            case .failure(let error):
                self?.presentTryAgainViewController(with: error)
            }
        }
    }
    
    private func determineNextStep() -> Step {
        let sessionManager = SessionManager()
        return sessionManager.hasActiveSubscriptions() ? .main : .paygate
    }
    
    private func markAsViewed() {
        UserDefaults.standard.setValue(true, forKey: Constants.wasViewedKey)
    }
    
    private func goToNext(at step: Step) {
        switch step {
        case .main:
            UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController = NavigationController(rootViewController: MainViewController.make())
        case .paygate:
            let vc = PaygateViewController.make { [weak self] in
                self?.goToNext(at: .main)
            }
            present(vc, animated: true)
        }
    }
    
    private func presentTryAgainViewController(with error: Error) {
        let vc = TryAgainViewController.make(error: error) { [weak self] in
            self?.saveProfile()
        }
        self.present(vc, animated: true)
    }
}

// MARK: - Step Enum
extension ScanOnboardingViewController {
    enum Step {
        case paygate, main
    }
}

// MARK: Make
extension ScanOnboardingViewController {
    static func make() -> ScanOnboardingViewController {
        ScanOnboardingViewController()
    }
}

// MARK: Public
extension ScanOnboardingViewController {
    static func wasViewed() -> Bool {
        UserDefaults.standard.bool(forKey: ScanOnboardingViewController.Constants.wasViewedKey)
    }
}

// MARK: - UINavigationControllerDelegate
extension ScanOnboardingViewController: UINavigationControllerDelegate {
    // Implement UINavigationControllerDelegate methods if needed
}
