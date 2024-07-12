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
class CustomCloseButton: UIButton {
    var removeCell: RemoveCell!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("CustomCloseButton tocuhesBegan")
        removeCell.closeButtonTapped()
    }
}
class RemoveCell: UICollectionViewCell {
  
    weak var delegate: RemoveCellDelegate?
    var numberOfCells: Int? {
        didSet {
            if let numberOfCells = numberOfCells {
                layer.cornerRadius = numberOfCells == 6 ? 20.scale : 28.scale
            }
        }
    }
     let closeButton: CustomCloseButton = {
        let button = CustomCloseButton()
      
        button.setImage(UIImage(named: "EditTickets.Close"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .center
        //button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("RemoveCell tocuhesBegan")
    }
    
    var indexPath: IndexPath!
    
    @objc  func closeButtonTapped() {
        delegate?.removeItem(at: indexPath)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        closeButton.removeCell = self
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
