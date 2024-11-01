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
    
    // MARK: - Views
    
    var selectStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    var selectLotteryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    var selectLinesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        // Set content hugging and compression resistance priorities
        view.setContentHuggingPriority(.required, for: .vertical)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        return view
    }()
    
    let stateTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "State"
        return label
    }()
    
    let gameTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Game"
        return label
    }()
    
    let linesTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Lines"
        return label
    }()
    
    let stateNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select the state"
        label.textAlignment = .right
        return label
    }()
    
    let gameNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select the game"
        label.textAlignment = .right
        return label
    }()
    
    let linesCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Choose amount"
        label.textAlignment = .right
        return label
    }()
    
    let amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Amount"
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()
    
    // Custom picker components
    var customPickerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.isHidden = true
        return view
    }()
    
    var minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("-", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        return button
    }()
    
    var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        return button
    }()
    
    var numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    // Constraints for selectLinesView's bottom
    var selectLinesViewBottomConstraintCollapsed: NSLayoutConstraint!
    var selectLinesViewBottomConstraintExpanded: NSLayoutConstraint!
    
    // MARK: - Gestures
    
    let stateTapGesture = UITapGestureRecognizer()
    let lotteryTapGesture = UITapGestureRecognizer()
    let linesTapGesture = UITapGestureRecognizer()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupGestures()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    
    func setupViews() {
        view.addSubview(selectStateView)
        selectStateView.addSubview(stateTitleLabel)
        selectStateView.addSubview(stateNameLabel)
        
        view.addSubview(selectLotteryView)
        selectLotteryView.addSubview(gameTitleLabel)
        selectLotteryView.addSubview(gameNameLabel)
        
        view.addSubview(selectLinesView)
        selectLinesView.addSubview(linesTitleLabel)
        selectLinesView.addSubview(linesCountLabel)
        selectLinesView.addSubview(customPickerView)
        selectLinesView.addSubview(amountLabel)
        
        customPickerView.addSubview(minusButton)
        customPickerView.addSubview(numberLabel)
        customPickerView.addSubview(plusButton)
    }
    
    func setupGestures() {
        stateTapGesture.addTarget(self, action: #selector(selectStateViewTapped))
        selectStateView.addGestureRecognizer(stateTapGesture)
        
        lotteryTapGesture.addTarget(self, action: #selector(selectLotteryViewTapped))
        selectLotteryView.addGestureRecognizer(lotteryTapGesture)
        
        linesTapGesture.addTarget(self, action: #selector(selectLinesViewTapped))
        selectLinesView.addGestureRecognizer(linesTapGesture)
        
        minusButton.addTarget(self, action: #selector(decreaseNumber), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(increaseNumber), for: .touchUpInside)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // selectStateView constraints
            selectStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            selectStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectStateView.widthAnchor.constraint(equalToConstant: 343),
            selectStateView.heightAnchor.constraint(equalToConstant: 56),
            
            // stateTitleLabel constraints
            stateTitleLabel.leadingAnchor.constraint(equalTo: selectStateView.leadingAnchor, constant: 16),
            stateTitleLabel.centerYAnchor.constraint(equalTo: selectStateView.centerYAnchor),
            
            // stateNameLabel constraints
            stateNameLabel.trailingAnchor.constraint(equalTo: selectStateView.trailingAnchor, constant: -16),
            stateNameLabel.centerYAnchor.constraint(equalTo: selectStateView.centerYAnchor),
            stateNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: stateTitleLabel.trailingAnchor, constant: 8),
            
            // selectLotteryView constraints
            selectLotteryView.topAnchor.constraint(equalTo: selectStateView.bottomAnchor, constant: 20),
            selectLotteryView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectLotteryView.widthAnchor.constraint(equalToConstant: 343),
            selectLotteryView.heightAnchor.constraint(equalToConstant: 56),
            
            // gameTitleLabel constraints
            gameTitleLabel.leadingAnchor.constraint(equalTo: selectLotteryView.leadingAnchor, constant: 16),
            gameTitleLabel.centerYAnchor.constraint(equalTo: selectLotteryView.centerYAnchor),
            
            // gameNameLabel constraints
            gameNameLabel.trailingAnchor.constraint(equalTo: selectLotteryView.trailingAnchor, constant: -16),
            gameNameLabel.centerYAnchor.constraint(equalTo: selectLotteryView.centerYAnchor),
            gameNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: gameTitleLabel.trailingAnchor, constant: 8),
            
            // selectLinesView constraints
            selectLinesView.topAnchor.constraint(equalTo: selectLotteryView.bottomAnchor, constant: 20),
            selectLinesView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectLinesView.widthAnchor.constraint(equalToConstant: 343),
            
            // linesTitleLabel constraints
            linesTitleLabel.leadingAnchor.constraint(equalTo: selectLinesView.leadingAnchor, constant: 16),
            linesTitleLabel.topAnchor.constraint(equalTo: selectLinesView.topAnchor, constant: 8),
            
            // linesCountLabel constraints
            linesCountLabel.trailingAnchor.constraint(equalTo: selectLinesView.trailingAnchor, constant: -16),
            linesCountLabel.topAnchor.constraint(equalTo: selectLinesView.topAnchor, constant: 8),
            linesCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: linesTitleLabel.trailingAnchor, constant: 8),
            
            // customPickerView constraints
            customPickerView.trailingAnchor.constraint(equalTo: selectLinesView.trailingAnchor, constant: -16),
            customPickerView.topAnchor.constraint(equalTo: linesTitleLabel.bottomAnchor, constant: 8),
            customPickerView.widthAnchor.constraint(equalToConstant: 122),
            customPickerView.heightAnchor.constraint(equalToConstant: 60),
            
            // amountLabel constraints
            amountLabel.leadingAnchor.constraint(equalTo: selectLinesView.leadingAnchor, constant: 16),
            amountLabel.centerYAnchor.constraint(equalTo: customPickerView.centerYAnchor),
            amountLabel.trailingAnchor.constraint(lessThanOrEqualTo: customPickerView.leadingAnchor, constant: -8),
            
            // minusButton constraints
            minusButton.leadingAnchor.constraint(equalTo: customPickerView.leadingAnchor, constant: 8),
            minusButton.centerYAnchor.constraint(equalTo: customPickerView.centerYAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 30),
            
            // plusButton constraints
            plusButton.trailingAnchor.constraint(equalTo: customPickerView.trailingAnchor, constant: -8),
            plusButton.centerYAnchor.constraint(equalTo: customPickerView.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 30),
            
            // numberLabel constraints
            numberLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor, constant: 8),
            numberLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -8),
            numberLabel.centerYAnchor.constraint(equalTo: customPickerView.centerYAnchor)
        ])
        
        // Constraints for selectLinesView's bottom anchor
        selectLinesViewBottomConstraintCollapsed = selectLinesView.bottomAnchor.constraint(equalTo: linesCountLabel.bottomAnchor, constant: 8)
        selectLinesViewBottomConstraintExpanded = selectLinesView.bottomAnchor.constraint(equalTo: customPickerView.bottomAnchor, constant: 8)
        
        // Initially, activate collapsed constraint
        selectLinesViewBottomConstraintCollapsed.isActive = true
    }
    
    // MARK: - Actions
    
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
