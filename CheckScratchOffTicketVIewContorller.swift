import UIKit
class PaddedLabel: UILabel {
    
    var textInsets = UIEdgeInsets(top: 20.scale, left: 16.scale, bottom: 16.scale, right: 16.scale) {
        didSet {
            setNeedsDisplay() // Redraw the label with the new insets
        }
    }
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
}

class CheckScratchOffTicketViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        if let image = UIImage(named: "pastDrawDefBcg") {
            imageView.image = image
        }
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 15.scale
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textLabel: PaddedLabel = {
        let label = PaddedLabel()
        label.numberOfLines = 0
        label.backgroundColor = Appearance.mono100
        label.textAlignment = .left
        label.text = "To implement the /scratchoffs/list endpoint and retrieve an array of the same objects..."
        label.font = Fonts.Inter.medium(size: 14.scale)
        label.layer.cornerRadius = 10.scale
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    private let saveTicketButton: UIButton = {
        let button = UIButton()
        button.setTitle("CheckTicketViewController.SaveTicketButton".localized, for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.layer.cornerRadius = 25.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTicketButtonTapped), for: .touchUpInside)
        button.isEnabled = true // Initially disabled
        return button
    }()
    
    private let rescanButton: UIButton = {
        let button = UIButton()
        button.setTitle("CheckTicketViewController.RescanButton".localized, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(Appearance.mono200, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.layer.cornerRadius = 25.scale
        button.layer.borderWidth = 1.scale
        button.layer.borderColor = Appearance.lightGrayBorderTicket.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(rescanButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        // Add scrollView and contentView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add imageView, titleLabel, and buttons to contentView
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
        contentView.addSubview(saveTicketButton)
        contentView.addSubview(rescanButton)
        
        // Constraints for scrollView and contentView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Constraints for imageView
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.scale),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            imageView.widthAnchor.constraint(equalToConstant: 140.scale),
            imageView.heightAnchor.constraint(equalToConstant: 174.scale) // Adjust as necessary
        ])
        
        // Constraints for titleLabel (dynamic height)
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20.scale),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale)
        ])
        
        // Constraints for buttons
        NSLayoutConstraint.activate([
            saveTicketButton.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 40.scale),
            saveTicketButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            saveTicketButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            saveTicketButton.heightAnchor.constraint(equalToConstant: 50.scale),
            
            rescanButton.topAnchor.constraint(equalTo: saveTicketButton.bottomAnchor, constant: 10.scale),
            rescanButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            rescanButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            rescanButton.heightAnchor.constraint(equalToConstant: 50.scale),
            rescanButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.scale) // To ensure scrollable content
        ])
    }
    
    // Button actions
    @objc private func saveTicketButtonTapped() {
        // Handle save button tap
        if let viewControllers = navigationController?.viewControllers {
            let targetIndex = viewControllers.count - 3
            if targetIndex >= 0 {
                let targetViewController = viewControllers[targetIndex]
                navigationController?.popToViewController(targetViewController, animated: true)
            }
        }
    }
    
    @objc private func rescanButtonTapped() {    
        if let viewControllers = navigationController?.viewControllers {
            let targetIndex = viewControllers.count - 3
            if targetIndex >= 0 {
                let targetViewController = viewControllers[targetIndex]
                navigationController?.popToViewController(targetViewController, animated: true)
            }
        }
    }
}
