//
//  AddScanTicketViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 7/5/24.
//

import UIKit

class AddScanTicketViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var lottery: Lottery?
    var ticket: Ticket?
    var numbersStringArray: [[String]] = [] {
        didSet {
            updateSaveButtonState()
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    var collectionView: UICollectionView!
    
    private let saveTicketButton: UIButton = {
        let button = UIButton()
        button.setTitle("AddScanTicketViewController.SaveTicket".localized, for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTicketButtonTapped), for: .touchUpInside)
        button.isEnabled = false // Initially disabled
        return button
    }()
    
    // Bottom constraint for the save button
    private var saveButtonBottomConstraint: NSLayoutConstraint!
    
    // Custom
    
    var lotteries: [Lottery]!
    init(ticket: Ticket, lotteries: [Lottery]) {
        super.init(nibName: nil, bundle: nil)
        self.ticket = ticket
        self.lotteries = lotteries
        print(lottery)
        for lottery in lotteries {
            if lottery.id == ticket.lotteryId {
                self.lottery = lottery
                if !doesURLContain(lottery.logoUrl.absoluteString, word: "2by2") {
                    self.numbersStringArray = [["","","","","",""]]
                } else {
                    self.numbersStringArray = [["","","",""]]
                }
            }
        }
    }
    func doesURLContain(_ urlString: String, word: String) -> Bool {
        return urlString.lowercased().contains(word)
    }
    func convertIntArrayToStringArray(_ intArray: [[Int]]) -> [[String]] {
        return intArray.map { $0.map { String($0) } }
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
        collectionView.register(ScanAddTicketNumbersEditCell.self, forCellWithReuseIdentifier: "ScanAddTicketNumbersEditCell")
        
        collectionView.contentInset = UIEdgeInsets(top: 40.scale, left: 0, bottom: 30.scale, right: 0)
        
        view.addSubview(collectionView)
        view.addSubview(saveTicketButton)
        
        setupConstraints()
        updateSaveButtonState() // Initial check to set the button state based on initial data
        
        // Add keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        setupNavigationBackButton()
    }
    
    func setupNavigationBackButton() {
        // Create a custom back button
        let backButton = UIButton(type: .custom)
        
        // Set the custom image for the button
        if let image = UIImage(named: "AddScanTicketViewController.CustomBackButtonImage".localized) {
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
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: saveTicketButton.topAnchor, constant: -10.scale),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            saveTicketButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            saveTicketButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            saveTicketButton.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
        
        // Initialize the bottom constraint
        saveButtonBottomConstraint = saveTicketButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30.scale)
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
        if let lottery = lottery, let ticket = ticket {
            let lotteryId = lottery.id
            let date = ticket.date
            
            let ticketManager = TicketsManager()
            ticketManager.addTicket(lotteryId: lotteryId, pictureUrl: lottery.logoUrl, date: ticket.date, numbers: numbersArray) { result in
                switch result {
                case .success(let updatedTicket):
                    
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                        
//                        if let sceneDelegate = UIApplication.shared.connectedScenes
//                            .first?.delegate as? SceneDelegate {
//                            if let rootNavigController = sceneDelegate.getRootViewController() as? NavigationController{
//                                // Do something with the root view controller
//                                let rootViewControllers = rootNavigController.viewControllers
//                                
//                                if let mainViewController = rootViewControllers.first as? MainViewController {
//                                    
//                                    mainViewController.coordinator.change(tab: .myTickets)
//                                }
//                            }
//                        }
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
   
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "AddScanTicketViewController.Error".localized, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    private func setupNavigationBarTitle() {
        guard let backButtonImage = UIImage(named: "AddScanTicketViewController.NavigationTitle".localized) else { return }
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScanAddTicketNumbersEditCell", for: indexPath) as! ScanAddTicketNumbersEditCell
        if let ticket = self.ticket, let lottery = self.lottery {
            
            cell.configure(ticket: ticket, lottery: lottery, lotteries: lotteries, numbersStringArray: numbersStringArray)
            
        }
        cell.delegate = self
        cell.parentvc = self
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
                          height: CGFloat(numbersStringArray.count) * (cellWidth + 6).scale + 41.scale + 15.scale + 50.scale + 30.scale)
        } else {
            return CGSize(width: 343.scale,
                          height: CGFloat(numbersStringArray.count) * (40 + 10).scale + 41.scale + 61.scale + 50.scale + 30.scale)
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
    func updateSaveButtonState() {
        let allNumbersValid = areAllNumbersValid()
        
        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? ScanAddTicketNumbersEditCell {
            let isValid: Bool = allNumbersValid && cell.dateLabel.text != "MM/DD/YYY"
            saveTicketButton.isEnabled = isValid
            saveTicketButton.backgroundColor = isValid ? Appearance.main100 : .gray // Change the color to gray if not valid
        } else {
            saveTicketButton.isEnabled = false
            saveTicketButton.backgroundColor  = .gray
        }
    }
    
    // Handle keyboard appearance
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            let accessoryViewHeight: CGFloat = saveTicketButton.inputAccessoryView?.frame.height ?? 0
            let totalHeight = keyboardHeight
            
            saveButtonBottomConstraint.constant = -totalHeight * 0.95
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

extension AddScanTicketViewController: EditTicketViewControllerDelegate {
    func updateSizeOfEditCell(numbersStringArray: [[String]]) {
        self.numbersStringArray = numbersStringArray
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension AddScanTicketViewController {
    func removeTicketButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
