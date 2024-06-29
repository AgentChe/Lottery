//
//  EditScanViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/12/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//


import AVFoundation
import UIKit

/// The `EditScanViewController` offers an interface for the user to edit the detected quadrilateral.
final class EditScanViewController: UIViewController, UIGestureRecognizerDelegate {
    var keepButton: UIButton!
    var retakeButton: UIButton!
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
        imageView.image = image
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var quadView: QuadrilateralView = {
        let quadView = QuadrilateralView()
        quadView.editable = true
        quadView.translatesAutoresizingMaskIntoConstraints = false
        return quadView
    }()

    private lazy var nextButton: UIBarButtonItem = {
        let title = NSLocalizedString("wescan.edit.button.next",
                                      tableName: nil,
                                      bundle: Bundle(for: EditScanViewController.self),
                                      value: "Next",
                                      comment: "A generic next button"
        )
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(pushReviewController))
        button.tintColor = navigationController?.navigationBar.tintColor
        return button
    }()

    private lazy var cancelButton: UIBarButtonItem = {
        let title = NSLocalizedString("wescan.scanning.cancel",
                                      tableName: nil,
                                      bundle: Bundle(for: EditScanViewController.self),
                                      value: "Cancel",
                                      comment: "A generic cancel button"
        )
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(cancelButtonTapped))
        button.tintColor = navigationController?.navigationBar.tintColor
        return button
    }()
    private lazy var cornerImageView: UIImageView = {
         let imageView = UIImageView()
         imageView.frame = CGRect(x: 16.scale, y: 140.scale, width: 343.scale, height: 477.scale)
         imageView.image = UIImage(named: "Scan.DragTheCorners")
         imageView.contentMode = .scaleAspectFill
         imageView.backgroundColor = .clear
         imageView.layer.cornerRadius = 20.scale
         imageView.translatesAutoresizingMaskIntoConstraints = false
         return imageView
     }()
     
    private lazy var maskView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 20.scale
        view.layer.masksToBounds = true
        view.frame = CGRect(x: 20.scale, y: 150.scale, width: 330.5.scale, height: 506.scale)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    /// The image the quadrilateral was detected on.
    private let image: UIImage

    /// The detected quadrilateral that can be edited by the user. Uses the image's coordinates.
    private var quad: Quadrilateral

    private var zoomGestureController: ZoomGestureController!

    private var quadViewWidthConstraint = NSLayoutConstraint()
    private var quadViewHeightConstraint = NSLayoutConstraint()

    // MARK: - Life Cycle

    init(image: UIImage, quad: Quadrilateral?, rotateImage: Bool = true) {
        self.image = rotateImage ? image.applyingPortraitOrientation() : image
        self.quad = quad ?? EditScanViewController.defaultQuad(forImage: image)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        title = NSLocalizedString("wescan.edit.title",
                                  tableName: nil,
                                  bundle: Bundle(for: EditScanViewController.self),
                                  value: "Edit Scan",
                                  comment: "The title of the EditScanViewController"
        )
        navigationItem.rightBarButtonItem = nextButton
        if let firstVC = self.navigationController?.viewControllers.first, firstVC == self {
            navigationItem.leftBarButtonItem = cancelButton
        } else {
            navigationItem.leftBarButtonItem = nil
        }

        zoomGestureController = ZoomGestureController(image: image, quadView: quadView)

        let touchDown = UILongPressGestureRecognizer(target: zoomGestureController, action: #selector(zoomGestureController.handle(pan:)))
        touchDown.minimumPressDuration = 0
        touchDown.delegate = self  // Set the delegate to self
        view.addGestureRecognizer(touchDown)
        
        setupNavigationBackButton()
        setupButtons()
        setupConstraints()
        
    }

    private func setupButtons() {
        // Keep button
        keepButton = UIButton(type: .system)
        keepButton.setTitle("Continue", for: .normal)
        keepButton.backgroundColor = Appearance.main100 // Using your custom color
        keepButton.setTitleColor(Appearance.mono100, for: .normal)
        keepButton.titleLabel?.font = Fonts.Inter.bold(size: 17.scale) // Using your custom font with scale
        keepButton.layer.cornerRadius = 21.scale // Adjust radius to match the one in your image with scale
        keepButton.clipsToBounds = true
        keepButton.translatesAutoresizingMaskIntoConstraints = false
        keepButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        view.addSubview(keepButton)
        
        // Retake button
        retakeButton = UIButton(type: .system)
        retakeButton.setTitle("Retake photo", for: .normal)
        retakeButton.backgroundColor = Appearance.mono100 // Clear background
        retakeButton.setTitleColor(Appearance.mono200, for: .normal)
        retakeButton.titleLabel?.font = Fonts.Inter.bold(size: 17.scale) // Using your custom font with scale
        retakeButton.layer.cornerRadius = 21.scale // No rounded corners
        retakeButton.clipsToBounds = true
        retakeButton.translatesAutoresizingMaskIntoConstraints = false
        retakeButton.addTarget(self, action: #selector(retakeButtonTapped), for: .touchUpInside)
        view.addSubview(retakeButton)
    }

    @objc func retakeButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func continueButtonTapped() {
        guard let quad = quadView.quad,
              let ciImage = CIImage(image: image) else {
            if let imageScannerController = navigationController as? ImageScannerController {
                let error = ImageScannerControllerError.ciImageCreation
                imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFailWithError: error)
            }
            return
        }
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        let scaledQuad = quad.scale(quadView.bounds.size, image.size)
        self.quad = scaledQuad
        
        // Cropped Image
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()
        
        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])
        
        var finalImage: UIImage? = UIImage.from(ciImage: filteredImage)
        //
        //          switch filterType {
        //          case .none:
        //              break
        //          case .grayscale:
        //              finalImage = filteredImage.applyingGrayscaleFilter()
        //          case .adaptiveThreshold:
        //              finalImage = filteredImage.applyingAdaptiveThreshold()
        //          }
        
        let enhancedScan = finalImage.flatMap { ImageScannerScan(image: $0) }
        
        let results = ImageScannerResults(
            detectedRectangle: scaledQuad,
            originalScan: ImageScannerScan(image: image),
            croppedScan: ImageScannerScan(image: finalImage ?? UIImage()),
            enhancedScan: enhancedScan
        )
        ImageManager.shared.addImageScans(results)
        
        let ticket = Ticket(id: 1, lotteryId: 1, pictureUrl: URL(string: "http://example.com/pic.png"), date: 1627490000.0, numbers: [[1, 2, 3, 4 ],[6, 7, 8, 9]])
        
        let checkTicketViewController = CheckTicketViewController(ticket: ticket)
        
        checkTicketViewController.imageView.image = results.croppedScan.image
        navigationController?.pushViewController( checkTicketViewController, animated: true)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustQuadViewConstraints()
        displayQuad()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Work around for an iOS 11.2 bug where UIBarButtonItems don't get back to their normal state after being pressed.
        navigationController?.navigationBar.tintAdjustmentMode = .normal
        navigationController?.navigationBar.tintAdjustmentMode = .automatic
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

    // MARK: - Setups

    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(quadView)
        view.addSubview(cornerImageView)
        view.addSubview(maskView)
        view.backgroundColor = Appearance.mono200
        
        imageView.mask = maskView
        
        
        
     }

    private func setupConstraints() {
        // Constraints for cornerImageView
        NSLayoutConstraint.activate([
            cornerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.scale),
            cornerImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 142.scale),
            cornerImageView.widthAnchor.constraint(equalToConstant: 339.scale),
            cornerImageView.heightAnchor.constraint(equalToConstant: 477.scale)
        ])
        
        // Constraints for maskView
        NSLayoutConstraint.activate([
            maskView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.scale),
            maskView.topAnchor.constraint(equalTo: view.topAnchor, constant: 129.scale),
            maskView.widthAnchor.constraint(equalToConstant: 300.scale),
            maskView.heightAnchor.constraint(equalToConstant: 400.scale)
        ])
        
        // Constraints for keepButton
        NSLayoutConstraint.activate([
            keepButton.bottomAnchor.constraint(equalTo: retakeButton.topAnchor, constant: ScreenSize.isIphoneXFamily ? -10.scale : -5.scale), // Distance between buttons.
            keepButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ScreenSize.isIphoneXFamily ? 20.scale : 40.scale),
            keepButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: ScreenSize.isIphoneXFamily ? -20.scale : -40.scale),
            keepButton.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 44.scale : 50.scale)
        ])
        
        // Constraints for retakeButton
        NSLayoutConstraint.activate([
            retakeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -40.scale : -10.scale), // Lifted up by 10 pts
            retakeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ScreenSize.isIphoneXFamily ? 20.scale : 40.scale),
            retakeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: ScreenSize.isIphoneXFamily ? -20.scale : -40.scale),
            retakeButton.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 44.scale : 30.scale)
        ])
        
        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: -25.scale),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25.scale),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ]

        quadViewWidthConstraint = quadView.widthAnchor.constraint(equalToConstant: 0.0)
        quadViewHeightConstraint = quadView.heightAnchor.constraint(equalToConstant: 0.0)

        let quadViewConstraints = [
            quadView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            quadView.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -25.scale),
            quadViewWidthConstraint,
            quadViewHeightConstraint
        ]

        NSLayoutConstraint.activate(quadViewConstraints + imageViewConstraints)
    }

    // MARK: - Actions
    @objc func cancelButtonTapped() {
        if let imageScannerController = navigationController as? ImageScannerController {
            imageScannerController.imageScannerDelegate?.imageScannerControllerDidCancel(imageScannerController)
        }
    }

    @objc func pushReviewController() {
        guard let quad = quadView.quad,
            let ciImage = CIImage(image: image) else {
                if let imageScannerController = navigationController as? ImageScannerController {
                    let error = ImageScannerControllerError.ciImageCreation
                    imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFailWithError: error)
                }
                return
        }
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        let scaledQuad = quad.scale(quadView.bounds.size, image.size)
        self.quad = scaledQuad

        // Cropped Image
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()

        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])

        let croppedImage = UIImage.from(ciImage: filteredImage)
        // Enhanced Image
        let enhancedImage = filteredImage.applyingAdaptiveThreshold()?.withFixedOrientation()
        let enhancedScan = enhancedImage.flatMap { ImageScannerScan(image: $0) }

        let results = ImageScannerResults(
            detectedRectangle: scaledQuad,
            originalScan: ImageScannerScan(image: image),
            croppedScan: ImageScannerScan(image: croppedImage),
            enhancedScan: enhancedScan
        )

        let reviewViewController = ReviewViewController(results: results)
        navigationController?.pushViewController(reviewViewController, animated: true)
    }

    private func displayQuad() {
        let imageSize = image.size
        let imageFrame = CGRect(
            origin: quadView.frame.origin,
            size: CGSize(width: quadViewWidthConstraint.constant, height: quadViewHeightConstraint.constant)
        )

        let scaleTransform = CGAffineTransform.scaleTransform(forSize: imageSize, aspectFillInSize: imageFrame.size)
        let transforms = [scaleTransform]
        let transformedQuad = quad.applyTransforms(transforms)

        quadView.drawQuadrilateral(quad: transformedQuad, animated: false)
    }

    /// The quadView should be lined up on top of the actual image displayed by the imageView.
    /// Since there is no way to know the size of that image before run time, we adjust the constraints
    /// to make sure that the quadView is on top of the displayed image.
    private func adjustQuadViewConstraints() {
        let frame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        quadViewWidthConstraint.constant = frame.size.width
        quadViewHeightConstraint.constant = frame.size.height
    }

    /// Generates a `Quadrilateral` object that's centered and 90% of the size of the passed in image.
    private static func defaultQuad(forImage image: UIImage) -> Quadrilateral {
        let topLeft = CGPoint(x: image.size.width * 0.05, y: image.size.height * 0.05)
        let topRight = CGPoint(x: image.size.width * 0.95, y: image.size.height * 0.05)
        let bottomRight = CGPoint(x: image.size.width * 0.95, y: image.size.height * 0.95)
        let bottomLeft = CGPoint(x: image.size.width * 0.05, y: image.size.height * 0.95)

        let quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        return quad
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Check if the touch is within the keepButton's bounds
        if touch.view == keepButton || touch.view == retakeButton {
            return false
        }
        return true
    }
}
