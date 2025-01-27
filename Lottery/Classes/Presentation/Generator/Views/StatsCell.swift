import UIKit
class TopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let fittingSize = sizeThatFits(rect.size) // Get the size that fits the text
        let adjustedRect = CGRect(
            origin: CGPoint(x: rect.origin.x, y: rect.origin.y + 2.scale),
            size: CGSize(width: rect.width, height: fittingSize.height)
        )
        super.drawText(in: adjustedRect)
    }
}

class StatsCell: UICollectionViewCell {
    static let reusableIdentifier: String = "StatsCell"
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "Generator.statsBacground") // Replace with your image name
        return imageView
    }()
    
    private let statsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up the text with increased kerning
        let text = "STATS"
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .font: Fonts.Inter.bold(size: 12.scale),
                .foregroundColor: Appearance.mono100,
                .kern: 1.5 // Adjust the kern value as needed
            ]
        )
        
        label.attributedText = attributedString
        label.textAlignment = .left
        return label
    }()
    
    private let whiteBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 16.scale
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2.scale
        view.layer.borderColor = UIColor(red: 178/255.0, green: 112/255.0, blue: 157/255.0, alpha: 1.0).cgColor
        return view
    }()
    
    // Detailed stats labels and lines
    private let scoreOfNumbersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up the text with increased kerning
        let text = "score of numbers".uppercased()
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .font: Fonts.Inter.medium(size: 12.scale),
                .foregroundColor: Appearance.mono200,
                .kern: 1.5 // Adjust the kern value as needed
            ]
        )
        
        label.attributedText = attributedString
        label.textAlignment = .left
        return label
    }()
    
    private let scoreOfNumberActualNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0%"
        label.font = Fonts.Inter.extraBold(size: 24.scale)
        label.textColor = Appearance.statsGreen
        return label
    }()
    
    private let firstDashedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "FullTicket.Spearator")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let numbersFrequencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up the text with increased kerning
        let text = "regular numbers frequency".uppercased()
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .font: Fonts.Inter.medium(size: 12.scale),
                .foregroundColor: Appearance.mono200,
                .kern: 1.5 // Adjust the kern value as needed
            ]
        )
        
        label.attributedText = attributedString
        label.textAlignment = .left
        return label
    }()
    
    private let numbersFrequencyActualNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0%"
        label.font = Fonts.Inter.extraBold(size: 24.scale)
        label.textColor = Appearance.statsOrange
        return label
    }()
    
    private let numbersFrequencyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // Set up the text and paragraph style
        let text = "69% of the numbers you selected have appeared more frequently than the average in the recent period"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.4
        
        // Create an attributed string with the paragraph style
        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: Fonts.Inter.medium(size: 12.scale),
                .foregroundColor: Appearance.main300,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        label.attributedText = attributedText
        label.numberOfLines = 2
        return label
    }()
    
    private let secondDashedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "FullTicket.Spearator")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let skippedNumbersAnalyticsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up the text with increased kerning
        let text = "skipped numbers analytics".uppercased()
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .font: Fonts.Inter.medium(size: 12.scale),
                .foregroundColor: Appearance.mono200,
                .kern: 1.5 // Adjust the kern value as needed
            ]
        )
        
        label.attributedText = attributedString
        label.textAlignment = .left
        return label
    }()
    
    private let skippedNumbersAnalyticsActualNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0%"
        label.font = Fonts.Inter.extraBold(size: 24.scale)
        label.textColor = Appearance.statsGreen
        return label
    }()
    
    private let skippedNumbersAnalyticsActualNumberDescriptionLabel: TopAlignedLabel = {
        let label = TopAlignedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        
        // Set up the text and paragraph style
        let text = "76% of the numbers you selected have more missed draws"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.4
        
        // Create an attributed string with the paragraph style
        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: Fonts.Inter.medium(size: 12.scale),
                .foregroundColor: Appearance.main300,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        label.attributedText = attributedText
        label.textAlignment = .left // Adjust alignment as needed
        
        return label
    }()

    
    private let thirdDashedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "FullTicket.Spearator")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let consecutiveNumbersAnalyticsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up the text with increased kerning
        let text = "consecutive numers analytics".uppercased()
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .font: Fonts.Inter.medium(size: 12.scale),
                .foregroundColor: Appearance.mono200,
                .kern: 1.5 // Adjust the kern value as needed
            ]
        )
        
        label.attributedText = attributedString
        label.textAlignment = .left
        return label
    }()
    
    private let consecutiveNumbersAnalyticsActualNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0%"
        label.font = Fonts.Inter.extraBold(size: 24.scale)
        label.textColor = Appearance.statsGreen
        return label
    }()
    
    private let analyticDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up the text and paragraph style
        let text = "0 of the numbers you selected have been drawn in the previous draw"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.4
        
        // Create an attributed string with the paragraph style
        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: Fonts.Inter.medium(size: 12.scale),
                .foregroundColor: Appearance.main300,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        label.attributedText = attributedText
        label.numberOfLines = 2
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .orange
        layer.cornerRadius = 16.scale
        layer.masksToBounds = true
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(_ response: GeneratorResponse) {
        scoreOfNumberActualNumberLabel.text = response.scoreOfNumbers.value
     
        numbersFrequencyActualNumberLabel.text = response.regularNumbersFrequency.value
        // Set up the text and paragraph style
        let text = response.regularNumbersFrequency.infoDescription
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.4
        
        // Create an attributed string with the paragraph style
        let attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: Fonts.Inter.medium(size: 12.scale),
                .foregroundColor: Appearance.main300,
                .paragraphStyle: paragraphStyle
            ]
        )
        numbersFrequencyDescriptionLabel.attributedText = attributedText
        
      
        
        
        skippedNumbersAnalyticsActualNumberLabel.text = response.skippedNumbersAnalytics.value
        // Set up the text and paragraph style
        let skippedNumbers_text = response.skippedNumbersAnalytics.infoDescription
        let skippedNumbers_paragraphStyle = NSMutableParagraphStyle()
        skippedNumbers_paragraphStyle.lineHeightMultiple = 1.4
        
        // Create an attributed string with the paragraph style
        let skippedNumbers_attributedText = NSAttributedString(
            string: skippedNumbers_text,
            attributes: [
                .font: Fonts.Inter.medium(size: 12.scale),
                .foregroundColor: Appearance.main300,
                .paragraphStyle: skippedNumbers_paragraphStyle
            ]
        )
        
        skippedNumbersAnalyticsActualNumberDescriptionLabel.attributedText = skippedNumbers_attributedText
        
        
        consecutiveNumbersAnalyticsActualNumberLabel.text = response.consecutiveNumbersAnalytics.value
        
        // Set up the text and paragraph style
        let consecutiveNumbers_text = response.consecutiveNumbersAnalytics.infoDescription
        let consecutiveNumbers_paragraphStyle = NSMutableParagraphStyle()
        consecutiveNumbers_paragraphStyle.lineHeightMultiple = 1.4
        
        // Create an attributed string with the paragraph style
        let consecutiveNumbers_attributedText = NSAttributedString(
            string: consecutiveNumbers_text,
            attributes: [
                .font: Fonts.Inter.medium(size: 12.scale),
                .foregroundColor: Appearance.main300,
                .paragraphStyle: consecutiveNumbers_paragraphStyle
            ]
        )
        
        analyticDescriptionLabel.attributedText = consecutiveNumbers_attributedText
        
        
    }
    
    private func setupSubviews() {
        // Add background and main label
        insertSubview(backgroundImageView, at: 0)
        addSubview(statsLabel)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            statsLabel.widthAnchor.constraint(equalToConstant: 327.scale),
            statsLabel.heightAnchor.constraint(equalToConstant: 24.scale),
            statsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            statsLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8.scale)
        ])
        
        // Add the white background view and its constraints
        backgroundImageView.addSubview(whiteBackgroundView)
        NSLayoutConstraint.activate([
            whiteBackgroundView.widthAnchor.constraint(equalToConstant: 343.scale),
            whiteBackgroundView.heightAnchor.constraint(equalToConstant: 456.scale),
            whiteBackgroundView.centerXAnchor.constraint(equalTo: backgroundImageView.centerXAnchor),
            whiteBackgroundView.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor),
        ])
        
        // Add all labels and dashed lines to whiteBackgroundView
        [scoreOfNumbersLabel, scoreOfNumberActualNumberLabel, firstDashedImageView,
         numbersFrequencyLabel, numbersFrequencyActualNumberLabel, numbersFrequencyDescriptionLabel,
         secondDashedImageView, skippedNumbersAnalyticsLabel, skippedNumbersAnalyticsActualNumberLabel,
         skippedNumbersAnalyticsActualNumberDescriptionLabel, thirdDashedImageView,
         consecutiveNumbersAnalyticsLabel, consecutiveNumbersAnalyticsActualNumberLabel, analyticDescriptionLabel
        ].forEach { whiteBackgroundView.addSubview($0) }
        
        // Set up constraints for each label and dashed line
        NSLayoutConstraint.activate([
            // Score of Numbers
            scoreOfNumbersLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 19.scale),
            scoreOfNumbersLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16.scale),
            
            scoreOfNumberActualNumberLabel.topAnchor.constraint(equalTo: scoreOfNumbersLabel.bottomAnchor, constant: 5.scale),
            scoreOfNumberActualNumberLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16.scale),
            
            
            // First Dashed Line
            firstDashedImageView.topAnchor.constraint(equalTo: scoreOfNumberActualNumberLabel.bottomAnchor, constant: 12.scale),
            firstDashedImageView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor,constant: 16.scale),
            firstDashedImageView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor,constant: -16.scale),
            firstDashedImageView.heightAnchor.constraint(equalToConstant: 1.scale),
            
            // Numbers Frequency
            numbersFrequencyLabel.topAnchor.constraint(equalTo: firstDashedImageView.bottomAnchor, constant: 16.scale),
            numbersFrequencyLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16.scale),
            
            numbersFrequencyActualNumberLabel.topAnchor.constraint(equalTo: numbersFrequencyLabel.bottomAnchor, constant: 6.scale),
            numbersFrequencyActualNumberLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16.scale),
            
            numbersFrequencyDescriptionLabel.topAnchor.constraint(equalTo: numbersFrequencyActualNumberLabel.bottomAnchor, constant: 0.scale),
            numbersFrequencyDescriptionLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16.scale),
            numbersFrequencyDescriptionLabel.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -16.scale),
            numbersFrequencyDescriptionLabel.heightAnchor.constraint(equalToConstant: 44.scale),
            
            // Second Dashed Line
            secondDashedImageView.topAnchor.constraint(equalTo: numbersFrequencyDescriptionLabel.bottomAnchor, constant: 12.scale),
            secondDashedImageView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor,constant: 16.scale),
            secondDashedImageView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor,constant: -16.scale),
            secondDashedImageView.heightAnchor.constraint(equalToConstant: 1.scale),
            
            // Skipped Numbers Analytics
            skippedNumbersAnalyticsLabel.topAnchor.constraint(equalTo: secondDashedImageView.bottomAnchor, constant: 16.scale),
            skippedNumbersAnalyticsLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16.scale),
            
            skippedNumbersAnalyticsActualNumberLabel.topAnchor.constraint(equalTo: skippedNumbersAnalyticsLabel.bottomAnchor, constant: 6.scale),
            skippedNumbersAnalyticsActualNumberLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16.scale),
            
            skippedNumbersAnalyticsActualNumberDescriptionLabel.topAnchor.constraint(equalTo: skippedNumbersAnalyticsActualNumberLabel.bottomAnchor, constant: 0.scale),
            skippedNumbersAnalyticsActualNumberDescriptionLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16.scale),
            skippedNumbersAnalyticsActualNumberDescriptionLabel.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -16.scale),
            skippedNumbersAnalyticsActualNumberDescriptionLabel.heightAnchor.constraint(equalToConstant: 44.scale),
            
            // Third Dashed Line
            thirdDashedImageView.topAnchor.constraint(equalTo: skippedNumbersAnalyticsActualNumberDescriptionLabel.bottomAnchor, constant: 12.scale),
            thirdDashedImageView.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor,constant: 16.scale),
            thirdDashedImageView.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor,constant: -16.scale),
            thirdDashedImageView.heightAnchor.constraint(equalToConstant: 1.scale),
            
            // Consecutive Numbers Analytics
            consecutiveNumbersAnalyticsLabel.topAnchor.constraint(equalTo: thirdDashedImageView.bottomAnchor, constant: 16.scale),
            consecutiveNumbersAnalyticsLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16.scale),
            
            consecutiveNumbersAnalyticsActualNumberLabel.topAnchor.constraint(equalTo: consecutiveNumbersAnalyticsLabel.bottomAnchor, constant: 6.scale),
            consecutiveNumbersAnalyticsActualNumberLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: 16.scale),
            
            // Fourth Dashed Line
            analyticDescriptionLabel.topAnchor.constraint(equalTo: consecutiveNumbersAnalyticsActualNumberLabel.bottomAnchor, constant: 0.scale),
            analyticDescriptionLabel.centerXAnchor.constraint(equalTo: whiteBackgroundView.centerXAnchor),
            analyticDescriptionLabel.widthAnchor.constraint(equalToConstant: 311.scale),
            analyticDescriptionLabel.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
        
        
    }
    
}
