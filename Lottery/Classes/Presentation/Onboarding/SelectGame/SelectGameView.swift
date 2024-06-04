//  SelectGameView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit

final class SelectGameView: UIView {
    
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
    
    let addAnotherGameButton: UIButton = {
        let button = UIButton()
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.medium(size: 17.scale))
        let attributedTitle = "Add another game".localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        button.layer.borderWidth = 1.scale
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let headerLabel: UILabel = {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.bold(size: 19.scale))
            .lineHeight(22.8.scale)
            .textAlignment(.left)
        let label = UILabel()
        label.attributedText = "SELECT THE GAME".localized.attributed(with: attrs)
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
        label.attributedText = "Please choose the game to monitor. You can add another game if it is not on the list.".localized.attributed(with: attrs)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gameTableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsMultipleSelection = true
        tableView.backgroundColor = Appearance.main500
        tableView.separatorInset = UIEdgeInsets(top: 0.scale, left: 20.scale, bottom: 0.scale, right: 20.scale)
        tableView.separatorColor = .lightGray
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var games: [Game] = []
    private var selectedGames: Set<Int> = []
    
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

extension SelectGameView {
    func getSelectedGames() -> [Int] {
        return Array(selectedGames)
    }
    
    func updateGames(_ games: [Game]) {
        self.games = games
        gameTableView.reloadData()
    }
}

// MARK: - Private Methods

private extension SelectGameView {
    func setupView() {
        backgroundColor = Appearance.main500
        addSubview(headerLabel)
        addSubview(descriptionLabel)
        addSubview(gameTableView)
        addSubview(continueButton)
        addSubview(preloader) // Add preloader to the view
        addSubview(addAnotherGameButton)
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
            
            gameTableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20.scale),
            gameTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gameTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gameTableView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20.scale),
            
            continueButton.bottomAnchor.constraint(equalTo: addAnotherGameButton.topAnchor, constant: -10.scale),
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 50.scale),
            
            // Constraints for preloader
            preloader.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor),
            
            addAnotherGameButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50.scale),
            addAnotherGameButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            addAnotherGameButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            addAnotherGameButton.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
    }
    
    func setupTableView() {
        gameTableView.dataSource = self
        gameTableView.delegate = self
        gameTableView.register(GameCell.self, forCellReuseIdentifier: "GameCell")
    }
    
    func updateContinueButtonState() {
        continueButton.isEnabled = !selectedGames.isEmpty
        continueButton.alpha = selectedGames.isEmpty ? 0.5 : 1.0
    }
}

// MARK: - UITableViewDataSource

extension SelectGameView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as? GameCell else {
            return UITableViewCell()
        }
        let game = games[indexPath.row]
        let isSelected = selectedGames.contains(indexPath.row)
        cell.configure(with: game, isSelected: isSelected)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SelectGameView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedGames.contains(indexPath.row) {
            selectedGames.remove(indexPath.row)
        } else {
            selectedGames.insert(indexPath.row)
        }
        updateContinueButtonState()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if selectedGames.contains(indexPath.row) {
            selectedGames.remove(indexPath.row)
        } else {
            selectedGames.insert(indexPath.row)
        }
        updateContinueButtonState()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.scale
    }
}
