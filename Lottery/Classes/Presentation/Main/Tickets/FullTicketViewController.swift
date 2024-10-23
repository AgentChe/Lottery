import UIKit

class FullTicketViewController: UIViewController {
    
    let customTransitionManager = FullTicketCustomTransitionManager()
    
    // Background view that will take up 90% of the main view's height
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 32.scale
        view.clipsToBounds = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make the main view clear
        view.backgroundColor = UIColor.clear
        
        // Setup the background view
        setupBackgroundView()
        
        // Setup custom transition manager
        transitioningDelegate = customTransitionManager
        modalPresentationStyle = .overFullScreen
        
        // Setup the swipe gesture
        customTransitionManager.setupGestureRecognizer(in: self)
        
        // Add a tap gesture recognizer to the main view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupBackgroundView() {
        // Add backgroundView to the main view
        view.addSubview(backgroundView)
        
        // Set up constraints for backgroundView
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),  // Adjust width as needed
            backgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8) // 90% of main view's height
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Optional: You can add dimming or other effects here
        // view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    @objc private func handleViewTap() {
        // Dismiss the view controller when the view is tapped
        dismiss(animated: true, completion: nil)
    }
}
