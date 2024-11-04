import UIKit

class GeneratedNumbersViewController: UIViewController {
 
    var lotteries: [Lottery] = []
    var selectedLottery: Int?
    var nextDraws: [Game] = []
    var lotteryPatterns: [LotteryPattern] = []
   
    var bonusIdx: [Int] = [] {
        didSet {
            for i in 0..<bonusIdx.count {
                bonusIdx[i] = bonusIdx[i] + 1
            }
        }
    }
    
    var numbers: [[Int]] = [
        [12,23,34,45,56,67],
        [19,26,35,43,54,67],
        [15,23,30,48,55,61],
        [12,23,34,45,56,67],
        [19,26,35,43,54,67],
        [19,26,35,43,54,67],
        [15,23,30,48,55,61],
        [12,23,34,45,56,67],
        [19,26,35,43,54,67],
    ]
    
    var chanceString = "Your chance of matching all numbers with this combination is 2 in 292201338"
    
    private let backgroundfullView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "TicketsVCBackgroundImage")
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let spinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Generator.spin")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let generateNumbersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Generating the numbers..."
        label.textAlignment = .center
        label.font = Fonts.Inter.semiBold(size: 14.scale)
        label.textColor = Appearance.mono200
        return label
    }()
    
    // Numbers Image View
    private let numbersImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Generator.numbers")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // Define the buttons
    private let pickAgainButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Pick again", for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.setTitleColor(Appearance.mono200, for: .normal) // Adjust the color as needed
        button.backgroundColor = Appearance.mono100 // Adjust the color as needed
        button.layer.cornerRadius = 22.scale
        button.layer.borderWidth = 1.scale
        button.layer.borderColor = Appearance.main500.cgColor
        button.addTarget(self, action: #selector(pickAgain), for: .touchUpInside)
        
        return button
    }()
    
    private let goToEditLuckyNumbersButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Use as Lucky Numbers", for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.setTitleColor(Appearance.mono100, for: .normal) // Adjust the color as needed
        button.backgroundColor = Appearance.main100 // Adjust the color as needed
        button.layer.cornerRadius = 22.scale
        button.addTarget(self, action: #selector(goToEditLuckyNumbers), for: .touchUpInside)
        return button
    }()
    
    private lazy var statsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16.scale
        layout.minimumInteritemSpacing = 16.scale
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.alpha = 0 // Initially hidden
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(GeneratedNumbersCell.self, forCellWithReuseIdentifier: GeneratedNumbersCell.reusableIdentifier)
        collectionView.register(ChanceCell.self, forCellWithReuseIdentifier: ChanceCell.reusableIdentifier)
        collectionView.register(StatsCell.self, forCellWithReuseIdentifier: StatsCell.reusableIdentifier)
        
        return collectionView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = getRootViewController() as? NavigationController,
           let mainViewController = navigationController.viewControllers.first as? MainViewController {
            updateMainViewControllerConstraints(for: mainViewController, newConstant: 300.scale)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupNavigationBarTitle()
        setupConstraints()
        startSpinAnimation()
        
        delay(0.5) {
            // Remove the rotation animation
            self.spinImageView.layer.removeAnimation(forKey: "rotateAnimation")
            
            // Fade out the spinImageView and generateNumbersLabel
            
            self.spinImageView.alpha = 0
            self.generateNumbersLabel.alpha = 0
            self.numbersImageView.alpha = 0
            self.statsCollectionView.alpha = 1
            self.pickAgainButton.isUserInteractionEnabled = true
            self.goToEditLuckyNumbersButton.isUserInteractionEnabled = true
            
            self.pickAgainButton.setTitleAlpha(1, for: .normal)
            self.goToEditLuckyNumbersButton.setTitleAlpha(1, for: .normal)
        }
    }
    @objc func goToEditLuckyNumbers() {
        var game: Game?
        for g in nextDraws {
            if g.lotteryId == selectedLottery {
                game = g
                break
            }
        }
        guard let game = game else { return }
        
        for lottery in lotteries {
            if lottery.id == selectedLottery {
                let ticket: Ticket = Ticket(id: 0,
                                            lotteryId: lottery.id,
                                            pictureUrl: lottery.logoUrl,
                                            date: game.date,
                                            numbers: numbers)
                
                let editLuckyNumbersVC = EditLuckyNumbersViewController(ticket: ticket, game: game, lotteries: lotteries)
    
                editLuckyNumbersVC.lotteryPatterns = lotteryPatterns
                navigationController?.pushViewController(editLuckyNumbersVC, animated: true)
            }
        }
    }
    @objc func pickAgain() {
        startSpinAnimation()
    }
    private func setupSubviews() {
        view.addSubview(backgroundfullView)
        backgroundfullView.addSubview(spinImageView)
        backgroundfullView.addSubview(generateNumbersLabel)
        backgroundfullView.addSubview(numbersImageView)
        backgroundfullView.addSubview(pickAgainButton)
        backgroundfullView.addSubview(goToEditLuckyNumbersButton)
        backgroundfullView.addSubview(statsCollectionView)
    }
    
    private func setupConstraints() {
        // Background view constraints
        NSLayoutConstraint.activate([
            backgroundfullView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundfullView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundfullView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundfullView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Spin image view constraints
        NSLayoutConstraint.activate([
            spinImageView.widthAnchor.constraint(equalToConstant: 24.scale),
            spinImageView.heightAnchor.constraint(equalToConstant: 24.scale),
            spinImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.scale)
        ])
        
        // Generate numbers label constraints
        NSLayoutConstraint.activate([
            generateNumbersLabel.topAnchor.constraint(equalTo: spinImageView.bottomAnchor, constant: 16.scale),
            generateNumbersLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Numbers image view constraints
        NSLayoutConstraint.activate([
            numbersImageView.widthAnchor.constraint(equalToConstant: 343.scale),
            numbersImageView.heightAnchor.constraint(equalToConstant: 248.scale),
            numbersImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            numbersImageView.topAnchor.constraint(equalTo: generateNumbersLabel.bottomAnchor, constant: 24.scale)
        ])
        // Constraints for the second button, positioned above the first button
        NSLayoutConstraint.activate([
            goToEditLuckyNumbersButton.widthAnchor.constraint(equalToConstant: 343.scale),
            goToEditLuckyNumbersButton.heightAnchor.constraint(equalToConstant: 44.scale),
            goToEditLuckyNumbersButton.centerXAnchor.constraint(equalTo: backgroundfullView.centerXAnchor),
            goToEditLuckyNumbersButton.bottomAnchor.constraint(equalTo: pickAgainButton.topAnchor, constant: -12.scale) // Adjust the constant as needed
        ])
        
        NSLayoutConstraint.activate([
            pickAgainButton.widthAnchor.constraint(equalToConstant: 343.scale),
            pickAgainButton.heightAnchor.constraint(equalToConstant: 44.scale),
            pickAgainButton.centerXAnchor.constraint(equalTo: backgroundfullView.centerXAnchor),
            pickAgainButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12.scale) // Adjust the constant as needed
        ])
        NSLayoutConstraint.activate([
            statsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.scale),
            statsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.scale),
            statsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.scale),
            statsCollectionView.bottomAnchor.constraint(equalTo: goToEditLuckyNumbersButton.topAnchor, constant: -6.scale)
        ])
        
    }
    
    private func startSpinAnimation() {
        self.spinImageView.alpha = 1
        self.generateNumbersLabel.alpha = 1
        self.numbersImageView.alpha = 1
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.toValue = CGFloat.pi * 20
        rotation.duration = 5
        rotation.repeatCount = .infinity
        spinImageView.layer.add(rotation, forKey: "rotateAnimation")
        
        pickAgainButton.isUserInteractionEnabled = false
        goToEditLuckyNumbersButton.isUserInteractionEnabled = false
        
        pickAgainButton.setTitleAlpha(0.4, for: .normal)
        goToEditLuckyNumbersButton.setTitleAlpha(0.4, for: .normal)
        
        statsCollectionView.alpha = 0
    }
}

extension GeneratedNumbersViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // Three different sections for each cell type
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3 // Assuming one cell per section, adjust as needed
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            let cellHeight = CGFloat(numbers.count)*(40.scale + 10.scale + 4.scale) + 20.scale
            return CGSize(width: collectionView.bounds.width, height: cellHeight)
        }
        if indexPath.item == 1 {
            return CGSize(width: collectionView.bounds.width, height: 69.scale)
        }
        
        if indexPath.item == 2 {
            return CGSize(width: collectionView.bounds.width, height: 496.scale)
        }
        
        fatalError()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GeneratedNumbersCell.reusableIdentifier, for: indexPath) as! GeneratedNumbersCell
            cell.bonusIdx = bonusIdx
            cell.numbers = numbers
            
            cell.configure()
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChanceCell.reusableIdentifier, for: indexPath) as! ChanceCell
            

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1 // Set your desired line height multiple here
            
            let attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: paragraphStyle,
                .font: Fonts.Inter.regular(size: 14.scale), // Ensure this matches your font
                .foregroundColor: Appearance.mono200
            ]
            
            let attributedString = NSAttributedString(string: chanceString, attributes: attributes)
            cell.chanceLabel.attributedText = attributedString
            
            
            
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatsCell.reusableIdentifier, for: indexPath) as! StatsCell
            // Configure your StatsCell
            return cell
        default:
            fatalError("Unexpected section")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16.scale, left: 0.scale, bottom: 14.scale, right: 0.scale)
    }
    
}

extension GeneratedNumbersViewController {
    private func setupNavigationBarTitle() {
        let backButton = UIButton(type: .custom)
        if let image = UIImage(named: "Generator.blankNavBar") {
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
            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: -3.scale),
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
        navigationController?.popViewController(animated: true)
    }
}

extension GeneratedNumbersViewController {
    func updateMainViewControllerConstraints(for mainViewController: MainViewController, newConstant: CGFloat = ScreenSize.isIphoneXFamily ? 100.scale : 80.scale) {
        let mainView = mainViewController.mainView
        let tabView = mainView.tabView
        tabView.alpha = 1
        if mainView.tabViewBottomConstraint?.constant != newConstant {
            if let oldTabViewBottomConstraint = mainView.tabViewBottomConstraint {
                oldTabViewBottomConstraint.isActive = false
                mainView.tabViewBottomConstraint = nil
            }
            let newTabViewBottomConstraint = tabView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: newConstant)
            mainView.tabViewBottomConstraint = newTabViewBottomConstraint
            newTabViewBottomConstraint.isActive = true
            mainView.layoutIfNeeded()
        }
    }
}
extension UIButton {
    func setTitleAlpha(_ alpha: CGFloat, for state: UIControl.State) {
        guard let currentTitle = title(for: state),
              let currentTitleColor = titleColor(for: state) else { return }
        
        let colorWithAlpha = currentTitleColor.withAlphaComponent(alpha)
        let attributedTitle = NSAttributedString(
            string: currentTitle,
            attributes: [.foregroundColor: colorWithAlpha]
        )
        
        UIView.performWithoutAnimation {
            setAttributedTitle(attributedTitle, for: state)
            layoutIfNeeded() // Forces the layout to update without animation
        }
    }
}
