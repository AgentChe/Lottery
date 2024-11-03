//
//  ChanceCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 11/3/24.
//

import UIKit

class ChanceCell: UICollectionViewCell {
    static let reusableIdentifier: String = "ChanceCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
