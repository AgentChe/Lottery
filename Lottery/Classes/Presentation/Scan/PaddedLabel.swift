//
//  PaddedLabel.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 9/11/24.
//

import UIKit
class PaddedLabel: UILabel {
    
    var textInsets = UIEdgeInsets(top: 10.scale, left: 16.scale, bottom: 16.scale, right: 10.scale) {
        didSet {
            setNeedsDisplay() // Redraw the label with the new insets
        }
    }
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
}
