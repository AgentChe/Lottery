//  SelectStateView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit

final class SelectStateView: UIView, UITableViewDataSource, UITableViewDelegate {
    let continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Appearance.main100
        button.titleLabel?.font = Fonts.Inter.medium(size: 17.scale)
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false // Initially disabled
        button.alpha = 0.5 // Initially pale
        return button
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "SELECT THE STATE"
        label.font = Fonts.Inter.bold(size: 19.scale)
        label.textColor = Appearance.mono200
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Please choose the state to monitor now. You can switch later."
        label.font = Fonts.Inter.medium(size: 15.scale)
        label.textColor = Appearance.main300
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6.scale  // Adjust this value as needed
        
        let attributedString = NSMutableAttributedString(string: label.text ?? "")
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        
        return label
    }()
    
    private let stateTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = Appearance.main500
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.separatorColor = .lightGray
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let states = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
    private var selectedState: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        stateTableView.dataSource = self
        stateTableView.delegate = self
        stateTableView.register(UITableViewCell.self, forCellReuseIdentifier: "StateCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = Appearance.main500
        
        addSubview(headerLabel)
        addSubview(descriptionLabel)
        addSubview(stateTableView)
        addSubview(continueButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
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
    
    func getSelectedState() -> Int? {
        return selectedState
    }
    
    // UITableViewDataSource and UITableViewDelegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath)
        
        // Configure the text label
        cell.textLabel?.text = states[indexPath.row]
        cell.textLabel?.textColor = Appearance.mono200
        cell.textLabel?.font = Fonts.Inter.medium(size: 15.scale)
        
        // Configure the accessory view with additional space to the right
        let accessoryImageView = UIImageView(image: UIImage(named: selectedState == indexPath.row ? "State.Selected" : "State.NotSelected"))
        accessoryImageView.contentMode = .scaleAspectFit
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 34.scale, height: 24.scale)) // Adjust width to provide additional space
        accessoryImageView.frame = CGRect(x: -10.scale, y: 0, width: 24.scale, height: 24.scale) // Move left by 10 points
        containerView.addSubview(accessoryImageView)
        cell.accessoryView = containerView
        
        // Set cell selection style and background color
        cell.selectionStyle = .none
        cell.backgroundColor = Appearance.main500
        
        // Adjust separator inset
        cell.separatorInset = UIEdgeInsets(top: 0, left: 20.scale, bottom: 0, right: 20.scale)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedState = indexPath.row
        updateContinueButtonState()
        tableView.reloadData()
    }
    
    private func updateContinueButtonState() {
        if selectedState != nil {
            continueButton.isEnabled = true
            continueButton.alpha = 1.0
        } else {
            continueButton.isEnabled = false
            continueButton.alpha = 0.5
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.scale
    }
}
