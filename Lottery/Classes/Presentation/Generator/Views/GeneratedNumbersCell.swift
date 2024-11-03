//
//  GeneratedNumbersCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 11/3/24.
//

import UIKit

class GeneratedNumbersCell: UICollectionViewCell {
    static let reusableIdentifier: String = "GeneratedNumbersCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .green
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
