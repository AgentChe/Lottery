//
//  EditScanViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/12/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//


import AVFoundation
import UIKit

final class EditScanViewController: UIViewController, UIGestureRecognizerDelegate {
    var stateId: Int!
    var lotteryId: Int!
    var continueButton: UIButton!
    var retakeButton: UIButton!
    private var dimView: DimViewWithProgressBar?
    let scanScratchManager = ScanScratchManager()
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
    
    private lazy var nextButton:  UIBarButtonItem = {
        let title = "EditScanViewController.NextButton".localized
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(pushReviewController))
        button.tintColor = navigationController?.navigationBar.tintColor
        return button
    }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        let title = "EditScanViewController.CancelButton".localized
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
        view.frame = CGRect(x: 20.scale, y: ScreenSize.isIphoneXFamily ? 150.scale : 90.scale, width: 330.5.scale, height: 506.scale)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let image: UIImage
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
    var touchDown:UILongPressGestureRecognizer!
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        title = "EditScanViewController.Title".localized
        navigationItem.rightBarButtonItem = nextButton
        if let firstVC = self.navigationController?.viewControllers.first, firstVC == self {
            navigationItem.leftBarButtonItem = cancelButton
        } else {
            navigationItem.leftBarButtonItem = nil
        }
        
        zoomGestureController = ZoomGestureController(image: image, quadView: quadView)
        
        touchDown = UILongPressGestureRecognizer(target: zoomGestureController, action: #selector(zoomGestureController.handle(pan:)))
        touchDown.minimumPressDuration = 0
        touchDown.delegate = self
        view.addGestureRecognizer(touchDown)
        
        setupNavigationBackButton()
        setupButtons()
        setupConstraints()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showDimView()
        dimView?.alpha = 0
        weDo = true
    }
    private func setupButtons() {
        continueButton = UIButton(type: .system)
        continueButton.setTitle("EditScanViewController.ContinueButton".localized, for: .normal)
        continueButton.backgroundColor = Appearance.main100
        continueButton.setTitleColor(Appearance.mono100, for: .normal)
        continueButton.titleLabel?.font = Fonts.Inter.bold(size: 17.scale)
        continueButton.layer.cornerRadius =  ScreenSize.isIphoneXFamily ? 21.scale : 17.5.scale
        continueButton.clipsToBounds = true
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        view.addSubview(continueButton)
        
        retakeButton = UIButton(type: .system)
        retakeButton.setTitle("EditScanViewController.RetakeButton".localized, for: .normal)
        retakeButton.backgroundColor = Appearance.mono100
        retakeButton.setTitleColor(Appearance.mono200, for: .normal)
        retakeButton.titleLabel?.font = Fonts.Inter.bold(size: 17.scale)
        retakeButton.layer.cornerRadius = ScreenSize.isIphoneXFamily ? 21.scale : 17.5.scale
        retakeButton.clipsToBounds = true
        retakeButton.translatesAutoresizingMaskIntoConstraints = false
        retakeButton.addTarget(self, action: #selector(retakeButtonTapped), for: .touchUpInside)
        view.addSubview(retakeButton)
    }
    
    @objc func retakeButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    var weDo: Bool = true
    @objc func continueButtonTapped() {
        if let navigController = (parent?.parent as? MainViewController)?.children.first as? NavigationController {
            print("navigController: ",navigController.children)
            var drawsViewController: DrawsViewController!
            for child in navigController.children {
                if child.isKind(of: DrawsViewController.self) {
                    drawsViewController = child as! DrawsViewController
                    if drawsViewController.isDrawScan != nil {
                        drawsScanMagic()
                    }
                    if drawsViewController.isScratchScan != nil {
                        scratchOffsScanMagic()
                    }
                }
            }
        }
        
        if lotteryId == 999 && stateId == 999 {
            scratchOffsScanMagic()
        } else {
            drawsScanMagic()
        }
        
    }
    func scratchOffsScanMagic() {
        dimView?.alpha = 1
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
        
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()
        
        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])
        
        var finalImage: UIImage? = UIImage.from(ciImage: filteredImage)
        let finalImageGray = filteredImage.applyingGrayscaleFilter()
        
        let enhancedScan = finalImage.flatMap { ImageScannerScan(image: $0) }
        
        let results = ImageScannerResults(
            detectedRectangle: scaledQuad,
            originalScan: ImageScannerScan(image: image),
            croppedScan: ImageScannerScan(image: finalImage ?? UIImage()),
            enhancedScan: enhancedScan
        )
        
        let resultsGray = ImageScannerResults(
            detectedRectangle: scaledQuad,
            originalScan: ImageScannerScan(image: image),
            croppedScan: ImageScannerScan(image: finalImageGray ?? UIImage()),
            enhancedScan: enhancedScan
        )
        
        ImageManager.shared.addImageScans(results)
        
        let ticket = Ticket(id: Int(Date().timeIntervalSince1970), lotteryId: lotteryId, pictureUrl: URL(string: "http://example.com/pic.png"), date: Date().timeIntervalSince1970, numbers: [[ ]])
        
        let checkTicketViewController = CheckScanTicketViewController(ticket: ticket)
        
        checkTicketViewController.image = results.originalScan.image
        checkTicketViewController.imageView.image = results.croppedScan.image
        let croppedImageSize = results.croppedScan.image.size
        checkTicketViewController.imageView.contentMode = croppedImageSize.width / croppedImageSize.height < 3.125 ? .scaleAspectFill : .scaleAspectFit
        if croppedImageSize.width / croppedImageSize.height < 3 {
            checkTicketViewController.addGaussianBlurEffect(
                to: checkTicketViewController.imageView,
                withOverlayImage: "Scan.Search",
                target: checkTicketViewController,
                action: #selector(CheckScanTicketViewController.imageViewTapped))
        }
        
        // checkTicketViewController.processImage(image: resultsGray.croppedScan.image)
        
        
        touchDown.isEnabled = false
        self.continueButton.isUserInteractionEnabled = false
        
        scanScratchManager.analyze(image: results.croppedScan.image) { scratchoff in
            if let response = scratchoff {
                DispatchQueue.main.async {
                    if self.weDo {
                        // Pass the ScratchOff data to the new view controller
                        let checkScratchoffViewController = CheckScratchOffTicketViewController(scratchOff: response)
                        self.navigationController?.pushViewController(checkScratchoffViewController, animated: true)
                        self.hideDimView()
                        self.touchDown.isEnabled = true
                        self.continueButton.isUserInteractionEnabled = true
                    } else {
                        self.weDo = true
                    
                        self.hideDimView()
                        self.showDimView()
                        self.dimView?.alpha = 0
                        self.continueButton.isUserInteractionEnabled = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.weDo = true
                    self.dimView?.progressLabel.text = "Scan unsuccesfull. Try again."
                    self.dimView?.setNeedsDisplay()
                    self.dimView?.setNeedsLayout()
                    self.dimView?.layoutIfNeeded()
                    delay(1) {
                        self.hideDimView()
                        self.showDimView()
                        self.dimView?.alpha = 0
                        
                        self.continueButton.isUserInteractionEnabled = true
                    }
                }
            }
        }

    }
    func drawsScanMagic() {
        dimView?.alpha = 1
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
        
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()
        
        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])
        
        var finalImage: UIImage? = UIImage.from(ciImage: filteredImage)
        let finalImageGray = filteredImage.applyingGrayscaleFilter()
        
        let enhancedScan = finalImage.flatMap { ImageScannerScan(image: $0) }
        
        let results = ImageScannerResults(
            detectedRectangle: scaledQuad,
            originalScan: ImageScannerScan(image: image),
            croppedScan: ImageScannerScan(image: finalImage ?? UIImage()),
            enhancedScan: enhancedScan
        )
        
        let resultsGray = ImageScannerResults(
            detectedRectangle: scaledQuad,
            originalScan: ImageScannerScan(image: image),
            croppedScan: ImageScannerScan(image: finalImageGray ?? UIImage()),
            enhancedScan: enhancedScan
        )
        
        ImageManager.shared.addImageScans(results)
        
        let ticket = Ticket(id: Int(Date().timeIntervalSince1970), lotteryId: lotteryId, pictureUrl: URL(string: "http://example.com/pic.png"), date: Date().timeIntervalSince1970, numbers: [[ ]])
        
        let checkTicketViewController = CheckScanTicketViewController(ticket: ticket)
        
        checkTicketViewController.image = results.originalScan.image
        checkTicketViewController.imageView.image = results.croppedScan.image
        let croppedImageSize = results.croppedScan.image.size
        checkTicketViewController.imageView.contentMode = croppedImageSize.width / croppedImageSize.height < 3.125 ? .scaleAspectFill : .scaleAspectFit
        if croppedImageSize.width / croppedImageSize.height < 3 {
            checkTicketViewController.addGaussianBlurEffect(to: checkTicketViewController.imageView, withOverlayImage: "Scan.Search", target: checkTicketViewController, action: #selector(CheckScanTicketViewController.imageViewTapped))
        }
        
        checkTicketViewController.processImage(image: resultsGray.croppedScan.image)
        touchDown.isEnabled = false
        
        delay(0.8) {
            DispatchQueue.main.async {
                self.continueButton.isUserInteractionEnabled = false
                if self.weDo {
                    self.navigationController?.pushViewController(checkTicketViewController, animated: true)
                    self.hideDimView()
                    self.touchDown.isEnabled = true
                    self.continueButton.isUserInteractionEnabled = true
                } else {
                    self.weDo = true
                    self.showDimView()
                    self.dimView?.alpha = 0
                    self.continueButton.isUserInteractionEnabled = true
                    
                }
            }
        }
    }
    func showDimView() {
        dimView = DimViewWithProgressBar(frame: view.bounds)
        if let dimView = dimView {
            dimView.isUserInteractionEnabled = true
            view.addSubview(dimView)
        }
    }
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustQuadViewConstraints()
        displayQuad()
    }
    func hideDimView() {
        dimView?.stopLoading()
        dimView = nil
    }
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintAdjustmentMode = .normal
        navigationController?.navigationBar.tintAdjustmentMode = .automatic
    }
    
    func setupNavigationBackButton() {
        let backButton = UIButton(type: .custom)
        if let image = UIImage(named: "Scan.ScanTheTicket") {
            backButton.setImage(image, for: .normal)
        }
        backButton.frame = CGRect(x: 0, y: 0, width: 50.scale, height: 45.scale)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.hidesBackButton = true
    }
    
    @objc private func customBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(quadView)
        view.addSubview(cornerImageView)
        view.addSubview(maskView)
        view.backgroundColor = Appearance.mono200
        imageView.mask = maskView
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cornerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.scale),
            cornerImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: ScreenSize.isIphoneXFamily ? 142.scale : 77.scale),
            cornerImageView.widthAnchor.constraint(equalToConstant: 339.scale),
            cornerImageView.heightAnchor.constraint(equalToConstant: 477.scale),
            maskView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.scale),
            maskView.topAnchor.constraint(equalTo: view.topAnchor, constant: ScreenSize.isIphoneXFamily ? 129.scale : 129.scale.scale),
            maskView.widthAnchor.constraint(equalToConstant: 300.scale),
            maskView.heightAnchor.constraint(equalToConstant: 400.scale),
            continueButton.bottomAnchor.constraint(equalTo: retakeButton.topAnchor, constant: ScreenSize.isIphoneXFamily ? -10.scale : -5.scale),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ScreenSize.isIphoneXFamily ? 20.scale : 40.scale),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: ScreenSize.isIphoneXFamily ? -20.scale : -40.scale),
            continueButton.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 44.scale : 35.scale),
            retakeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -40.scale : -15.scale),
            retakeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ScreenSize.isIphoneXFamily ? 20.scale : 40.scale),
            retakeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: ScreenSize.isIphoneXFamily ? -20.scale : -40.scale),
            retakeButton.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 44.scale : 35.scale),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: ScreenSize.isIphoneXFamily ? -25.scale : -22.scale),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -25.scale : -22.scale),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        quadViewWidthConstraint = quadView.widthAnchor.constraint(equalToConstant: 0.0)
        quadViewHeightConstraint = quadView.heightAnchor.constraint(equalToConstant: 0.0)
        
        NSLayoutConstraint.activate([
            quadView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            quadView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: ScreenSize.isIphoneXFamily ? -25.scale : -22.scale ),
            quadViewWidthConstraint,
            quadViewHeightConstraint
        ])
    }
    
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
        
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()
        
        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])
        
        let croppedImage = UIImage.from(ciImage: filteredImage)
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
    
    private func adjustQuadViewConstraints() {
        let frame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        quadViewWidthConstraint.constant = frame.size.width
        quadViewHeightConstraint.constant = frame.size.height
    }
    
    private static func defaultQuad(forImage image: UIImage) -> Quadrilateral {
        let topLeft = CGPoint(x: image.size.width * 0.05, y: image.size.height * 0.05)
        let topRight = CGPoint(x: image.size.width * 0.95, y: image.size.height * 0.05)
        let bottomRight = CGPoint(x: image.size.width * 0.95, y: image.size.height * 0.95)
        let bottomLeft = CGPoint(x: image.size.width * 0.05, y: image.size.height * 0.95)
        return Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view != continueButton && touch.view != retakeButton
    }
}
