//
//  CheckTicketViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/25/24.
//

import UIKit
import VisionKit
import Vision

protocol RecognizedTextDataSource: AnyObject {
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation])
}

class CheckScanTicketViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var image: UIImage?
    var ticket: Ticket?
    var lotteryPatterns: [LotteryPattern] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var lotteries: [Lottery] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var contentManager: ContentManagerProtocol = ContentManager()
    var numbersStringArray: [[String]] = [] {
        didSet {
            if numbersStringArray.count == 0 {
                presentRecognitionErrorAlert(on: self)
            }
            updateSaveButtonState()
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    var transcript = ""

    var collectionView: UICollectionView!

    var textRecognitionRequest = VNRecognizeTextRequest()
    var resultsViewController: (UIViewController & RecognizedTextDataSource)?
    
    private let ticketsManager = TicketsManager()
    private let uploadImage = TicketUploadImage()
 
   
    let saveTicketButton: UIButton = {
        let button = UIButton()
        button.setTitle("CheckTicketViewController.SaveTicketButton".localized, for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.layer.cornerRadius = 25.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTicketButtonTapped), for: .touchUpInside)
        button.isEnabled = false // Initially disabled
        return button
    }()
    
    // Add an activity indicator
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
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

    // ImageView above the collectionView
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        // Set your image here
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
        imageView.image = UIImage(named: "YourImageName")
        return imageView
    }()

    // Bottom constraint for the save button
    private var saveButtonBottomConstraint: NSLayoutConstraint!
    var badRecognition: Bool = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if badRecognition {
            self.presentRecognitionErrorAlert(on: self)
        }
    }
    
    func fetchLotteriesPatterns(for stateId: Int? = nil) {
        contentManager.fetchLotteriesPattern(forceUpdate: false, stateId: nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let patterns):
                    self?.lotteryPatterns = patterns
                    // Reload any UI or update any data structures as necessary
                    self?.collectionView.reloadData()
                  //  print("Successfully fetched lottery patterns: \(patterns)")
                case .failure(let error):
                    print("Failed to fetch lottery patterns: \(error)")
                }
            }
        }
    }
    
    var uploadResponse: UploadResponse?
    // Custom initializer
    init(ticket: Ticket, uploadResponse: UploadResponse? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.ticket = ticket
        self.numbersStringArray = [[]]
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = Appearance.main400
        collectionView.register(TicketEditCell.self, forCellWithReuseIdentifier: "TicketEditCell")
        self.fetchLotteriesPatterns()
        self.contentManager.fetchLotteries(forceUpdate: false, stateId: nil)  { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lotteries):
                    self?.lotteries = lotteries
                    if uploadResponse == nil {
                        self?.badRecognition = true
                        if let self = self {
                            self.presentRecognitionErrorAlert(on: self)
                        }
                    } else {
                        print("we here!")
                        if let uploadResponse = uploadResponse {
                            self?.uploadResponse = uploadResponse
                            self?.ticket?.numbers = uploadResponse.numbers
                            self?.numbersStringArray = self?.convertToFormattedStringArray(intArray:  uploadResponse.numbers) ?? []
                            self?.collectionView.reloadData()
                        }
                        
                    }
                case .failure(let error):
                    print("Failed to fetch lotteries: \(error)")
                }
            }
        }
       
//        textRecognitionRequest = VNRecognizeTextRequest { request, error in
//            guard let resultsViewController = self.resultsViewController else {
//                print("resultsViewController is not set")
//                return
//            }
//
//            if let requestResults = request.results as? [VNRecognizedTextObservation], !requestResults.isEmpty {
//                DispatchQueue.main.async {
//                    resultsViewController.addRecognizedText(recognizedText: requestResults)
//                }
//            } else {
//               
//                self.badRecognition = true
//                self.presentRecognitionErrorAlert(on: self)
//            }
//        }

        // This doesn't require OCR on a live camera feed, select accurate for more accurate results.
//        textRecognitionRequest.recognitionLevel = .accurate
//
//        if #available(iOS 16.0, *) {
//            textRecognitionRequest.revision = VNRecognizeTextRequestRevision3
//        }
//
//        textRecognitionRequest.usesLanguageCorrection = true
        
        resultsViewController = self
    }

    // Required initializer for compatibility with storyboards
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.main400
        setupNavigationBar()
        setupNavigationBarTitle()
        
      

        collectionView.contentInset = UIEdgeInsets(top: 40.scale, left: 0, bottom: 30.scale, right: 0)

        view.addSubview(imageView)
        view.addSubview(collectionView)
        view.addSubview(saveTicketButton)
        view.addSubview(rescanButton)
        
        // Add activity indicator to save button
        saveTicketButton.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: saveTicketButton.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: saveTicketButton.centerYAnchor).isActive = true

        setupConstraints()
        updateSaveButtonState() // Initial check to set the button state based on initial data

        // Add keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if badRecognition {
            imageView.alpha = 0
            collectionView.alpha = 0
            saveTicketButton.alpha = 0
            rescanButton.alpha = 0
        }
         
        
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.scale),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 375.scale),
            imageView.heightAnchor.constraint(equalToConstant: 120.scale),

            collectionView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10.scale),
            collectionView.bottomAnchor.constraint(equalTo: saveTicketButton.topAnchor, constant: -10.scale),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            saveTicketButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            saveTicketButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            saveTicketButton.heightAnchor.constraint(equalToConstant: 50.scale),
            saveTicketButton.bottomAnchor.constraint(equalTo: rescanButton.topAnchor, constant: -10.scale),

            rescanButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            rescanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            rescanButton.heightAnchor.constraint(equalToConstant: 50.scale)
        ])

        // Initialize the bottom constraint
        saveButtonBottomConstraint = rescanButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30.scale)
        saveButtonBottomConstraint.isActive = true
    }

    @objc func saveTicketButtonTapped() {
        // Hide the title and show the activity indicator
        saveTicketButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()

        // Convert numbersStringArray to [[Int]]
        var numbersArray: [[Int]] = []
        for section in numbersStringArray {
            var intSection: [Int] = []
            for numberString in section {
                if let number = Int(numberString) {
                    intSection.append(number)
                }
            }
            numbersArray.append(intSection)
        }
        
        // Ensure we have a ticket to modify
        guard var existingTicket = ticket else { return }
        
        // Update the ticket's numbers
        existingTicket.numbers = numbersArray
        if  let ticket = ticket {
            let ticketsManager = TicketsManager()
            ticketsManager.addTicket(lotteryId: existingTicket.lotteryId, pictureUrl: nil, date: ticket.date, numbers: numbersArray) { result in
                DispatchQueue.main.async {
                    // Stop the activity indicator and show the title
                    self.activityIndicator.stopAnimating()
                    self.saveTicketButton.setTitle("AddScanTicketViewController.SaveTicket".localized, for: .normal)
                }
                switch result {
                case .success(let updatedTicket):
                    DispatchQueue.main.async {
                        ticketsManager.listTickets(forceUpdate: true) {
                            [weak self] result in
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
                            if !viewControllers.contains(myTicketsController) {
                                viewControllers.insert(myTicketsController, at: 1)
                            }
                            
                            navigationController.setViewControllers(viewControllers, animated: false)
                            navigationController.popToViewController(myTicketsController, animated: true)
                        }
                    }
                case .failure(let error):
                    // Handle failure by presenting an alert to the user
                    print("Failed to update the ticket: \(error)")
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(
                            title: "AddScanTicketViewController.UpdateFailed.Title".localized,
                            message: String(format: "AddScanTicketViewController.UpdateFailed.Message".localized, error.localizedDescription),
                            preferredStyle: .alert
                        )
                        
                        // Add an OK button to the alert
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        // Present the alert
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    @objc func rescanButtonTapped() {
        // Handle the rescan button tap
        print("Rescan button tapped")
        
        if let viewControllers = navigationController?.viewControllers {
            let targetIndex = viewControllers.count - 3
            if targetIndex >= 0 {
                let targetViewController = viewControllers[targetIndex]
                navigationController?.popToViewController(targetViewController, animated: true)
            }
        }
    }

    private func setupNavigationBarTitle() {
        guard let backButtonImage = UIImage(named: "EditBackButtonImage") else { return }

        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.backgroundColor = .clear
        backButton.frame = CGRect(x: 0, y: 0, width: 140, height: 26)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)

        let barButtonItem = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = barButtonItem
    }

    @objc func handleBackButton() {
        navigationController?.popViewController(animated: true)
        
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = Appearance.mono200
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Appearance.mono200]
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TicketEditCell", for: indexPath) as! TicketEditCell
        if let ticket = self.ticket {
            if let pattern : LotteryPattern = lotteryPatterns.filter {$0.id == ticket.lotteryId }.first {
                cell.bonusIdx = pattern.bonusIdx
            }
            cell.lotteries = self.lotteries
            cell.configure(ticket: ticket)
        }
        if let uploadResponse = uploadResponse {
            if let date_of_game = uploadResponse.date_of_game {
                let date = Date(timeIntervalSince1970: date_of_game)
                
                // Create a DateFormatter to format the date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent formatting
                
                // Convert the Date object to the desired string format
                let formattedDate = dateFormatter.string(from: date)
                cell.dateLabel.text = formattedDate.uppercased()
                self.ticket?.date = date.timeIntervalSince1970
                saveTicketButton.isEnabled = true
                saveTicketButton.backgroundColor = Appearance.main100 
            }
        }
        cell.checkScanDelegate = self
        cell.parentCheckScan = self
        cell.layer.cornerRadius = 20.scale
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height

        // Get the number of cells in the last row
        if let firstNumberArray = numbersStringArray.first {
            let numberOfCells = firstNumberArray.count + 1
            // Calculate the available width based on the given constraints
            let totalWidth: CGFloat = 343.scale
            let sideMargins: CGFloat = 40.scale
            let cellSpacing: CGFloat = 3.scale * CGFloat(numberOfCells)

            // Calculate the width for each cell
            let availableWidth = totalWidth - sideMargins - cellSpacing
            let cellWidth = availableWidth / CGFloat(numberOfCells)

            return CGSize(width: 343.scale,
                          height: CGFloat(numbersStringArray.count) * (40.scale + 16).scale + 41.scale + 15.scale + 50.scale + 30.scale + 85.scale )
        } else {
            return CGSize(width: 343.scale,
                          height: CGFloat(numbersStringArray.count) * (40 + 16).scale + 41.scale + 15.scale + 50.scale + 30.scale + 85.scale)
        }
    }

    // Validation method to check if all numbers are valid
    private func areAllNumbersValid() -> Bool {
    
        for section in numbersStringArray {
            if section.count > 0 {
                for i in 1..<section.count {
                    if Int(section[i]) == nil {
                        return false
                    }
                }
            }
        }
        return true
    }

    // Method to update save button state based on validation
    func updateSaveButtonState() {
        let allNumbersValid = areAllNumbersValid()
        saveTicketButton.isEnabled = allNumbersValid
        saveTicketButton.backgroundColor = allNumbersValid ? Appearance.main100 : .gray // Change the color to gray if not valid
    }

    // Handle keyboard appearance
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            let accessoryViewHeight: CGFloat = saveTicketButton.inputAccessoryView?.frame.height ?? 0
            let totalHeight = keyboardHeight + 10.scale

            saveButtonBottomConstraint.constant = -totalHeight*0.9
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    // Handle keyboard disappearance
    @objc private func keyboardWillHide(_ notification: Notification) {
        saveButtonBottomConstraint.constant = -30.scale
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
}

extension CheckScanTicketViewController {

    func addGaussianBlurEffect(to imageView: UIImageView, withOverlayImage overlayImageName: String, target: Any?, action: Selector?) {
        guard let image = imageView.image else { return }

        // Create a blurred version of the image
        let ciImage = CIImage(image: image)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(10.0, forKey: kCIInputRadiusKey) // Adjust the blur radius as needed

        guard let outputCIImage = filter?.outputImage else { return }
        let context = CIContext(options: nil)

        guard let cgImage = context.createCGImage(outputCIImage, from: ciImage!.extent) else { return }
        let blurredImage = UIImage(cgImage: cgImage)

        // Create and configure the blur effect image view
        let blurImageView = UIImageView(image: blurredImage)
        blurImageView.translatesAutoresizingMaskIntoConstraints = false
        blurImageView.contentMode = .scaleAspectFill
        blurImageView.layer.masksToBounds = true
        imageView.addSubview(blurImageView)

        // Create a darker overlay
        let darkOverlayView = UIView()
        darkOverlayView.translatesAutoresizingMaskIntoConstraints = false
        darkOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        imageView.addSubview(darkOverlayView)

        // Create and configure the overlay image view
        let overlayImageView = UIImageView()
        overlayImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayImageView.contentMode = .scaleAspectFit
        overlayImageView.image = UIImage(named: overlayImageName)
        imageView.addSubview(overlayImageView)

        // Add constraints for the blur effect image view to fill the entire image view
        NSLayoutConstraint.activate([
            blurImageView.topAnchor.constraint(equalTo: imageView.topAnchor),
            blurImageView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            blurImageView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            blurImageView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])

        // Add constraints for the dark overlay view to fill the entire image view
        NSLayoutConstraint.activate([
            darkOverlayView.topAnchor.constraint(equalTo: imageView.topAnchor),
            darkOverlayView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            darkOverlayView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            darkOverlayView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])

        // Add constraints to center the overlay image view in the image view and set its size
        NSLayoutConstraint.activate([
            overlayImageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            overlayImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            overlayImageView.widthAnchor.constraint(equalToConstant: 40.scale),
            overlayImageView.heightAnchor.constraint(equalToConstant: 40.scale)
        ])

        // Add tap gesture recognizer to the image view
        if let target = target, let action = action {
            let tapGestureRecognizer = UITapGestureRecognizer(target: target, action: action)
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @objc func imageViewTapped() {
        let imageVC = ImageViewController()
        imageVC.image = imageView.image
        imageVC.modalPresentationStyle = .overFullScreen
        present(imageVC, animated: false, completion: nil)
    }
}
