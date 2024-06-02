//
//  SelectStateView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/2/24.
//

import UIKit

final class SelectStateView: UIView {
    let continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 255/255, green: 0, blue: 0, alpha: 1)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "SELECT THE STATE"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = UIColor(red: 0, green: 0, blue: 139/255, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statePickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .white
        
        addSubview(headerLabel)
        addSubview(statePickerView)
        addSubview(continueButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            statePickerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            statePickerView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            statePickerView.widthAnchor.constraint(equalTo: widthAnchor),
            statePickerView.heightAnchor.constraint(equalToConstant: 200),
            
            continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
