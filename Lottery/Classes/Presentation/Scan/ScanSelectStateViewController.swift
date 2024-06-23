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
        selectStateView.continueButton.isHidden = true
        selectStateView.preloader.startAnimating()
        
        onContinue?(selectedState)
    }
    
    func presentTryAgainViewController(with error: Error) {
        let vc = TryAgainViewController.make(error: error) { [weak self] in
            self?.fetchStates()
        }
        self.present(vc, animated: true)
    }
    
    func setupNavigationBackButton() {
        // Hide the default back button
        navigationItem.hidesBackButton = true
        
//        // Load the image from your asset catalog
//        let backButtonImage = UIImage(named: "Scan.SelectState")
//        
//        // Create a UIButton with the custom image
//        let backButton = UIButton(type: .custom)
//        backButton.setImage(backButtonImage, for: .normal)
//        backButton.addTarget(self, action: #selector(navigationBackButtonTapped), for: .touchUpInside)
//        
//        // Adjust the frame if needed
//        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        
//        // Create a UIBarButtonItem using the UIButton
//        let backBarButtonItem = UIBarButtonItem(customView: backButton)
//        
//        // Set the custom UIBarButtonItem as the left bar button item
//        navigationItem.leftBarButtonItem = backBarButtonItem
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
