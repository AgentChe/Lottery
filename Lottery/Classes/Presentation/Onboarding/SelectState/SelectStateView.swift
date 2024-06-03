//  SelectStateView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit

final class SelectStateView: UIView {
    
    // MARK: - UI Components
    
    let continueButton: UIButton = {
        let button = UIButton()
        let attrs = TextAttributes()
            .textColor(.white)
            .font(Fonts.Inter.medium(size: 17.scale))
        
        let attributedTitle = NSLocalizedString("SelectState.Continue", comment: "Continue").attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false // Initially disabled
        button.alpha = 0.5 // Initially pale
        return button
    }()
    
    private let headerLabel: UILabel = {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.bold(size: 19.scale))
            .lineHeight(22.8.scale)
            .textAlignment(.left)
        
        let label = UILabel()
        label.attributedText = NSLocalizedString("SelectState.Header", comment: "SELECT THE STATE").attributed(with: attrs)
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
        label.attributedText = NSLocalizedString("SelectState.Description", comment: "Please choose the state to monitor now. You can switch later.").attributed(with: attrs)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stateTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = Appearance.main500
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20.scale, bottom: 0, right: 20.scale)
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
    
    // MARK: - Helper Methods
    
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
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 83.scale),
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
            continueButton.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
    }
    
    func setupTableView() {
        stateTableView.dataSource = self
        stateTableView.delegate = self
        stateTableView.register(UITableViewCell.self, forCellReuseIdentifier: "StateCell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath)
        let state = states[indexPath.row]
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.medium(size: 15.scale))
            .lineHeight(18.scale)
        
        cell.textLabel?.attributedText = state.name.attributed(with: attrs)
        
        let accessoryImageView = UIImageView(image: UIImage(named: selectedState == state.id ? "State.Selected" : "State.NotSelected"))
        accessoryImageView.contentMode = .scaleAspectFit
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 34.scale, height: 24.scale))
        accessoryImageView.frame = CGRect(x: -10.scale, y: 0, width: 24.scale, height: 24.scale)
        containerView.addSubview(accessoryImageView)
        cell.accessoryView = containerView
        
        cell.selectionStyle = .none
        cell.backgroundColor = Appearance.main500
        cell.separatorInset = UIEdgeInsets(top: 0, left: 20.scale, bottom: 0, right: 20.scale)
        
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
