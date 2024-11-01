import UIKit

class GeneratedNumbersViewController: UIViewController {
  
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
        
        delay(5) {
            // Remove the rotation animation
            self.spinImageView.layer.removeAnimation(forKey: "rotateAnimation")
            
            // Fade out the spinImageView and generateNumbersLabel
            UIView.animate(withDuration: 0) {
                self.spinImageView.alpha = 0
                self.generateNumbersLabel.alpha = 0
                self.numbersImageView.alpha = 0
            }
        }
    }
    
    private func setupSubviews() {
        view.addSubview(backgroundfullView)
        view.addSubview(spinImageView)
        view.addSubview(generateNumbersLabel)
        view.addSubview(numbersImageView)
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
    }
    
    private func startSpinAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.toValue = CGFloat.pi * 20
        rotation.duration = 5
        rotation.repeatCount = .infinity
        spinImageView.layer.add(rotation, forKey: "rotateAnimation")
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
