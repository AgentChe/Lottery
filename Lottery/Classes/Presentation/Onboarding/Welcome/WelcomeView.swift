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
    
    // Replace ScanAndWinImageView with ScanAndWinLabel
    private let scanAndWinLabel: UILabel = {
        let label = UILabel()

        // Create a paragraph style for line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10.scale // Adjust this value to increase or decrease the line spacing

        // Create the attributed string with the desired text
        let text = NSMutableAttributedString(
            string: "Scan and win\n",
            attributes: [
                .font: Fonts.Inter.semiBold(size: 28.scale),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle // Apply the paragraph style to this line
            ]
        )

        // Append the second part of the text with its own attributes
        text.append(NSAttributedString(
            string: "right from your phone",
            attributes: [
                .font: Fonts.Inter.semiBold(size: 28.scale),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5),
                .paragraphStyle: paragraphStyle // Apply the same paragraph style to this line
            ]
        ))

        // Set the attributed text to the label
        label.attributedText = text
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
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
        
        addSubview(backgroundImageView)
        addSubview(scanAndWinLabel) // Add the ScanAndWinLabel
        addSubview(animationView)
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
        
        // Set constraints for ScanAndWinLabel
        NSLayoutConstraint.activate([
            scanAndWinLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            scanAndWinLabel.bottomAnchor.constraint(equalTo: animationView.topAnchor, constant: -20.scale),
            scanAndWinLabel.widthAnchor.constraint(equalToConstant: 311.scale),
            scanAndWinLabel.heightAnchor.constraint(equalToConstant: 90.scale)
        ])
        
        // Set constraints for AnimationView
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
