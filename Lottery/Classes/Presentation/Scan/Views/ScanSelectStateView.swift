//
//  ScanSelectStateView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/21/24.
//

import UIKit

final class ScanSelectStateView: UIView {
    
    // MARK: - UI Components
    
    let continueButton: UIButton = {
        let button = UIButton()
        let attrs = TextAttributes()
            .textColor(.white)
            .font(Fonts.Inter.medium(size: 17.scale))
        
        let attributedTitle = "Continue".localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 22.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false // Initially disabled
        button.alpha = 0.5 // Initially pale
        return button
    }()
    
    let preloader: UIActivityIndicatorView = {
        let preloader = UIActivityIndicatorView(style: .medium)
        preloader.translatesAutoresizingMaskIntoConstraints = false
        preloader.hidesWhenStopped = true
        return preloader
    }()
    
    let middlePreloader: UIActivityIndicatorView = {
        let preloader = UIActivityIndicatorView(style: .medium)
        preloader.translatesAutoresizingMaskIntoConstraints = false
        preloader.hidesWhenStopped = true
        return preloader
    }()
    
    private let descriptionLabel: UILabel = {
        let attrs = TextAttributes()
            .textColor(Appearance.main300)
            .font(Fonts.Inter.medium(size: 14.scale))
            .lineHeight(25.scale)
            .textAlignment(.left)
        
        let label = UILabel()
        label.attributedText = "ScanSelectStateView.selectState" .localized.attributed(with: attrs)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let stateTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = Appearance.main400
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0.scale, left: 20.scale, bottom: 0.scale, right: 20.scale)
        tableView.separatorColor = .lightGray
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private var states: [State] = []
    var selectedState: Int?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        setupView()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateContinueButtonState() {
        if selectedState != nil {
            continueButton.isEnabled = true
            continueButton.alpha = 1.0
        } else {
            continueButton.isEnabled = false
            continueButton.alpha = 0.5
        }
    }
}

// MARK: - Public Methods

extension ScanSelectStateView {
    func getSelectedState() -> Int? {
        return selectedState
    }
    
    func updateStates(_ states: [State]) {
        self.states = states
        stateTableView.reloadData()
    }
}

// MARK: - Private Methods

private extension ScanSelectStateView {
    func setupView() {
        backgroundColor = Appearance.main400
        
        addSubview(descriptionLabel)
        addSubview(stateTableView)
        addSubview(continueButton)
        addSubview(preloader) // Add preloader to the view
        addSubview(middlePreloader) // Add middle preloader to the view
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
          
            descriptionLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10.scale),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14.scale),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            
            stateTableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20.scale),
            stateTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stateTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stateTableView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20.scale),
            
            continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35.scale),
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 44.scale),
            
            // Constraints for preloader
            preloader.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor),

            // Constraints for middle preloader
            middlePreloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            middlePreloader.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func setupTableView() {
        stateTableView.dataSource = self
        stateTableView.delegate = self
        stateTableView.register(StateCell.self, forCellReuseIdentifier: "StateCell")
    }
}

// MARK: - UITableViewDataSource

extension ScanSelectStateView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath) as? StateCell else {
            return UITableViewCell()
        }
        let state = states[indexPath.row]
        let isSelected = selectedState == state.id
        cell.configure(with: state, isSelected: isSelected)
        
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScanSelectStateView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedState = states[indexPath.row].id
        updateContinueButtonState()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.scale
    }
}
