//
//  SelectStateViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit

class SelectStateViewController: UIViewController {
    var onContinue: ((Int?) -> Void)?
    
    private let selectStateView = SelectStateView()
    
    override func loadView() {
        view = selectStateView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
    }
    
    private func setupButton() {
        selectStateView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    @objc private func continueButtonTapped() {
        let selectedState = selectStateView.getSelectedState()
        onContinue?(selectedState)
    }
}
