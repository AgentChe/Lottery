//
//  RemoveCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/14/24.
//

import UIKit
protocol RemoveCellDelegate: AnyObject {
    func removeItem(at indexPath: IndexPath)
}
class RemoveCell: UICollectionViewCell {
    weak var delegate: RemoveCellDelegate?
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "EditTickets.Close"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .center
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var indexPath: IndexPath!
    
    @objc private func closeButtonTapped() {
        delegate?.removeItem(at: indexPath)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = Appearance.mono100
        layer.cornerRadius = (20).scale
        layer.masksToBounds = true
        
        addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
    }
}
