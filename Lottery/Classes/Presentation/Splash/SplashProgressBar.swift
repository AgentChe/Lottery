import UIKit

class SplashProgressBar: UIView {

    private let loaderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "onboardingLoader")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.textColor = .white
        label.font = Fonts.Inter.medium(size: 14.scale)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupView()
        startLoadingAnimation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        startLoadingAnimation()
    }
    
    private func setupView() {
        addSubview(loaderImageView)

        NSLayoutConstraint.activate([
            loaderImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loaderImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            loaderImageView.widthAnchor.constraint(equalToConstant: 24.scale),
            loaderImageView.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
        
        addSubview(progressLabel)
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: loaderImageView.bottomAnchor, constant: 10.scale)
        ])
    }
    
    private func startLoadingAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 0.5
        rotation.repeatCount = .infinity
        loaderImageView.layer.add(rotation, forKey: "rotateAnimation")
    }
    
    func updateProgressText(_ text: String) {
        progressLabel.text = text
    }
    
    func stopLoading() {
        loaderImageView.layer.removeAnimation(forKey: "rotateAnimation")
        removeFromSuperview()
    }
}
