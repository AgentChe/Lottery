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
    private var states: [State] = []
    private let selectStateView = ScanSelectStateView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func loadView() {
        view = selectStateView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
        fetchStates()
        setupNavigationBackButton()
        configureNavigationBar()
    }
}

// MARK: - Private Methods

private extension ScanSelectStateViewController {
    func setupButton() {
        selectStateView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    func fetchStates() {
        contentManager.fetchStates(forceUpdate: true) { [weak self] result in
            switch result {
            case .success(let states):
                self?.states = states
                self?.selectStateView.updateStates(states)
            case .failure(let error):
                self?.presentTryAgainViewController(with: error)
            }
        }
    }
    
    @objc func continueButtonTapped() {
        guard let selectedState = selectStateView.getSelectedState() else {
            presentTryAgainViewController(with: ContentError(.notContent))
            return
        }
        
        // Show preloader and hide button
        // selectStateView.continueButton.isHidden = true
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
    
    func setupNavigationBackButton() {
        // Create a custom back button
        let backButton = UIButton(type: .custom)
        
        // Set the custom image for the button
        if let image = UIImage(named: "Scan.SelectState") {
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
