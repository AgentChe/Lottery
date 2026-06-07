//  SelectGameViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit

class SelectLotteriesViewController: UIViewController {
    var onContinue: (([Int]) -> Void)?
    private let contentManager: ContentManagerProtocol = ContentManager()
    private var lotteries: [Lottery] = []
    private let stateId: Int?

    private let selectLotteryView = SelectLotteryView()

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
        
        RequestReview.request()
        
        setupButtons()
        fetchLotteries()
    }
}

// MARK: - Private Methods

private extension SelectLotteriesViewController {
    func setupButtons() {
        selectLotteryView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        selectLotteryView.addAnotherGameButton.addTarget(self, action: #selector(addAnotherGameButtonTapped), for: .touchUpInside)
    }
    
    func fetchLotteries() {
        contentManager.fetchLotteries(forceUpdate: false, stateId: nil) { [weak self] result in
            switch result {
            case .success(let lotteries):
                for lottery in lotteries {
                    if let stateId = self?.stateId {
                        if lottery.avaliable_states.contains(stateId) {
                            self?.lotteries.append(lottery)
                        }
                    }
                }
                if let lotteries = self?.lotteries {
                    self?.selectLotteryView.updateGames(lotteries)
                }

                
            case .failure(let error):
                self?.presentTryAgainViewController(with: error)
            }
        }
    }
    
    @objc func continueButtonTapped() {
        let selectedLotteries = selectLotteryView.getSelectedLotteries()
//        if selectedLotteries.isEmpty {
//            presentTryAgainViewController(with: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Please select at least one game."]))
//            return
//        }
        
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
