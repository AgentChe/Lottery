import UIKit

class ImageViewController: UIViewController {
    var image: UIImage?
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20.scale
        view.layer.masksToBounds = true
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Appearance.main100
        button.layer.cornerRadius = 22.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        view.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(closeButton)
        
        imageView.image = image
        if let imageSize = imageView.image?.size {
            let width = view.frame.width * 0.9
            let height = imageSize.height * width/imageSize.width
    
            NSLayoutConstraint.activate([
                containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                containerView.widthAnchor.constraint(equalToConstant: width),
                containerView.heightAnchor.constraint(equalToConstant: height + 100.scale),
                
                imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0.scale),
                imageView.widthAnchor.constraint(equalToConstant: width),
                imageView.heightAnchor.constraint(equalToConstant: height),
                
                closeButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30.scale),
                closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                closeButton.widthAnchor.constraint(equalToConstant: 311.scale),
                closeButton.heightAnchor.constraint(equalToConstant: 44.scale)
            ])
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: false, completion: nil)
    }
}
