//
//  StateCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/4/24.
//

import UIKit

class StateCell: UITableViewCell {
    
    let stateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(stateLabel)
        contentView.addSubview(accessoryImageView)
        
        NSLayoutConstraint.activate([
            stateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.scale),
            stateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            accessoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.scale),
            accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryImageView.widthAnchor.constraint(equalToConstant: 24.scale),
            accessoryImageView.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
    }
    
    func configure(with state: State, isSelected: Bool) {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.medium(size: 15.scale))
            .lineHeight(18.scale)
        stateLabel.attributedText = state.name.attributed(with: attrs)
        
        accessoryImageView.image = UIImage(named: isSelected ? "State.Selected" : "State.NotSelected")
        
        contentView.backgroundColor = Appearance.main500
        separatorInset = UIEdgeInsets(top: 0.scale, left: 20.scale, bottom: 0.scale, right: 20.scale)
    }
}
