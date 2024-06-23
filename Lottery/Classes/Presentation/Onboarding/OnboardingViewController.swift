//  OnboardingViewController.swift
//  Soccer
//
//  Created by Андрей Чернышев on 23.08.2022.
//

import UIKit

final class OnboardingViewController: UINavigationController, UINavigationControllerDelegate {
    struct Constants {
        static let wasViewedKey = "onboarding_view_controller_was_viewed_key"
    }
    
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let profileManager: ProfileManagerProtocol = ProfileManager()
    private var selectedState: Int?
    private var selectedGames: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.isNavigationBarHidden = true // Hide the navigation bar
        setupProgressView()
        setupInitialViewController()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    private func setupProgressView() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = Appearance.main100
        progressView.trackTintColor = Appearance.main500
        view.addSubview(progressView) // Add to view instead of navigationBar
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        updateProgress()
    }
    
    private func setupInitialViewController() {
        let welcomeVC = WelcomeViewController()
        welcomeVC.onContinue = { [weak self] in
            self?.showSelectStateViewController()
        }
        setViewControllers([welcomeVC], animated: false)
    }
    
    private func showSelectStateViewController() {
        let selectStateVC = SelectStateViewController()
        selectStateVC.onContinue = { [weak self] selectedState in
            guard let self = self else { return }
            self.selectedState = selectedState
            self.showSelectLotteriesViewController()
        }
        pushViewController(selectStateVC, animated: true)
    }
    
    private func showSelectLotteriesViewController() {
        guard let selectedState = selectedState else { return } // Ensure we have a stateId
        let selectGameVC = SelectLotteriesViewController(stateId: selectedState)
        selectGameVC.onContinue = { [weak self] selectedGames in
            guard let self = self else { return }
            self.selectedGames = selectedGames
            self.completeOnboarding()
        }
        pushViewController(selectGameVC, animated: true)
    }
    
    private func completeOnboarding() {
        markAsViewed()
        saveProfile()
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
              //  self?.presentTryAgainViewController(with: error)
                self?.goToNext(at: .main)
            }
        }
    }
    
    private func determineNextStep() -> Step {
        let sessionManager = SessionManager()
        return sessionManager.hasActiveSubscriptions() ? .main : .paygate
    }
    
    private func updateProgress() {
        let totalSteps = 3
        let currentStep = viewControllers.count
        let progress = Float(currentStep) / Float(totalSteps)
        progressView.setProgress(progress, animated: true)
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
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        updateProgress()
    }
}

// MARK: - Step Enum
extension OnboardingViewController {
    enum Step {
        case paygate, main
    }
}

// MARK: Make
extension OnboardingViewController {
    static func make() -> OnboardingViewController {
        OnboardingViewController()
    }
}

// MARK: Public
extension OnboardingViewController {
    static func wasViewed() -> Bool {
        UserDefaults.standard.bool(forKey: OnboardingViewController.Constants.wasViewedKey)
    }
}
