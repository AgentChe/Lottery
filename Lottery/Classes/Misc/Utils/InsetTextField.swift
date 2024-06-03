//
//  InsetTextField.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/3/24.
//

import UIKit

class InsetTextField: UITextField {
    var textInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInset)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInset)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInset)
    }
}
