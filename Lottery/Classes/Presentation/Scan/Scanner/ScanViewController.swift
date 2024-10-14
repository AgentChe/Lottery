//
//  ScanViewController.swift
//  Printer
//
//  Created by Niiaz Khasanov on 5/3/24.
//

import UIKit
import AVFoundation


class ScanViewController: UIViewController, ImageScannerControllerDelegate {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
     
    var stateId: Int!
    var lotteryId: Int!
    override func loadView() {
        super.loadView()
        setupNavigationBackButton()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupNavigationBackButton()
        // Initialize the scanner
        let scanner = ImageScannerController(lotteryId: self.lotteryId, stateId: self.stateId)
        scanner.stateId = stateId
        scanner.lotteryId = lotteryId
        scanner.imageScannerDelegate = self
 
        // Add the scanner as a child view controller
        addChild(scanner)
        scanner.view.frame = view.bounds  // Adjust the frame as needed
        view.addSubview(scanner.view)
        scanner.didMove(toParent: self)
        //setupNavigationBackButton()
      
    }
    func setupNavigationBackButton() {
        // Create a custom back button
        let backButton = UIButton(type: .custom)
        
        // Set the custom image for the button
        if let image = UIImage(named: "Scan.ScanTheTicket") {
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
            backButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: -20.scale),
            backButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        // Set constraints for the container view
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: backButton.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: backButton.heightAnchor)
        ])
        
        // Create a UIBarButtonItem with the container view
        let backButtonItem = UIBarButtonItem(customView: containerView)
        
        // Replace the default back button with the custom button
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.hidesBackButton = true // Hide the default back button
    }

    @objc private func customBackButtonTapped() {
        // Perform back navigation
        navigationController?.popViewController(animated: true)
    }
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        // Handle error
        print(error)
    }

    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        // Handle cancellation
        scanner.willMove(toParent: nil)
        scanner.view.removeFromSuperview()
        scanner.removeFromParent()
    }

    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        // Use the scanned image
        scanner.willMove(toParent: nil)
        scanner.view.removeFromSuperview()
        scanner.removeFromParent()
    }
}
