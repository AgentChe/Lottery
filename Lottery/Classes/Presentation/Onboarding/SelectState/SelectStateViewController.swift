//  SelectStateViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.

import UIKit

class SelectStateViewController: UIViewController {
    var onContinue: ((Int?) -> Void)?
    private let contentManager: ContentManagerProtocol = ContentManager()
    private var states: [State] = []
    private let selectStateView = SelectStateView()
    
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
    }
}

// MARK: - Private Methods

private extension SelectStateViewController {
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
        onContinue?(selectedState)
    }
    
    func presentTryAgainViewController(with error: Error) {
        let vc = TryAgainViewController.make(error: error) { [weak self] in
            self?.fetchStates()
        }
        self.present(vc, animated: true)
    }
}
