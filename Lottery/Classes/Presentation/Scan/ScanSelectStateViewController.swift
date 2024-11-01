//
//  ScanSelectStateViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/21/24.
//

import UIKit

class ScanSelectStateViewController: UIViewController {
    var onContinue: ((Int?) -> Void)?
    private let contentManager: ContentManagerProtocol = ContentManager()
    private let profileManager: ProfileManagerProtocol = ProfileManager()
    private var states: [State] = []
    var profile: Profile!
    private let selectStateView = ScanSelectStateView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func loadView() {
      
        if let navigationController {
            if let firstViewController = navigationController.viewControllers.first {
                if firstViewController.isKind(of: GeneratorViewController.self) {
                    selectStateView.fromGenerator = true
                    selectStateView.layoutSubviews()
                }
            }
        }
        view = selectStateView
        selectStateView.setupView()
        selectStateView.setupTableView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
        fetchProfile()
        if let navigationController {
            if let firstViewController = navigationController.viewControllers.first {
                if firstViewController.isKind(of: GeneratorViewController.self) {
                    setupNavigationBackButtonFromGenerator()
                } else {
                    setupNavigationBackButton()
                }
            }
        }
        
      
        
        configureNavigationBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectStateView.continueButton.isHidden = false
    }
}


// MARK: - Private Methods

private extension ScanSelectStateViewController {
    func setupButton() {
        selectStateView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    func fetchProfile() {
        // Start both preloaders
        selectStateView.preloader.startAnimating()
        selectStateView.middlePreloader.startAnimating()
        
        profileManager.getProfile(forceUpdate: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    if let stateId = profile.state {
                        self?.profile = profile
                        self?.selectStateView.selectedState = profile.state
                        self?.selectStateView.stateTableView.reloadData()
                        self?.selectStateView.updateContinueButtonState()
                        self?.fetchStates()
                    } else {
                        // Stop both preloaders if state ID is not available
                        self?.selectStateView.preloader.stopAnimating()
                        self?.selectStateView.middlePreloader.stopAnimating()
                        print("State ID is not available in profile")
                    }
                case .failure(let error):
                    // Stop both preloaders on failure
                    self?.selectStateView.preloader.stopAnimating()
                    self?.selectStateView.middlePreloader.stopAnimating()
                    print("Failed to fetch profile: \(error)")
                }
            }
        }
    }

    func fetchStates() {
        contentManager.fetchStates(forceUpdate: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let states):
                    self?.states = states
                    self?.selectStateView.updateStates(states)
                    // Stop both preloaders on success
                    self?.selectStateView.preloader.stopAnimating()
                    self?.selectStateView.middlePreloader.stopAnimating()
                case .failure(let error):
                    // Stop both preloaders on failure
                    self?.selectStateView.preloader.stopAnimating()
                    self?.selectStateView.middlePreloader.stopAnimating()
                    self?.presentTryAgainViewController(with: error)
                }
            }
        }
    }
    
    @objc func continueButtonTapped() {
        guard let selectedState = selectStateView.getSelectedState() else {
            presentTryAgainViewController(with: ContentError(.notContent))
            return
        }
        
        // Show preloader and hide button
        selectStateView.continueButton.isHidden = true
        selectStateView.preloader.startAnimating()
        onContinue?(selectedState)
        selectStateView.preloader.stopAnimating()
    }
    
    func presentTryAgainViewController(with error: Error) {
        let vc = TryAgainViewController.make(error: error) { [weak self] in
            self?.fetchStates()
        }
        self.present(vc, animated: true)
    }
    func setupNavigationBackButtonFromGenerator() {
        let backButton = UIButton(type: .custom)
        
        // Set the custom image for the button
        if let image = UIImage(named: "Scan.SelectState") {
            backButton.setImage(image, for: .normal)
        }
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 341.scale),
            backButton.heightAnchor.constraint(equalToConstant: 26.scale),
            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: -26.scale),
            backButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: backButton.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: backButton.heightAnchor)
        ])
        
        let backButtonItem = UIBarButtonItem(customView: containerView)
        
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear
        navigationItem.leftBarButtonItem = backButtonItem
        
        // Replace the default back button with the custom button
        parent?.navigationItem.leftBarButtonItem = backButtonItem
        parent?.navigationItem.hidesBackButton = true // Hide the default back button
    }
    func setupNavigationBackButton() {
        let backButton = UIButton(type: .custom)
        
        // Set the custom image for the button
        if let image = UIImage(named: "Scan.SelectState") {
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
            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: -20.scale),
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
        parent?.navigationItem.leftBarButtonItem = backButtonItem
        parent?.navigationItem.hidesBackButton = true // Hide the default back button
    }

    @objc private func customBackButtonTapped() {
        // Perform back navigation
        navigationController?.popViewController(animated: true)
    }

    
    @objc func navigationBackButtonTapped() {
        // Handle the navigation back button tap action
        navigationController?.popViewController(animated: true)
    }
    
    func configureNavigationBar() {
        // Set the background color of the navigation bar to red
      //  navigationController?.navigationBar.barTintColor = .red
        
        //navigationController?.navigationBar.isTranslucent = false
    }
}
