//
//  MenuCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/11/24.
//

import UIKit

class MenuCell: UITableViewCell {
    
    // Create a custom separator view
    private let customSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.main300
        view.alpha = 0.25
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add the custom separator to the cell
        contentView.addSubview(customSeparator)
        
        // Disable default separator inset
        separatorInset = .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Layout the custom separator
        let inset: CGFloat = 20
        let separatorHeight: CGFloat = 1
        customSeparator.frame = CGRect(
            x: inset,
            y: contentView.bounds.height - separatorHeight,
            width: contentView.bounds.width - inset * 2,
            height: separatorHeight
        )
    }
}

