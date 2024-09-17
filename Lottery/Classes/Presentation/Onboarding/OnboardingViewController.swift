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
        setupProgressView()
        setupInitialViewController()
    }
    
    var currentStep: Int = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Call the setCustomBackButton method from the OnboardingViewController
        if let onboardingVC = self.navigationController as? OnboardingViewController {
            onboardingVC.setCustomBackButton(for: self)
            self.isNavigationBarHidden = true
        }
    }
    private func setupProgressView() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = Appearance.main100
        progressView.trackTintColor = Appearance.main500
        
        view.addSubview(progressView) // Add to view instead of navigationBar
        progressView.alpha = 0
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  54.scale),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -54.scale),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: ScreenSize.isIphoneXFamily ? 12.scale : 17.scale),
            progressView.heightAnchor.constraint(equalToConstant: 6.scale)
        ])
    }
    
    private func setupInitialViewController() {
        let welcomeVC = WelcomeViewController()
        welcomeVC.onContinue = { [weak self] in
            self?.showScanScratchViewController()
        }
        setViewControllers([welcomeVC], animated: false)
    }
    
    private func showScanScratchViewController() {
        let scanScratchViewController = ScanScratchViewController()
        setCustomBackButton(for: scanScratchViewController)
        // Set the custom back button
        self.isNavigationBarHidden = true
        scanScratchViewController.onContinue = { [weak self] in
            self?.showSelectStateViewController()
        }
        pushViewController(scanScratchViewController, animated: false)
    }
    
    private func showSelectStateViewController() {
        let selectStateVC = SelectStateViewController()
        progressView.alpha = 1
        updateProgress()
        
        // Set the custom back button
        setCustomBackButton(for: selectStateVC)
        self.isNavigationBarHidden = false
        
        selectStateVC.onContinue = { [weak self] selectedState in
            guard let self = self else { return }
            self.selectedState = selectedState
            self.showSelectLotteriesViewController()
        }
        pushViewController(selectStateVC, animated: true)
    }
    
    private func showSelectLotteriesViewController() {
        guard let selectedState = selectedState else { return }
        updateProgress()
        let selectGameVC = SelectLotteriesViewController(stateId: selectedState)
        
        // Set the custom back button
        setCustomBackButton(for: selectGameVC)
        
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
            case .failure:
                self?.goToNext(at: .main)
            }
        }
    }
    
    private func determineNextStep() -> Step {
        let sessionManager = SessionManager()
        return sessionManager.hasActiveSubscriptions() ? .main : .paygate
    }
    
    private func updateProgress() {
        let totalSteps = 2
        currentStep += 1
        progressView.alpha = 1
        self.isNavigationBarHidden = false
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
    
    // Method to set custom back button with UIImage
    private func setCustomBackButton(for viewController: UIViewController) {
        let backButton = UIButton(type: .custom)
        if let image = UIImage(named: "onboardingBackButton") {
            backButton.setImage(image, for: .normal)
        }
        backButton.frame = CGRect(x: 0, y: 0.scale, width: 50.scale, height: 45.scale)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(handleBackButtonTap), for: .touchUpInside)
        
        let backButtonItem = UIBarButtonItem(customView: backButton)
        viewController.navigationItem.leftBarButtonItem = backButtonItem
        viewController.navigationItem.hidesBackButton = true
    }
    
    // Action for the back button
    @objc private func handleBackButtonTap() {
        popViewController(animated: true)
        let totalSteps = 2
        currentStep -= 1
        if currentStep <= 0 {
            progressView.alpha = 0
            currentStep = 0
            self.isNavigationBarHidden = true
            return
        }
        let progress = Float(currentStep) / Float(totalSteps)
        progressView.setProgress(progress, animated: true)
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
