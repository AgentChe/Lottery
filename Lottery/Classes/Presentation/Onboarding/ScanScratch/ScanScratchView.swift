import UIKit
import Lottie
import RiveRuntime
final class ScanScratchView: UIView, RivePlayerDelegate {
    func player(playedWithModel riveModel: RiveRuntime.RiveModel?) {
        
    }
    
    func player(pausedWithModel riveModel: RiveRuntime.RiveModel?) {
        
    }
    
    func player(loopedWithModel riveModel: RiveRuntime.RiveModel?, type: Int) {
        
    }
    
    func player(stoppedWithModel riveModel: RiveRuntime.RiveModel?) {
        
    }
    var duration: Double = 0
    func player(didAdvanceby seconds: Double, riveModel: RiveRuntime.RiveModel?) {
        duration += seconds
        if duration >= 3.0840116666804533 {
        //    riveViewModel.stop()
        }
    }
    
    
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
        
        // Localize the button title
        let attributedTitle = NSLocalizedString("Continue", comment: "Start button title").localized.attributed(with: attrs)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Replace drawSandScratchOffsImageView with drawsAndScratchLabel
    private let drawsAndScratchLabel: UILabel = {
        let label = UILabel()

        // Create a paragraph style for line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10.scale // Adjust this value to increase or decrease the line spacing

        // Localize the label's text
        let text = NSMutableAttributedString(
            string: NSLocalizedString("Draws & scratch-offs\n", comment: "Title for draws and scratch-offs"),
            attributes: [
                .font: Fonts.Inter.semiBold(size: 28.scale),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle // Apply the paragraph style to this line
            ]
        )

        // Append the second part of the text with its own attributes and localization
        text.append(NSAttributedString(
            string: NSLocalizedString("in one place", comment: "Subtitle for draws and scratch-offs"),
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
  
    private let riveViewModel = RiveViewModel(fileName: "lottery_welcome_screen_02", autoPlay: false)

    private lazy var animationView: UIView = {
        // Create a RiveView using RiveViewModel
        let riveView = riveViewModel.createRiveView()
        riveView.translatesAutoresizingMaskIntoConstraints = false
        riveViewModel.play(loop:.oneShot) // Start the animation
        riveView.playerDelegate = self
        return riveView
    }()
    
    // Add new UILabel beneath the animation view
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 16.scale))
            .textAlignment(.center)
        
        // Localize the description text
        label.attributedText = NSLocalizedString("Stay on top of every lottery game's result. Never miss a chance to win!", comment: "Description of lottery benefits").localized.attributed(with: attrs)
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

private extension ScanScratchView {
    func setupView() {
        backgroundColor = Appearance.main400
        
        // Add the background image view
        addSubview(backgroundImageView)
        addSubview(drawsAndScratchLabel) // Add the Draws and Scratch Offs label
        addSubview(animationView) // Add the Lottie animation view
        addSubview(descriptionLabel) // Add the description label
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
        
        // Set constraints for the DrawsAndScratchLabel
        NSLayoutConstraint.activate([
            drawsAndScratchLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            drawsAndScratchLabel.bottomAnchor.constraint(equalTo: animationView.topAnchor, constant: -20.scale),
            drawsAndScratchLabel.widthAnchor.constraint(equalToConstant: 311.scale),
            drawsAndScratchLabel.heightAnchor.constraint(equalToConstant: 90.scale)
        ])
        
        // Set constraints for the LottieAnimationView
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 343.scale : 343.scale * 0.86),
            animationView.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 343.scale : 343.scale * 0.86)
        ])
        
        // Set constraints for the description label
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 20.scale),
            descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalToConstant: 295.scale),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
        
        // Set constraints for the start button
        NSLayoutConstraint.activate([
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -50.scale : -20.scale),
            startButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 343.scale),
            startButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
    }
}
