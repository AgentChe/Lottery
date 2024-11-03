//
//  StatsCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 11/3/24.
//

import UIKit

class StatsCell : UICollectionViewCell {
    static let reusableIdentifier: String = "StatsCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .orange
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
