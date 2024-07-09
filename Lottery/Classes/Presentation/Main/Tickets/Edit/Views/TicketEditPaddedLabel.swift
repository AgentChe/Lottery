//
//  TicketEditPaddedLabel.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/13/24.
//

import UIKit

class TickedEditDatePaddedLabel: UILabel {
    
    var textPadding = UIEdgeInsets(top: 0.scale, left: 0.scale, bottom: 0.scale, right: 0.scale)
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textPadding)
        super.drawText(in: insetRect)
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textPadding.left + textPadding.right,
                      height: size.height + textPadding.top + textPadding.bottom)
    }
}
