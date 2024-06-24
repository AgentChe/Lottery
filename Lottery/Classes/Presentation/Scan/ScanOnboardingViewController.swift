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
    
    private let profileManager: ProfileManagerProtocol = ProfileManager()
    private var selectedState: Int?
    private var selectedGames: [Int] = []
    //private var stateId: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        getSavedProfile()

    }
    override func loadView() {
        super.loadView()
      
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
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
    

     
    private func showSelectLotteriesViewController() {
        guard let selectedState = selectedState else { return } // Ensure we have a stateId
        let selectGameVC = ScanSelectLotteriesViewController(stateId: selectedState)
        selectGameVC.onContinue = { [weak self] selectedGames in
            guard let self = self else { return }
            self.selectedGames = selectedGames
            self.completeOnboarding()
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
        let scanViewController = ScanViewController()
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
                        self?.setupInitialViewControllerToChooseState()
                        //self?.stateId = stateId
                       // self?.setupInitialViewControllerToScan()
                        
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

        profileManager.setProfile(lotteries: selectedGames, state: stateId, forceUpdate: true) { [weak self] result in
            switch result {
            case .success:
                let nextStep = self?.determineNextStep() ?? .main
                self?.goToNext(at: nextStep)
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
