//  SelectStateViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//


import UIKit

class SelectStateViewController: UIViewController {
    var onContinue: ((Int?) -> Void)?
    private let contentManager: ContentManagerProtocol = ContentManager()
    private var states: [State] = []

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    private let selectStateView = SelectStateView()
    
    override func loadView() {
        view = selectStateView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
        fetchStates()
    }
    
    private func setupButton() {
        selectStateView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    private func fetchStates() {
        contentManager.fetchStates(forceUpdate: true) { [weak self] result in
            switch result {
            case .success(let states):
                self?.states = states
                self?.selectStateView.updateStates(states)
            case .failure(let error):
                print("Failed to fetch states: \(error)")
                self?.showError(message: "Failed to load states. Please try again.")
            }
        }
    }
    
    @objc private func continueButtonTapped() {
        guard let selectedState = selectStateView.getSelectedState() else {
            showError(message: "Please select a state.")
            return
        }
        onContinue?(selectedState)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
