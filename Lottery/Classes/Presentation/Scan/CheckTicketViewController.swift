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


class CheckTicketViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var ticket: Ticket?
    var numbersStringArray: [[String]] = [] {
        didSet {
            updateSaveButtonState()
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    var transcript = ""
    
    var collectionView: UICollectionView!
    
    var textRecognitionRequest = VNRecognizeTextRequest()
    var resultsViewController: (UIViewController & RecognizedTextDataSource)?
    
    private let saveTicketButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save ticket", for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.layer.cornerRadius = 25.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTicketButtonTapped), for: .touchUpInside)
        button.isEnabled = false // Initially disabled
        return button
    }()
    
    private let rescanButton: UIButton = {
        let button = UIButton()
        button.setTitle("Rescan", for: .normal)
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
        imageView.contentMode = .scaleAspectFit
        // Set your image here
        imageView.backgroundColor = .red
        imageView.image = UIImage(named: "YourImageName")
        return imageView
    }()
    
    // Bottom constraint for the save button
    private var saveButtonBottomConstraint: NSLayoutConstraint!

    // Custom initializer
    
    init(ticket: Ticket) {
        super.init(nibName: nil, bundle: nil)
        self.ticket = ticket
        self.numbersStringArray = ticket.numbers.map { $0.map { "\($0)" } }
        
        textRecognitionRequest = VNRecognizeTextRequest { request, error in
            guard let resultsViewController = self.resultsViewController else {
                print("resultsViewController is not set")
                return
            }
            
            if let requestResults = request.results as? [VNRecognizedTextObservation], !requestResults.isEmpty {
                DispatchQueue.main.async {
                    resultsViewController.addRecognizedText(recognizedText: requestResults)
                }
            }
        }
        
        // This doesn't require OCR on a live camera feed, select accurate for more accurate results.
        textRecognitionRequest.recognitionLevel = .accurate
        
        if #available(iOS 16.0, *) {
            textRecognitionRequest.revision = VNRecognizeTextRequestRevision3
        }
        
        textRecognitionRequest.usesLanguageCorrection = true
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
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = Appearance.main400
        collectionView.register(TicketEditCell.self, forCellWithReuseIdentifier: "TicketEditCell")
        
        collectionView.contentInset = UIEdgeInsets(top: 40.scale, left: 0, bottom: 30.scale, right: 0)
        
        view.addSubview(imageView)
        view.addSubview(collectionView)
        view.addSubview(saveTicketButton)
        view.addSubview(rescanButton)
        
        setupConstraints()
        updateSaveButtonState() // Initial check to set the button state based on initial data
        
        // Add keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
         
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.scale),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 375.scale),
            imageView.heightAnchor.constraint(equalToConstant: 320.scale),
            
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
        
        // Get the necessary properties from the ticket to use in the editTicket method
        let id = existingTicket.id
        let lotteryId = existingTicket.lotteryId
        let pictureUrl = existingTicket.pictureUrl
        let date = existingTicket.date
        
        // Create an instance of TicketsManager (assuming you have a shared instance or create a new one)
        let ticketsManager = TicketsManager()
        
        // Call the editTicket method
        ticketsManager.editTicket(id: id, lotteryId: lotteryId, pictureUrl: pictureUrl, date: date, numbers: numbersArray) { result in
            switch result {
            case .success(let updatedTicket):
                // Handle success (e.g., show a success message or pop the view controller)
                print("Ticket updated successfully: \(updatedTicket)")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
                
            case .failure(let error):
                // Handle failure by presenting an alert to the user
                print("Failed to update the ticket: \(error)")
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Update Failed",
                        message: "Unable to update the ticket. Please try again later. Error: \(error.localizedDescription)",
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
    
    @objc func rescanButtonTapped() {
        // Handle the rescan button tap
        print("Rescan button tapped")
        // Add your rescan logic here
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
            cell.configure(ticket: ticket)
        }
        cell.delegate = self
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
            let cellSpacing: CGFloat = 12.scale * CGFloat(numberOfCells )
            
            // Calculate the width for each cell
            let availableWidth = totalWidth - sideMargins - cellSpacing
            let cellWidth = availableWidth / CGFloat(numberOfCells)
            
            return CGSize(width: 343.scale,
                          height: CGFloat(numbersStringArray.count) * (cellWidth + 10).scale + 41.scale + 15.scale + 50.scale + 30.scale )
        } else {
            return CGSize(width: 343.scale,
                          height: CGFloat(numbersStringArray.count) * (40 + 10).scale + 41.scale + 15.scale + 50.scale + 30.scale )
        }
    }

    // Validation method to check if all numbers are valid
    private func areAllNumbersValid() -> Bool {
        for section in numbersStringArray {
            for number in section {
                if Int(number) == nil {
                    return false
                }
            }
        }
        return true
    }

    // Method to update save button state based on validation
    private func updateSaveButtonState() {
        let allNumbersValid = areAllNumbersValid()
        saveTicketButton.isEnabled = allNumbersValid
        saveTicketButton.backgroundColor = allNumbersValid ? Appearance.main100 : .gray // Change the color to gray if not valid
    }
    
    // Handle keyboard appearance
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            let accessoryViewHeight: CGFloat = saveTicketButton.inputAccessoryView?.frame.height ?? 0
            let totalHeight = keyboardHeight
            
            saveButtonBottomConstraint.constant = -totalHeight
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

extension CheckTicketViewController: EditTicketViewControllerDelegate {
    func updateSizeOfEditCell(numbersStringArray: [[String]]) {
        self.numbersStringArray = numbersStringArray
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension CheckTicketViewController: RecognizedTextDataSource {
    func processImage(image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Failed to get cgimage from input image")
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([textRecognitionRequest])
        } catch {
            print(error)
        }
    }
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
        // Create a full transcript to run analysis on.
        let maximumCandidates = 1
        for observation in recognizedText {
                    guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                    
                    // Filter to include only numbers
                    let numbersOnly = candidate.string.filter { "0123456789".contains($0) }
                    
                    if !numbersOnly.isEmpty {
                        // Add recognized numbers to the transcript
                        transcript += numbersOnly  // Add a new line for each recognized line
                    }
                }
        print("Text recoginzed is:", transcript)
        if let ticket = ticket {
            fullfillNumbersStringArray(transcript: transcript, ticket: ticket)
        }
    }
}

extension CheckTicketViewController {
    func fullfillNumbersStringArray(transcript: String, ticket: Ticket ) -> [[Int]] {
        if ticket.id != 3 && ticket.id != 6 {
            let numbersArray = convertStringToIntArray(transcript)
            if isDivisible(numbersArray.count, by: 12) {
                let numberOfRows = numbersArray.count/12
                let twoDigitsArray = convertToTwoDigitArray(numbersArray)
                print("Text recoginzed is: \(twoDigitsArray)")
                
                print("Text recoginzed is: ",reshapeArray6Case(twoDigitsArray, numberOfRows: numberOfRows))
            } else {
                presentRecognitionErrorAlert(on: self)
            }
            
        }
        return [[]]
    }
    func convertStringToIntArray(_ str: String) -> [Int] {
        return str.compactMap { $0.wholeNumberValue }
    }
    func isDivisible(_ dividend: Int, by divisor: Int) -> Bool {
        return dividend % divisor == 0
    }
    func presentRecognitionErrorAlert(on viewController: UIViewController) {
        // Create the alert controller
        let alert = UIAlertController(
            title: "Recognition Error",
            message: "An error occurred during the recognition process. Please try again.",
            preferredStyle: .alert
        )
        
        // Add an action to the alert
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { _ in
            // Code to retry the recognition process
            print("User tapped Try Again")
        }
        
        // Add the action to the alert controller
        alert.addAction(tryAgainAction)
        
        // Present the alert on the provided view controller
        viewController.present(alert, animated: true, completion: nil)
    }
    func convertToTwoDigitArray(_ inputArray: [Int]) -> [String] {
        var resultArray: [String] = []
        
        // Check if the array has an even number of elements
        if inputArray.count % 2 != 0 {
            print("The input array does not have an even number of elements.")
            return resultArray
        }
        
        for i in stride(from: 0, to: inputArray.count, by: 2) {
            // Combine each pair of elements into a two-digit string
            let combinedNumber = String(format: "%d%d", inputArray[i], inputArray[i+1])
            resultArray.append(combinedNumber)
        }
        
        return resultArray
    }
    func reshapeArray6Case(_ input: [String], numberOfRows: Int) -> [[Int]]? {
        // Convert strings to integers
        let integers = input.compactMap { Int($0) }
        
        // Calculate expected number of elements based on provided number of rows and fixed 6 columns
        let expectedNumberOfElements = numberOfRows * 6
        
        // Ensure the input array has the exact number of required elements
        if integers.count != expectedNumberOfElements {
            print("Input array does not contain the correct number of elements.")
            return nil
        }
        
        // Create an array to hold the reshaped data
        var output = [[Int]]()
        
        for i in 0..<numberOfRows {
            var row = [Int]()
            for k in 0..<6 {
                row.append(k) // Example value, you can replace it with any value you want
            }
            output.append(row)
        }
        
        for j in 0..<numberOfRows {
            for k in 0..<6 {
                //print(k*numberOfRows + j)
                output[j][k] = integers[k*numberOfRows + j]
                //print(integers[k*numberOfRows + j], j,k,numberOfRows)
            }
        }
        
        return output
    }
}
