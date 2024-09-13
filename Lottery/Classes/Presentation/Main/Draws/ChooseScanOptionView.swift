import UIKit

class ChooseScanOptionView: UIView {
    
    // Declare buttons and label
    let chooseOptionLabel: UILabel = {
        let label = UILabel()
        label.text = "CHOOSE OPTION"
        label.font = Fonts.Inter.bold(size: 16.scale) // Update to correct font size and style
        label.textColor = Appearance.mono200 // Change color if needed
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let scanDrawButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan draw ticket", for: .normal)
        button.setTitleColor(Appearance.mono100, for: .normal)
        button.backgroundColor = Appearance.main100 // Set the Appearance main color
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale) // Set font and size
        button.layer.cornerRadius = 22.scale // Set corner radius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let scanScratchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan scratch-off ticket", for: .normal)
        button.setTitleColor(Appearance.mono200, for: .normal)
        button.backgroundColor = Appearance.mono100 // Set the Appearance mono color
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale) // Set font and size
        button.layer.cornerRadius = 22.scale // Set corner radius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 1.scale
        button.layer.borderColor = Appearance.main500.cgColor
        return button
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        if let closeImage = UIImage(named: "dismissChooseScan")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(closeImage, for: .normal)
            button.tintColor = UIColor.gray // Set the tintColor to gray
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        return button
    }()
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Set background color of the main view
        self.backgroundColor = Appearance.main400
        
        // Add label and buttons to the view
        addSubview(chooseOptionLabel)
        addSubview(scanDrawButton)
        addSubview(scanScratchButton)
        addSubview(dismissButton)
        
        // Add button actions
        scanDrawButton.addTarget(self, action: #selector(scanDrawButtonTapped), for: .touchUpInside)
        scanScratchButton.addTarget(self, action: #selector(scanScratchButtonTapped), for: .touchUpInside)
        
        // Set up layout constraints for chooseOptionLabel
        NSLayoutConstraint.activate([
            chooseOptionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 26.scale),
            chooseOptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.scale)
        ])
        
        // Set up layout constraints for scanDrawButton
        NSLayoutConstraint.activate([
            scanDrawButton.topAnchor.constraint(equalTo: chooseOptionLabel.bottomAnchor, constant: 26.scale),
            scanDrawButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            scanDrawButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            scanDrawButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
        
        // Set up layout constraints for scanScratchButton
        NSLayoutConstraint.activate([
            scanScratchButton.topAnchor.constraint(equalTo: scanDrawButton.bottomAnchor, constant: 13.scale),
            scanScratchButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            scanScratchButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            scanScratchButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
        
        // Set up layout constraints for dismissButton
        NSLayoutConstraint.activate([
            dismissButton.centerYAnchor.constraint(equalTo: chooseOptionLabel.centerYAnchor),
            dismissButton.trailingAnchor.constraint(equalTo: scanDrawButton.trailingAnchor, constant: -10.scale),
            dismissButton.widthAnchor.constraint(equalToConstant: 15.scale),
            dismissButton.heightAnchor.constraint(equalToConstant: 15.scale)
        ])
    }
    
    // Action for scan draw button
    @objc private func scanDrawButtonTapped() {
        if let drawsViewController = parentViewController as? DrawsViewController {
            drawsViewController.dismissAndPresentScanDraw(chooseScanOptionView: self)
            drawsViewController.isDrawScan = true
            drawsViewController.isScratchScan = false
        }
    }
    
    // Action for scan scratch-off button
    @objc private func scanScratchButtonTapped() {
        if let drawsViewController = parentViewController as? DrawsViewController {
            drawsViewController.dismissAndPresentreScanDraw(chooseScanOptionView: self)
            drawsViewController.isDrawScan = false
            drawsViewController.isScratchScan = true
        }
    }
}
