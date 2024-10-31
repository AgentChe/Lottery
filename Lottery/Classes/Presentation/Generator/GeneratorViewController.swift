import UIKit

struct RandomNumberRequest {
    var state: String?
    var lotteryId: String?
    var lines: Int?
}

class GeneratorViewController: UIViewController {
    
    var state: String?
    var lotteryId: String?
    var lines: Int?
    
    var selectStateView: UIView!
    var selectLotteryView: UIView!
    var selectLinesView: UIView!
    
    let stateNameLabel = UILabel()
    let gameNameLabel = UILabel()
    let linesCountLabel = UILabel()
    let amountLabel = UILabel()
    
    // Custom picker components
    var customPickerView: UIView!
    var minusButton: UIButton!
    var plusButton: UIButton!
    var numberLabel: UILabel!
    
    // Lines title label
    var linesTitleLabel: UILabel!
    
    // Constraints for selectLinesView's bottom
    var selectLinesViewBottomConstraintCollapsed: NSLayoutConstraint!
    var selectLinesViewBottomConstraintExpanded: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureStateView()
    }
    
    func configureStateView() {
        // MARK: - selectStateView
        selectStateView = UIView()
        selectStateView.translatesAutoresizingMaskIntoConstraints = false
        selectStateView.backgroundColor = .lightGray
        view.addSubview(selectStateView)
        
        NSLayoutConstraint.activate([
            selectStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            selectStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectStateView.widthAnchor.constraint(equalToConstant: 343),
            selectStateView.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // "State" label
        let stateTitleLabel = UILabel()
        stateTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        stateTitleLabel.text = "State"
        selectStateView.addSubview(stateTitleLabel)
        
        NSLayoutConstraint.activate([
            stateTitleLabel.leadingAnchor.constraint(equalTo: selectStateView.leadingAnchor, constant: 16),
            stateTitleLabel.centerYAnchor.constraint(equalTo: selectStateView.centerYAnchor)
        ])
        
        // Actual state name label
        stateNameLabel.translatesAutoresizingMaskIntoConstraints = false
        stateNameLabel.text = "Select the state"
        stateNameLabel.textAlignment = .right
        selectStateView.addSubview(stateNameLabel)
        
        NSLayoutConstraint.activate([
            stateNameLabel.trailingAnchor.constraint(equalTo: selectStateView.trailingAnchor, constant: -16),
            stateNameLabel.centerYAnchor.constraint(equalTo: selectStateView.centerYAnchor),
            stateNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: stateTitleLabel.trailingAnchor, constant: 8)
        ])
        
        // Add tap recognizer to selectStateView
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(selectStateViewTapped))
        selectStateView.addGestureRecognizer(tapGesture1)
        
        // MARK: - selectLotteryView
        selectLotteryView = UIView()
        selectLotteryView.translatesAutoresizingMaskIntoConstraints = false
        selectLotteryView.backgroundColor = .lightGray
        view.addSubview(selectLotteryView)
        
        NSLayoutConstraint.activate([
            selectLotteryView.topAnchor.constraint(equalTo: selectStateView.bottomAnchor, constant: 20),
            selectLotteryView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectLotteryView.widthAnchor.constraint(equalToConstant: 343),
            selectLotteryView.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // "Game" label
        let gameTitleLabel = UILabel()
        gameTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        gameTitleLabel.text = "Game"
        selectLotteryView.addSubview(gameTitleLabel)
        
        NSLayoutConstraint.activate([
            gameTitleLabel.leadingAnchor.constraint(equalTo: selectLotteryView.leadingAnchor, constant: 16),
            gameTitleLabel.centerYAnchor.constraint(equalTo: selectLotteryView.centerYAnchor)
        ])
        
        // Actual game name label
        gameNameLabel.translatesAutoresizingMaskIntoConstraints = false
        gameNameLabel.text = "Select the game"
        gameNameLabel.textAlignment = .right
        selectLotteryView.addSubview(gameNameLabel)
        
        NSLayoutConstraint.activate([
            gameNameLabel.trailingAnchor.constraint(equalTo: selectLotteryView.trailingAnchor, constant: -16),
            gameNameLabel.centerYAnchor.constraint(equalTo: selectLotteryView.centerYAnchor),
            gameNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: gameTitleLabel.trailingAnchor, constant: 8)
        ])
        
        // Add tap recognizer to selectLotteryView
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(selectLotteryViewTapped))
        selectLotteryView.addGestureRecognizer(tapGesture2)
        
        // MARK: - selectLinesView
        selectLinesView = UIView()
        selectLinesView.translatesAutoresizingMaskIntoConstraints = false
        selectLinesView.backgroundColor = .lightGray
        view.addSubview(selectLinesView)
        
        // Set content hugging and compression resistance priorities
        selectLinesView.setContentHuggingPriority(.required, for: .vertical)
        selectLinesView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            selectLinesView.topAnchor.constraint(equalTo: selectLotteryView.bottomAnchor, constant: 20),
            selectLinesView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectLinesView.widthAnchor.constraint(equalToConstant: 343)
            // No height constraint
        ])
        
        // "Lines" label
        linesTitleLabel = UILabel()
        linesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        linesTitleLabel.text = "Lines"
        selectLinesView.addSubview(linesTitleLabel)
        
        // Actual lines count label
        linesCountLabel.translatesAutoresizingMaskIntoConstraints = false
        linesCountLabel.text = "Choose amount"
        linesCountLabel.textAlignment = .right
        selectLinesView.addSubview(linesCountLabel)
        
        // Constraints for top labels
        NSLayoutConstraint.activate([
            linesTitleLabel.leadingAnchor.constraint(equalTo: selectLinesView.leadingAnchor, constant: 16),
            linesTitleLabel.topAnchor.constraint(equalTo: selectLinesView.topAnchor, constant: 8),
            
            linesCountLabel.trailingAnchor.constraint(equalTo: selectLinesView.trailingAnchor, constant: -16),
            linesCountLabel.topAnchor.constraint(equalTo: selectLinesView.topAnchor, constant: 8),
            linesCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: linesTitleLabel.trailingAnchor, constant: 8)
        ])
        
        // Configure custom picker (initially hidden)
        configureCustomPicker()
        customPickerView.isHidden = true
        amountLabel.isHidden = true
        
        // Add amountLabel to selectLinesView
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.text = "Amount"
        amountLabel.textAlignment = .right
        amountLabel.font = UIFont.systemFont(ofSize: 16)
        selectLinesView.addSubview(amountLabel)
        
        // Constraints for customPickerView and amountLabel
        NSLayoutConstraint.activate([
            customPickerView.trailingAnchor.constraint(equalTo: selectLinesView.trailingAnchor, constant: -16),
            customPickerView.topAnchor.constraint(equalTo: linesTitleLabel.bottomAnchor, constant: 8),
            customPickerView.widthAnchor.constraint(equalToConstant: 122),
            customPickerView.heightAnchor.constraint(equalToConstant: 60),
            
            amountLabel.leadingAnchor.constraint(equalTo: selectLinesView.leadingAnchor, constant: 16),
            amountLabel.centerYAnchor.constraint(equalTo: customPickerView.centerYAnchor),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: customPickerView.trailingAnchor, constant: 8)
        ])
        
        // Constraints for selectLinesView's bottom anchor
        selectLinesViewBottomConstraintCollapsed = selectLinesView.bottomAnchor.constraint(equalTo: linesCountLabel.bottomAnchor, constant: 8)
        selectLinesViewBottomConstraintExpanded = selectLinesView.bottomAnchor.constraint(equalTo: customPickerView.bottomAnchor, constant: 8)
        
        // Initially, activate collapsed constraint
        selectLinesViewBottomConstraintCollapsed.isActive = true
        
        // Add tap recognizer to selectLinesView
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(selectLinesViewTapped))
        selectLinesView.addGestureRecognizer(tapGesture3)
    }
    
    func configureCustomPicker() {
        // Custom picker view
        customPickerView = UIView()
        customPickerView.translatesAutoresizingMaskIntoConstraints = false
        customPickerView.backgroundColor = .white
        customPickerView.layer.borderWidth = 1
        customPickerView.layer.borderColor = UIColor.lightGray.cgColor
        selectLinesView.addSubview(customPickerView)
        
        // Minus button
        minusButton = UIButton(type: .system)
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        minusButton.setTitle("-", for: .normal)
        minusButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        minusButton.addTarget(self, action: #selector(decreaseNumber), for: .touchUpInside)
        customPickerView.addSubview(minusButton)
        
        // Number label
        numberLabel = UILabel()
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.text = "1"
        numberLabel.textAlignment = .center
        numberLabel.font = UIFont.systemFont(ofSize: 24)
        customPickerView.addSubview(numberLabel)
        
        // Plus button
        plusButton = UIButton(type: .system)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        plusButton.addTarget(self, action: #selector(increaseNumber), for: .touchUpInside)
        customPickerView.addSubview(plusButton)
        
        // Layout constraints for buttons and number label within customPickerView
        NSLayoutConstraint.activate([
            minusButton.leadingAnchor.constraint(equalTo: customPickerView.leadingAnchor, constant: 8),
            minusButton.centerYAnchor.constraint(equalTo: customPickerView.centerYAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 30),
            
            plusButton.trailingAnchor.constraint(equalTo: customPickerView.trailingAnchor, constant: -8),
            plusButton.centerYAnchor.constraint(equalTo: customPickerView.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 30),
            
            numberLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor, constant: 8),
            numberLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -8),
            numberLabel.centerYAnchor.constraint(equalTo: customPickerView.centerYAnchor)
        ])
    }
    
    @objc func selectStateViewTapped() {
        // Push a UIViewController onto the navigation stack
        let stateVC = UIViewController()
        stateVC.view.backgroundColor = .white
        stateVC.title = "Select State"
        navigationController?.pushViewController(stateVC, animated: true)
    }
    
    @objc func selectLotteryViewTapped() {
        // Push a UIViewController onto the navigation stack
        let lotteryVC = UIViewController()
        lotteryVC.view.backgroundColor = .white
        lotteryVC.title = "Select Game"
        navigationController?.pushViewController(lotteryVC, animated: true)
    }
    
    @objc func selectLinesViewTapped() {
        if customPickerView.isHidden {
            // Show custom picker and amount label
            linesCountLabel.isHidden = true
            amountLabel.isHidden = false
            customPickerView.isHidden = false
            
            // Deactivate collapsed constraint
            selectLinesViewBottomConstraintCollapsed.isActive = false
            // Activate expanded constraint
            selectLinesViewBottomConstraintExpanded.isActive = true
            
            // Update amount label
            
            
            UIView.animate(withDuration: 0) {
                self.view.layoutIfNeeded()
            }
        } 
    }
    
    @objc func decreaseNumber() {
        var currentNumber = Int(numberLabel.text!) ?? 1
        if currentNumber > 1 {
            currentNumber -= 1
            numberLabel.text = "\(currentNumber)"
            
        }
    }
    
    @objc func increaseNumber() {
        var currentNumber = Int(numberLabel.text!) ?? 1
        currentNumber += 1
        numberLabel.text = "\(currentNumber)"
        
    }
    
  
}
