//
//  ScanMenuViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/24/24.
//

import UIKit
import AVFoundation

final class ScanMenuViewController: UIViewController {
    var stateId: Int!
    var lotteryId: Int!
    var lotteries: [Lottery]!
    private var contentManager: ContentManagerProtocol = ContentManager()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // UIImageView for displaying an image
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Scan.ScanMenuViewController") // Replace with your image name
        return imageView
    }()
    
    // First UIButton
    private let scanTicketButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("ScanMenuViewController.ScanTicketButton".localized, for: .normal)
        button.titleLabel?.font = Fonts.Inter.semiBold(size: 16.scale)
        button.backgroundColor = Appearance.main100
        button.tintColor = Appearance.mono100
        button.layer.cornerRadius = 21.scale
        button.addTarget(self, action: #selector(scanTicketButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Second UIButton
    private let addTicketButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("ScanMenuViewController.AddTicketManuallyButton".localized, for: .normal)
        button.titleLabel?.font = Fonts.Inter.semiBold(size: 16.scale)
        button.titleLabel?.textColor = Appearance.mono200
        button.backgroundColor = Appearance.mono100
        button.tintColor = Appearance.mono200
        button.layer.cornerRadius = 21.scale
        button.addTarget(self, action: #selector(addTicketManuallyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.mono200
        
        // Adding subviews
        view.addSubview(imageView)
        view.addSubview(scanTicketButton)
        view.addSubview(addTicketButton)
        
        // Applying constraints
        setupConstraints()
        
        setupNavigationBackButton()
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
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.hidesBackButton = true // Hide the default back button
    }
    @objc private func customBackButtonTapped() {
        // Perform back navigation
        navigationController?.popViewController(animated: true)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Constraints for imageView
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30.scale),
            imageView.widthAnchor.constraint(equalToConstant: 343.scale),
            imageView.heightAnchor.constraint(equalToConstant: 510.scale), // Adjust as needed for aspect ratio
            
            // Constraints for firstButton
            scanTicketButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanTicketButton.bottomAnchor.constraint(equalTo: addTicketButton.topAnchor, constant: -15.scale),
            scanTicketButton.widthAnchor.constraint(equalToConstant: 343.scale),
            scanTicketButton.heightAnchor.constraint(equalToConstant: 44.scale),
            
            // Constraints for secondButton
            addTicketButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addTicketButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50.scale),
            addTicketButton.widthAnchor.constraint(equalToConstant: 343.scale),
            addTicketButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
    }
    
    // Actions for the buttons
    @objc private func scanTicketButtonTapped() {
        requestCameraPermission()
    }
    
    @objc private func addTicketManuallyButtonTapped() {
        print("Second button tapped")
        contentManager.fetchLotteries(forceUpdate: false, stateId: nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lotteries):
                    self?.lotteries = lotteries
                    for lottery in lotteries {
                        if lottery.id == self?.lotteryId {
                            let pictureUrl = lottery.logoUrl
                            
                            let ticket: Ticket = Ticket(
                                id: 0,
                                lotteryId: lottery.id,
                                pictureUrl: pictureUrl,
                                date: Date().timeIntervalSince1970,
                                numbers: []
                            )
                            
                            let addScanTicketVC = AddScanTicketViewController(ticket: ticket, lotteries: lotteries)
                            self?.navigationController?.pushViewController(addScanTicketVC, animated: true)
                        }
                    }
                case .failure(let error):
                    print("Failed to fetch lotteries: \(error)")
                }
            }
        }
    }
   
    func requestCameraPermission() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if granted {
                        print("Camera access granted.")
                        let scanViewController = ScanViewController()
                        scanViewController.stateId = self.stateId
                        scanViewController.lotteryId = self.lotteryId
                        if let navigationController = self.navigationController {
                            navigationController.pushViewController(scanViewController, animated: true)
                        } else {
                            self.present(scanViewController, animated: true, completion: nil)
                        }
                    } else {
                        print("Camera access denied.")
                    }
                }
            }
        case .restricted, .denied:
            self.showCameraAccessDeniedAlert()
        case .authorized:
            DispatchQueue.main.async {
                let scanViewController = ScanViewController()
                scanViewController.stateId = self.stateId
                scanViewController.lotteryId = self.lotteryId
                if let navigationController = self.navigationController {
                    navigationController.pushViewController(scanViewController, animated: true)
                } else {
                    self.present(scanViewController, animated: true, completion: nil)
                }
            }
        @unknown default:
            fatalError("Unknown camera authorization status.")
        }
    }
    
    func showCameraAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "ScanMenuViewController.CameraAccessNeededTitle".localized,
            message: "ScanMenuViewController.CameraAccessNeededMessage".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ScanMenuViewController.OpenSettingsButton".localized, style: .default, handler: { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "ScanMenuViewController.CancelButton".localized, style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
