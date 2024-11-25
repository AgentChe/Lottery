import UIKit

class SheetViewController: UIViewController {

    // Dash ImageView for the handle
    private let dashImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "DeniedNotifications.dash")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Background view with rounded top corners
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.main400
        view.layer.cornerRadius = 32.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top left and right corners
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // ImageView for Denied Notifications
    private let notificationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "DeniedNotifications.image")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Replacing titleLabel and messageLabel with headerLabel and descriptionLabel from NotificationRequestViewController
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "SheetViewController.headerLabelText".localized.uppercased()
        label.font = Fonts.Inter.bold(size: 16.scale)
        label.textColor = Appearance.mono200
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        let attrs = TextAttributes()
            .textColor(.white)
            .font(Fonts.Inter.bold(size: 14.scale))
            .lineHeight(21.scale)
        
        label.attributedText = "SheetViewController.descriptionLabelText".localized.attributed(with: attrs)
        label.font = Fonts.Inter.regular(size: 14.scale)
        label.textColor = Appearance.main300
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Allow Button
    private let allowButton: UIButton = {
        let button = UIButton()
        
        let attrs = TextAttributes()
            .textColor(.white)
            .font(Fonts.Inter.bold(size: 14.scale))
            
        let attributedTitle = "SheetViewController.allowButton".localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 20.scale
        button.addTarget(self, action: #selector(allowButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Deny Button
    private let denyButton: UIButton = {
        let button = UIButton()
        
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.medium(size: 14.scale))
        
        let attributedTitle = "SheetViewController.denyButton".localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.backgroundColor = Appearance.mono100
        button.layer.cornerRadius = 20.scale
        button.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        button.layer.borderWidth = 1.scale
        button.addTarget(self, action: #selector(denyButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear // Make the background of the view controller clear
        
        // Add dashImageView to the main view
        view.addSubview(dashImageView)
        
        // Add backgroundView to the main view
        view.addSubview(backgroundView)
        
        // Add all other subviews to the backgroundView
        backgroundView.addSubview(notificationImageView)
        backgroundView.addSubview(headerLabel)
        backgroundView.addSubview(descriptionLabel)
        backgroundView.addSubview(allowButton)
        backgroundView.addSubview(denyButton)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // Dash ImageView Constraints
            dashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dashImageView.bottomAnchor.constraint(equalTo: backgroundView.topAnchor, constant: -6.scale),
            dashImageView.widthAnchor.constraint(equalToConstant: 32.scale),
            dashImageView.heightAnchor.constraint(equalToConstant: 4.scale),
            
            // Background View Constraints
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 385.scale),
            
            // Image View Constraints
            notificationImageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 24.scale),
            notificationImageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            notificationImageView.widthAnchor.constraint(equalToConstant: 130.scale),
            notificationImageView.heightAnchor.constraint(equalToConstant: 130.scale),
            
            // Header Label Constraints (pinned to the bottom of the image view)
            headerLabel.topAnchor.constraint(equalTo: notificationImageView.bottomAnchor, constant: 6.scale),
            headerLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            
            // Description Label Constraints
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10.scale),
            descriptionLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20.scale),
            descriptionLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20.scale),
            
            // Allow Button Constraints
            allowButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20.scale),
            allowButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20.scale),
            allowButton.heightAnchor.constraint(equalToConstant: 44.scale),
            allowButton.bottomAnchor.constraint(equalTo: denyButton.topAnchor, constant: -10.scale),
            
            // Deny Button Constraints
            denyButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20.scale),
            denyButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20.scale),
            denyButton.heightAnchor.constraint(equalToConstant: 44.scale),
            denyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.scale)
        ])
    }
    
    @objc private func allowButtonTapped() {
        // Request notification authorization when the allow button is tapped
        PushNotificationsManager.shared.requestAuthorization() { bool in
            if let noticiationRequestViewControleller = self.presentingViewController as? NotificationRequestViewController {
                if let onboardingViewController = noticiationRequestViewControleller.presentingViewController as? OnboardingViewController {
                    self.dismiss(animated: true) {
                        noticiationRequestViewControleller.dismiss(animated: true) {
                            onboardingViewController.completeOnboarding()
                        }
                    }
                } else {
                    self.dismiss(animated: true) {
                        noticiationRequestViewControleller.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    @objc private func denyButtonTapped() {
        if let noticiationRequestViewControleller = self.presentingViewController as? NotificationRequestViewController {
            if let onboardingViewController = noticiationRequestViewControleller.presentingViewController as? OnboardingViewController {
                self.dismiss(animated: true) {
                    noticiationRequestViewControleller.dismiss(animated: true) {
                        onboardingViewController.completeOnboarding()
                    }
                }
            }
        }
    }
}
