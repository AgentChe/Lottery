import UIKit
import Lottie

final class WelcomeView: UIView {
    
    // MARK: - UI Components
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "OnboardingBackground"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let startButton: UIButton = {
        let button = UIButton()
        let attrs = TextAttributes()
            .textColor(.white)
            .font(Fonts.Inter.medium(size: 17.scale))
        let attributedTitle = "Continue".localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let scanAndWinImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ScanAndWin"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Replace logoImageView with LottieAnimationView
    private let animationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: "Animation01")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.play() // Starts the animation
        return animationView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 16.scale))
            .textAlignment(.center)
        label.attributedText = "Follow lottery games, scan tickets, and analyze results, on the go.".localized.attributed(with: attrs)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods

private extension WelcomeView {
    func setupView() {
        backgroundColor = Appearance.main400
        
        // Add the background image view as the first subview (behind all other components)
        addSubview(backgroundImageView)
        addSubview(scanAndWinImageView)
        addSubview(animationView) // Add the Lottie animation view
        addSubview(descriptionLabel)
        addSubview(startButton)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        // Set the background image to cover the full screen
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // Set constraints for ScanAndWinImageView
        NSLayoutConstraint.activate([
            scanAndWinImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scanAndWinImageView.bottomAnchor.constraint(equalTo: animationView.topAnchor, constant: -20.scale),
            scanAndWinImageView.widthAnchor.constraint(equalToConstant: 311.scale),
            scanAndWinImageView.heightAnchor.constraint(equalToConstant: 76.scale)
        ])
        
        // Set constraints for AnimationView (formerly LogoImageView)
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 343.scale : 343.scale * 0.86),
            animationView.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 356.scale : 356.scale * 0.86)
        ])
        
        // Set constraints for DescriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 10.scale),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        // Set constraints for StartButton
        NSLayoutConstraint.activate([
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -50.scale : -20.scale),
            startButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 343.scale),
            startButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
    }
}
