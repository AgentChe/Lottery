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
    
    private let backgroundfullView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "TicketsVCBackgroundImage")
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
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
    
    var generateButton: UIButton = {
          let button = UIButton(type: .system)
          button.translatesAutoresizingMaskIntoConstraints = false
          button.setTitle("Generate", for: .normal)
          button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
          button.backgroundColor = .systemBlue
          button.layer.cornerRadius = 8
          button.setTitleColor(.white, for: .normal)
          return button
      }()
    
    // Constraints for selectLinesView's bottom

    private var selectLinesViewHeightConstraintCollapsed: NSLayoutConstraint!
    var selectLinesViewBottomConstraintExpanded: NSLayoutConstraint!
    
    // MARK: - Gestures
    
    let stateTapGesture = UITapGestureRecognizer()
    let lotteryTapGesture = UITapGestureRecognizer()
    let linesTapGesture = UITapGestureRecognizer()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBarTitle()
        setupViews()
        setupGestures()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    
    func setupViews() {
         view.addSubview(backgroundfullView)
         
         // Add existing views to backgroundfullView
         backgroundfullView.addSubview(selectStateView)
         selectStateView.addSubview(stateTitleLabel)
         selectStateView.addSubview(stateNameLabel)
         
         backgroundfullView.addSubview(selectLotteryView)
         selectLotteryView.addSubview(gameTitleLabel)
         selectLotteryView.addSubview(gameNameLabel)
         
         backgroundfullView.addSubview(selectLinesView)
         selectLinesView.addSubview(linesTitleLabel)
         selectLinesView.addSubview(linesCountLabel)
         selectLinesView.addSubview(customPickerView)
         selectLinesView.addSubview(amountLabel)
         
         customPickerView.addSubview(minusButton)
         customPickerView.addSubview(numberLabel)
         customPickerView.addSubview(plusButton)
         
         // Add the generate button
         backgroundfullView.addSubview(generateButton)
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
        setupBackgroundConstraints()
        setupSelectStateViewConstraints()
        setupSelectLotteryViewConstraints()
        setupSelectLinesViewConstraints()
        setupCustomPickerViewConstraints()
        setupAmountLabelConstraints()
        setupGenerateButtonConstraints()
    }

    private func setupBackgroundConstraints() {
        NSLayoutConstraint.activate([
            backgroundfullView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundfullView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundfullView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundfullView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
               
               // Deactivate collapsed height constraint
               selectLinesViewHeightConstraintCollapsed.isActive = false
               // Activate expanded constraint
               selectLinesViewBottomConstraintExpanded.isActive = true
               
               UIView.animate(withDuration: 0) {
                   self.view.layoutIfNeeded()
               }
           } else {
               // Hide custom picker and amount label
               linesCountLabel.isHidden = false
               amountLabel.isHidden = true
               customPickerView.isHidden = true
               
               // Deactivate expanded constraint
               selectLinesViewBottomConstraintExpanded.isActive = false
               // Reactivate collapsed height constraint
               selectLinesViewHeightConstraintCollapsed.isActive = true
               
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
            linesCountLabel.text = "\(currentNumber)"
        }
    }
    
    @objc func increaseNumber() {
        var currentNumber = Int(numberLabel.text!) ?? 1
        currentNumber += 1
        numberLabel.text = "\(currentNumber)"
        linesCountLabel.text = "\(currentNumber)"
    }
}
//MARK: Setup constraints
extension GeneratorViewController {

    private func setupSelectStateViewConstraints() {
        NSLayoutConstraint.activate([
            selectStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20.scale),
            selectStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectStateView.widthAnchor.constraint(equalToConstant: 343.scale),
            selectStateView.heightAnchor.constraint(equalToConstant: 56.scale),
            
            stateTitleLabel.leadingAnchor.constraint(equalTo: selectStateView.leadingAnchor, constant: 16.scale),
            stateTitleLabel.centerYAnchor.constraint(equalTo: selectStateView.centerYAnchor),
            
            stateNameLabel.trailingAnchor.constraint(equalTo: selectStateView.trailingAnchor, constant: -16.scale),
            stateNameLabel.centerYAnchor.constraint(equalTo: selectStateView.centerYAnchor),
            stateNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: stateTitleLabel.trailingAnchor, constant: 8.scale)
        ])
    }

    private func setupSelectLotteryViewConstraints() {
        NSLayoutConstraint.activate([
            selectLotteryView.topAnchor.constraint(equalTo: selectStateView.bottomAnchor, constant: 20.scale),
            selectLotteryView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectLotteryView.widthAnchor.constraint(equalToConstant: 343.scale),
            selectLotteryView.heightAnchor.constraint(equalToConstant: 56.scale),
            
            gameTitleLabel.leadingAnchor.constraint(equalTo: selectLotteryView.leadingAnchor, constant: 16.scale),
            gameTitleLabel.centerYAnchor.constraint(equalTo: selectLotteryView.centerYAnchor),
            
            gameNameLabel.trailingAnchor.constraint(equalTo: selectLotteryView.trailingAnchor, constant: -16.scale),
            gameNameLabel.centerYAnchor.constraint(equalTo: selectLotteryView.centerYAnchor),
            gameNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: gameTitleLabel.trailingAnchor, constant: 8.scale)
        ])
    }

    private func setupSelectLinesViewConstraints() {
        NSLayoutConstraint.activate([
            selectLinesView.topAnchor.constraint(equalTo: selectLotteryView.bottomAnchor, constant: 20.scale),
            selectLinesView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectLinesView.widthAnchor.constraint(equalToConstant: 343.scale),
            
            linesTitleLabel.leadingAnchor.constraint(equalTo: selectLinesView.leadingAnchor, constant: 16.scale),
            linesTitleLabel.topAnchor.constraint(equalTo: selectLinesView.topAnchor, constant: 16.scale),
            
            linesCountLabel.trailingAnchor.constraint(equalTo: selectLinesView.trailingAnchor, constant: -16.scale),
            linesCountLabel.topAnchor.constraint(equalTo: selectLinesView.topAnchor, constant: 16.scale),
            linesCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: linesTitleLabel.trailingAnchor, constant: 8.scale)
        ])
        
        // Add collapsed height constraint
        selectLinesViewHeightConstraintCollapsed = selectLinesView.heightAnchor.constraint(equalToConstant: 56.scale)
        selectLinesViewHeightConstraintCollapsed.isActive = true
        
        // Expanded constraint (initially inactive)
        selectLinesViewBottomConstraintExpanded = selectLinesView.bottomAnchor.constraint(equalTo: customPickerView.bottomAnchor, constant: 8.scale)
        
    }
    private func setupCustomPickerViewConstraints() {
        NSLayoutConstraint.activate([
            customPickerView.trailingAnchor.constraint(equalTo: selectLinesView.trailingAnchor, constant: -16.scale),
            customPickerView.topAnchor.constraint(equalTo: linesTitleLabel.bottomAnchor, constant: 8.scale),
            customPickerView.widthAnchor.constraint(equalToConstant: 122.scale),
            customPickerView.heightAnchor.constraint(equalToConstant: 60.scale),
            
            minusButton.leadingAnchor.constraint(equalTo: customPickerView.leadingAnchor, constant: 8.scale),
            minusButton.centerYAnchor.constraint(equalTo: customPickerView.centerYAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 30.scale),
            
            plusButton.trailingAnchor.constraint(equalTo: customPickerView.trailingAnchor, constant: -8.scale),
            plusButton.centerYAnchor.constraint(equalTo: customPickerView.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 30.scale),
            
            numberLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor, constant: 8.scale),
            numberLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -8.scale),
            numberLabel.centerYAnchor.constraint(equalTo: customPickerView.centerYAnchor)
        ])
    }

    private func setupAmountLabelConstraints() {
        NSLayoutConstraint.activate([
            amountLabel.leadingAnchor.constraint(equalTo: selectLinesView.leadingAnchor, constant: 16.scale),
            amountLabel.centerYAnchor.constraint(equalTo: customPickerView.centerYAnchor),
            amountLabel.trailingAnchor.constraint(lessThanOrEqualTo: customPickerView.leadingAnchor, constant: -8.scale)
        ])
    }

    private func setupGenerateButtonConstraints() {
        NSLayoutConstraint.activate([
            generateButton.topAnchor.constraint(equalTo: selectLinesView.bottomAnchor, constant: 20.scale),
            generateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generateButton.widthAnchor.constraint(equalToConstant: 343.scale),
            generateButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
    }
}

extension GeneratorViewController {
    private func setupNavigationBarTitle() {
        let backButton = UIButton(type: .custom)
        if let image = UIImage(named: "Generator.navigaitonBarTitle") {
            backButton.setImage(image, for: .normal)
        }
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 341.scale),
            backButton.heightAnchor.constraint(equalToConstant: 26.scale),
            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0.scale),
            backButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: backButton.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: backButton.heightAnchor)
        ])
        
        let backButtonItem = UIBarButtonItem(customView: containerView)
      
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.hidesBackButton = true
    }
    @objc private func customBackButtonTapped() {
        // Perform back navigation
      //  navigationController?.popViewController(animated: true)
    }
}
