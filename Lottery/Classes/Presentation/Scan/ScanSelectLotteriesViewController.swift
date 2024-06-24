//
//  ScanSelectLotteriesViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/24/24.
//


import UIKit

class ScanSelectLotteriesViewController: UIViewController {
    var onContinue: (([Int]) -> Void)?
    private let contentManager: ContentManagerProtocol = ContentManager()
    private var lotteries: [Lottery] = []
    private let stateId: Int?

    private let selectLotteryView = ScanSelectLotteryView()

    // Custom initializer to accept stateId
    init(stateId: Int?) {
        self.stateId = stateId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.stateId = nil
        super.init(coder: coder)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func loadView() {
        view = selectLotteryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        fetchLotteries()
        setupNavigationBackButton()
        
    }
}

// MARK: - Private Methods

private extension ScanSelectLotteriesViewController {
    func setupNavigationBackButton() {
        // Create a custom back button
        let backButton = UIButton(type: .custom)
        
        // Set the custom image for the button
        if let image = UIImage(named: "Scan.SelectLottery") {
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
    func setupButtons() {
        selectLotteryView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        selectLotteryView.addAnotherGameButton.addTarget(self, action: #selector(addAnotherGameButtonTapped), for: .touchUpInside)
    }
    
    func fetchLotteries() {
        contentManager.fetchLotteries(forceUpdate: true, stateId: nil) { [weak self] result in
            switch result {
            case .success(let lotteries):
                self?.lotteries = lotteries
                self?.selectLotteryView.updateGames(lotteries)
            case .failure(let error):
                self?.presentTryAgainViewController(with: error)
            }
        }
    }
    
    @objc func continueButtonTapped() {
        let selectedLotteries = selectLotteryView.getSelectedLotteries()
        if selectedLotteries.isEmpty {
            presentTryAgainViewController(with: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please select at least one game."]))
            return
        }
        
        // Show preloader and hide button
        selectLotteryView.continueButton.isHidden = true
        selectLotteryView.preloader.startAnimating()
        
        onContinue?(selectedLotteries)
    }
    
    @objc func addAnotherGameButtonTapped() {
        let suggestNewGameVC = SuggestNewGameViewController()
        suggestNewGameVC.modalPresentationStyle = .fullScreen
        present(suggestNewGameVC, animated: true, completion: nil)
    }
    
    func presentTryAgainViewController(with error: Error) {
        let vc = TryAgainViewController.make(error: error) { [weak self] in
            self?.fetchLotteries()
        }
        present(vc, animated: true)
    }
}
