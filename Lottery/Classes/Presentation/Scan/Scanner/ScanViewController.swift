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
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupNavigationBackButton()
        // Initialize the scanner
        let scanner = ImageScannerController()
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
        
        // Set the frame or size of the button as needed
        backButton.frame = CGRect(x: 0, y: 0, width: 50.scale, height: 45.scale)
        backButton.imageView?.contentMode = .scaleAspectFit
        
        // Add a target to handle back navigation
        backButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        
        // Create a UIBarButtonItem with the custom button
        let backButtonItem = UIBarButtonItem(customView: backButton)
        
        // Replace the default back button with the custom button
        parent?.navigationItem.leftBarButtonItem = backButtonItem
        parent?.navigationItem.hidesBackButton = true // Hide the default back button
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
