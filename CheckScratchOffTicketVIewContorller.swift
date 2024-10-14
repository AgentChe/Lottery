import UIKit
import Kingfisher

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
      
      private let lotteryImageView: UIImageView = {
          let imageView = UIImageView()
          if let image = UIImage(named: "pastDrawDefBcg") {
              imageView.image = image
          }
          imageView.contentMode = .scaleToFill
          imageView.layer.cornerRadius = 15.scale
          imageView.layer.masksToBounds = true
          imageView.translatesAutoresizingMaskIntoConstraints = false
          return imageView
      }()
      
      
      private let whiteLabel: UIView = {
          let view = UIView()
          view.backgroundColor = .white
          view.layer.cornerRadius = 15.scale
          view.layer.masksToBounds = true
          view.translatesAutoresizingMaskIntoConstraints = false
          return view
      }()
      
      private let analyzeLabel: PaddedLabel = {
          let label = PaddedLabel()
          label.numberOfLines = 0
          label.backgroundColor = .clear
          label.textAlignment = .left
          label.font = Fonts.Inter.medium(size: 14.scale)
          label.layer.cornerRadius = 10.scale
          label.layer.masksToBounds = false
          label.textColor = Appearance.mono200
          label.translatesAutoresizingMaskIntoConstraints = false
          return label
      }()
      
      private let liabilityWeaverLabel: PaddedLabel = {
          let label = PaddedLabel()
          label.numberOfLines = 0
          label.text = "We do not guarantee the accuracy or completeness of the information provided. Please consult the retailer for official information."
          label.font = Fonts.Inter.medium(size: 14.scale)
          label.textAlignment = .left
          label.textColor = Appearance.mono200
          label.layer.cornerRadius = 12.scale
          label.layer.masksToBounds = true
          label.backgroundColor = UIColor(red: 0xE5 / 255.0, green: 0xE9 / 255.0, blue: 0xF5 / 255.0, alpha: 1.0)
          label.translatesAutoresizingMaskIntoConstraints = false
          return label
      }()
      
       let saveTicketButton: UIButton = {
          let button = UIButton()
          button.setTitle("CheckTicketViewController.SaveTicketButton".localized, for: .normal)
          button.backgroundColor = Appearance.main100
          button.setTitleColor(.white, for: .normal)
          button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
          button.layer.cornerRadius = 25.scale
          button.translatesAutoresizingMaskIntoConstraints = false
          button.addTarget(self, action: #selector(saveTicketButtonTapped), for: .touchUpInside)
          return button
      }()
      
       let rescanButton: UIButton = {
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
      
      private var scratchOff: ScratchOff?
      private var analyzeLabelHeightConstraint: NSLayoutConstraint?
      private var whiteLabelHeightConstraint: NSLayoutConstraint?


    init(scratchOff: ScratchOff?) {
        self.scratchOff = scratchOff
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
           super.viewDidLoad()
           setupUI()
           setupNavigationBackButton()
           
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(lotteryImageTapped))
           lotteryImageView.isUserInteractionEnabled = true
           lotteryImageView.addGestureRecognizer(tapGesture)
           
           if scratchOff?.analyze == nil || scratchOff?.analyze == "" {
               saveTicketButton.isHidden = true
               lotteryImageView.isHidden = true
               analyzeLabel.isHidden = true
               whiteLabel.isHidden = true
               showAlertAndPop()
               
           } else {
               
               if let url = URL(string: scratchOff?.imageUrl ?? "") {
                   lotteryImageView.kf.setImage(with: url)
               }
               analyzeLabel.text = scratchOff?.analyze ?? ""
               
               let font = Fonts.Inter.medium(size: 14.6.scale)
               let expectedLabelSize = calculateLabelHeight(for: scratchOff?.analyze ?? "", with: font, width: view.frame.width - 32.scale)
               
               analyzeLabelHeightConstraint?.constant = expectedLabelSize.height + 20.scale + 20.scale
               
               // White label height is analyzeLabel height + liabilityWeaverLabel fixed height (105.scale)
               whiteLabelHeightConstraint?.constant = expectedLabelSize.height + 20.scale + 20.scale + 120.scale
               view.setNeedsLayout()
           }
           view.backgroundColor = Appearance.main400
       }
    private func isLabelTruncated(label: UILabel) -> Bool {
        guard let text = label.text else { return false }
        
        let labelWidth = label.frame.size.width
        let labelHeight = label.frame.size.height

        // Create a bounding rect for the text based on the label's width
        let font = label.font ?? UIFont.systemFont(ofSize: 14)
        let textAttributes: [NSAttributedString.Key: Any] = [.font: font]
        
        let boundingRect = text.boundingRect(with: CGSize(width: labelWidth, height: .greatestFiniteMagnitude),
                                             options: [.usesLineFragmentOrigin, .usesFontLeading],
                                             attributes: textAttributes,
                                             context: nil)

        // If the bounding rect's height is greater than the label's height, text is truncated
        return boundingRect.height > labelHeight
    }
    private func showAlertAndPop() {
        let alertController = UIAlertController(title: "Error", message: "Scan unsuccessful. Try again.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func setupNavigationBackButton() {
        let backButton = UIButton(type: .custom)
        if let image = UIImage(named: "analyzeResultIImage") {
            backButton.setImage(image, for: .normal)
        }
        
        // Disable autoresizing mask translation
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.imageView?.contentMode = .scaleAspectFit
        
        // Add a target to handle back navigation
        backButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Create a container view to hold the button
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(backButton)
        
        // Set constraints for the button within the container
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 341.scale),
            backButton.heightAnchor.constraint(equalToConstant: 26.scale),
            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: -35.scale),
            backButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        // Set constraints for the container view
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: backButton.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: backButton.heightAnchor)
        ])
        
        // Create a UIBarButtonItem with the container view
        let backButtonItem = UIBarButtonItem(customView: containerView)
        
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.hidesBackButton = true
    }
    
    @objc private func customBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
           view.backgroundColor = .clear
           
           view.addSubview(scrollView)
           scrollView.addSubview(contentView)
           
           contentView.addSubview(lotteryImageView)
           contentView.addSubview(whiteLabel) // Add whiteLabel to the contentView
           whiteLabel.addSubview(analyzeLabel) // Add analyzeLabel inside whiteLabel
           whiteLabel.addSubview(liabilityWeaverLabel) // Add liabilityWeaverLabel inside whiteLabel
           contentView.addSubview(saveTicketButton)
           contentView.addSubview(rescanButton)
           rescanButton.alpha = 0
           
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
           
           NSLayoutConstraint.activate([
               lotteryImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.scale),
               lotteryImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
               lotteryImageView.widthAnchor.constraint(equalToConstant: 140.scale),
               lotteryImageView.heightAnchor.constraint(equalToConstant: 174.scale)
           ])
           
           // Add whiteLabel and set its height dynamically
           whiteLabelHeightConstraint = whiteLabel.heightAnchor.constraint(equalToConstant: 200.scale) // Initial value, will update later
           whiteLabelHeightConstraint?.isActive = true
           
           NSLayoutConstraint.activate([
               whiteLabel.topAnchor.constraint(equalTo: lotteryImageView.bottomAnchor, constant: 20.scale),
               whiteLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
               whiteLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale)
           ])
           
           analyzeLabelHeightConstraint = analyzeLabel.heightAnchor.constraint(equalToConstant: 50.scale) // Initial value, will update later
           analyzeLabelHeightConstraint?.isActive = true
           
           // Add constraints for analyzeLabel inside whiteLabel
           NSLayoutConstraint.activate([
               analyzeLabel.topAnchor.constraint(equalTo: whiteLabel.topAnchor, constant: 5.scale),
               analyzeLabel.leadingAnchor.constraint(equalTo: whiteLabel.leadingAnchor, constant: 0.scale),
               analyzeLabel.trailingAnchor.constraint(equalTo: whiteLabel.trailingAnchor, constant: 0.scale)
           ])
           
           // Add constraints for liabilityWeaverLabel inside whiteLabel
           NSLayoutConstraint.activate([
               liabilityWeaverLabel.topAnchor.constraint(equalTo: analyzeLabel.bottomAnchor, constant: 0.scale),
               liabilityWeaverLabel.leadingAnchor.constraint(equalTo: whiteLabel.leadingAnchor, constant: 16.scale),
               liabilityWeaverLabel.trailingAnchor.constraint(equalTo: whiteLabel.trailingAnchor, constant: -16.scale),
               liabilityWeaverLabel.bottomAnchor.constraint(equalTo: whiteLabel.bottomAnchor, constant: -16.scale)
           ])
           
           NSLayoutConstraint.activate([
               saveTicketButton.topAnchor.constraint(equalTo: whiteLabel.bottomAnchor, constant: 40.scale),
               saveTicketButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
               saveTicketButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
               saveTicketButton.heightAnchor.constraint(equalToConstant: 50.scale),
               
               rescanButton.topAnchor.constraint(equalTo: saveTicketButton.bottomAnchor, constant: 10.scale),
               rescanButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
               rescanButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
               rescanButton.heightAnchor.constraint(equalToConstant: 50.scale),
               rescanButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.scale)
           ])
       }
    
    @objc private func saveTicketButtonTapped() {
        guard let scratchOff = scratchOff else {
            let alertController = UIAlertController(title: "Error", message: "No ticket data available to save.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }

        // Initialize the ScanScratchManager
        let scanManager = ScanScratchManager()

        // Call the save function from ScanScratchManager
        scanManager.save(scratchOff: scratchOff) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    guard let self = self else { return }
                    guard let navigationController = self.navigationController else { return }
                    guard let drawsViewController = navigationController.viewControllers.first as? DrawsViewController else { return }
                    
                    // Modify the navigation stack to insert DrawsViewController right after the root view controller
                    var viewControllers = navigationController.viewControllers
                    // Ensure root view controller exists at index 0
                    let rootViewController = viewControllers[0]
                    
                    // Insert DrawsViewController after the root view controller if it's not already there
                    // Add myTicketsController (or myTicketsVC) after DrawsViewController
                    let myTicketsController = drawsViewController.myTicketsController
                    myTicketsController.segmentedControl.segmentTapped(myTicketsController.segmentedControl.buttonsCollection[1])
                    if !viewControllers.contains(myTicketsController) {
                        viewControllers.insert(myTicketsController, at: 1)
                    }
                    
                    navigationController.setViewControllers(viewControllers, animated: false)
                    navigationController.popToViewController(myTicketsController, animated: true)
                } else {
                    // Show a specific alert in case of failure to save
                    let alertController = UIAlertController(title: "Save Error", message: "Failed to save the ticket. Please try again.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alertController.addAction(okAction)
                    self?.present(alertController, animated: true, completion: nil)
                }
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
    
    private func calculateLabelHeight(for text: String, with font: UIFont, width: CGFloat) -> CGSize {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)
        return boundingBox.size
    }
    
    @objc private func lotteryImageTapped() {
        guard let image = lotteryImageView.image else { return }
        
        let dimmedBackgroundView = UIView(frame: view.bounds)
        dimmedBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        dimmedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        dimmedBackgroundView.alpha = 0
        
        let enlargedImageView = UIImageView(image: image)
        enlargedImageView.contentMode = .scaleAspectFit
        enlargedImageView.translatesAutoresizingMaskIntoConstraints = false
        enlargedImageView.isUserInteractionEnabled = true
        enlargedImageView.layer.cornerRadius = 15.scale
        enlargedImageView.layer.masksToBounds = true
        
        view.addSubview(dimmedBackgroundView)
        view.addSubview(enlargedImageView)
        
        NSLayoutConstraint.activate([
            dimmedBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            enlargedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enlargedImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            enlargedImageView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9),
            enlargedImageView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.6)
        ])
        
        UIView.animate(withDuration: 0.3) {
            dimmedBackgroundView.alpha = 1
        }
        
        let tapOutsideGesture = UITapGestureRecognizer(target: self, action: #selector(dismissEnlargedImageView(_:)))
        dimmedBackgroundView.addGestureRecognizer(tapOutsideGesture)
    }

    @objc private func dismissEnlargedImageView(_ sender: UITapGestureRecognizer) {
        if let dimmedBackgroundView = sender.view, let enlargedImageView = view.subviews.last(where: { $0 is UIImageView }) {
            UIView.animate(withDuration: 0.1, animations: {
                dimmedBackgroundView.alpha = 0
                enlargedImageView.alpha = 0
            }) { _ in
                dimmedBackgroundView.removeFromSuperview()
                enlargedImageView.removeFromSuperview()
            }
        }
    }
}
