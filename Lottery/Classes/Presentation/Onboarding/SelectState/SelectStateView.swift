//  SelectStateView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.

import UIKit

final class SelectStateView: UIView {
    
    // MARK: - UI Components
    
    let continueButton: UIButton = {
        let button = UIButton()
        let attrs = TextAttributes()
            .textColor(.white)
            .font(Fonts.Inter.medium(size: 17.scale))
        
        let attributedTitle = "Continue".localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 20.scale
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
    
    private let headerLabel: UILabel = {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.bold(size: 19.scale))
            .lineHeight(22.8.scale)
            .textAlignment(.left)
        
        let label = UILabel()
        label.attributedText = "SELECT THE STATE".localized.attributed(with: attrs)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let attrs = TextAttributes()
            .textColor(Appearance.main300)
            .font(Fonts.Inter.medium(size: 15.scale))
            .lineHeight(18.scale)
            .textAlignment(.left)
        
        let label = UILabel()
        label.attributedText = "Please choose the state to monitor now. You can switch later.".localized.attributed(with: attrs)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stateTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = Appearance.main500
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0.scale, left: 20.scale, bottom: 0.scale, right: 20.scale)
        tableView.separatorColor = .lightGray
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private var states: [State] = []
    private var selectedState: Int?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods

extension SelectStateView {
    func getSelectedState() -> Int? {
        return selectedState
    }
    
    func updateStates(_ states: [State]) {
        self.states = states
        stateTableView.reloadData()
    }
}

// MARK: - Private Methods

private extension SelectStateView {
    func setupView() {
        backgroundColor = Appearance.main500
        addSubview(headerLabel)
        addSubview(descriptionLabel)
        addSubview(stateTableView)
        addSubview(continueButton)
        addSubview(preloader) // Add preloader to the view
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: ScreenSize.isIphoneXFamily ? 83.scale : 50.scale),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10.scale),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            
            stateTableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20.scale),
            stateTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stateTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stateTableView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20.scale),
            
            continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35.scale),
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 50.scale),
            
            // Constraints for preloader
            preloader.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor)
        ])
    }
    
    func setupTableView() {
        stateTableView.dataSource = self
        stateTableView.delegate = self
        stateTableView.register(StateCell.self, forCellReuseIdentifier: "StateCell")
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

// MARK: - UITableViewDataSource

extension SelectStateView: UITableViewDataSource {
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
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SelectStateView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedState = states[indexPath.row].id
        updateContinueButtonState()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.scale
    }
}
