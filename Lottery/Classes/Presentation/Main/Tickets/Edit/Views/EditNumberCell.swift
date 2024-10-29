//
//  EditNumberCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/14/24.
//

//
//  EditNumberCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/14/24.
//

import UIKit

class EditNumberCell: UICollectionViewCell, UITextFieldDelegate {
    
    weak var delegate: EditScanNumberCellDelegate?
    var indexPath: IndexPath?
    var bonusIdx: [Int] = []
    var numberOfCells: Int? {
        didSet {
            if let numberOfCells = numberOfCells {
                layer.cornerRadius = numberOfCells == 6 ? 20.scale : 28.scale
                if numberOfCells == 4 {
                    if self.indexPath?.item == 0 || self.indexPath?.item == 1 {
                        backgroundColor = Appearance.main100
                        numberTextField.textColor = Appearance.mono100
                        layer.borderWidth = 0.scale
                    }
                    if self.indexPath?.item == 2 || self.indexPath?.item == 3 {
                        backgroundColor = Appearance.mono100
                        numberTextField.textColor = Appearance.mono200
                        layer.borderWidth = 1.scale
                    }
                }
            }
        }
    }
    // Replace UILabel with UITextField
     let numberTextField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 18.scale)
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 10.scale
        
        // Set the placeholder with an underscore and change its color
        let placeholderText = "_"
        let placeholderColor = Appearance.mono200
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor,
            .font: UIFont.systemFont(ofSize: 18.scale)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        return textField
    }()

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
        layer.borderColor = Appearance.main500.cgColor
        layer.borderWidth = 1.scale
        addSubview(numberTextField)
        
        NSLayoutConstraint.activate([
            numberTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            numberTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            numberTextField.heightAnchor.constraint(equalToConstant: 30.scale)
        ])
        
        // Optional: Add a toolbar with Done button to the number pad
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: false)
        
        numberTextField.inputAccessoryView = toolbar
        
        // Set the delegate to handle text field events
        numberTextField.delegate = self
    }
    
    @objc private func doneButtonTapped() {
        numberTextField.resignFirstResponder()
    }
    
    func configure(number: String, isLastInRow: Bool, indexPath: IndexPath) {
        self.indexPath = indexPath
        // Show "_" if the number is an empty string
        let displayText = number.isEmpty ? "" : number
        
        // Underline the text using NSAttributedString
        let underlineAttribute: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: isLastInRow ? Appearance.mono100 : Appearance.mono200
        ]
        
        let attributedText = NSAttributedString(string: displayText, attributes: underlineAttribute)
        numberTextField.attributedText = attributedText
        
        if  bonusIdx.contains(indexPath.item) {
            // Apply the special background and text color for the last cell in the row
            backgroundColor = Appearance.main100
            numberTextField.textColor = Appearance.mono100
            layer.borderWidth = 0.scale
        } else {
            // Reset to default appearance if not the last cell in the row
            backgroundColor = Appearance.mono100
            numberTextField.textColor = Appearance.mono200
            layer.borderWidth = 1.scale
        }
        
        
    }
    
    // UITextFieldDelegate method to handle changes to the text
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow only numeric input and limit to 2 characters
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        // Determine the new text after the replacement
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        
        // Check if the new text exceeds the 2 characters limit
        if currentText.count > 2 {
            return false
        }
        
        // Apply the underline to the new text
        var resultedColor = Appearance.mono200
        
        if numberOfCells == 6 {
            if let indexPath = indexPath {
                if bonusIdx.contains(indexPath.item)  {
                    resultedColor = Appearance.mono100
                } else {
                    resultedColor = Appearance.mono200
                }
            }
        }
        if numberOfCells == 4 {
            if indexPath?.item == 0 || indexPath?.item == 1 {
                resultedColor = Appearance.mono100
            }
            if indexPath?.item == 2 || indexPath?.item == 3 {
                resultedColor = Appearance.mono200
            }
        }
        let underlineAttribute: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: resultedColor
        ]
        let attributedText = NSAttributedString(string: currentText, attributes: underlineAttribute)
        textField.attributedText = attributedText
        
        // Notify delegate of the text change
        if let indexPath = indexPath {
            delegate?.numberCell(self, didUpdateNumber: currentText, at: indexPath)
        }
        
        // Always return false to prevent the default behavior since we're handling the text change manually
        return false
    }
    
    // UITextFieldDelegate method to show underscore when text field is empty
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let indexPath = indexPath {
            delegate?.numberCell(self, didUpdateNumber: textField.text ?? "", at: indexPath)
        }
        if textField.text?.isEmpty ?? true {
            // Show underscore if the text field is empty
            let underlineAttribute: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: Appearance.mono200
            ]
            let attributedText = NSAttributedString(string: "", attributes: underlineAttribute)
            textField.attributedText = attributedText
        }
    }
}
