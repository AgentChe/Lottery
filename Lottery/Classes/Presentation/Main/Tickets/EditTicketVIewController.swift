//
//  EditTicketVIewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/12/24.
//

import UIKit

class EditTicketViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var lotteries: [Lottery] = []
    private var ticketsManager: TicketsManagerProtocol = TicketsManager()
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
        button.setTitle("EditTicketViewController.SaveTicket".localized, for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(Appearance.mono100, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTicketButtonTapped), for: .touchUpInside)
        button.isEnabled = false // Initially disabled
        return button
    }()
    
    private let deleteTicketButton: UIButton = {
        let button = UIButton()
        button.setTitle("EditTicketViewController.DeleteTicket".localized, for: .normal)
        button.backgroundColor = Appearance.mono100
        button.setTitleColor(Appearance.mono200, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.layer.cornerRadius = 20.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteTicketButtonTapped), for: .touchUpInside)
        button.isEnabled = true // Initially disabled
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
    
    // Bottom constraint for the save button
    private var saveButtonBottomConstraint: NSLayoutConstraint!
    private var deleteButtonBottomConstraint: NSLayoutConstraint!

    // Custom initializer
    init(ticket: Ticket) {
        super.init(nibName: nil, bundle: nil)
        self.ticket = ticket
        self.numbersStringArray = ticket.numbers.map { $0.map { "\($0)" } }
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
        
        view.addSubview(collectionView)
        view.addSubview(saveTicketButton)
        view.addSubview(deleteTicketButton)
        
        // Add activity indicator to save button
        saveTicketButton.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: saveTicketButton.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: saveTicketButton.centerYAnchor).isActive = true

        setupConstraints()
        updateSaveButtonState() // Initial check to set the button state based on initial data
        
        // Add keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: saveTicketButton.topAnchor, constant: -10.scale),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            saveTicketButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            saveTicketButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            saveTicketButton.heightAnchor.constraint(equalToConstant: 50.scale),
            
            deleteTicketButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            deleteTicketButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            deleteTicketButton.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
        
        // Initialize the bottom constraint
        saveButtonBottomConstraint = saveTicketButton.bottomAnchor.constraint(equalTo: deleteTicketButton.topAnchor , constant: -10.scale)
        saveButtonBottomConstraint.isActive = true
        deleteButtonBottomConstraint  = deleteTicketButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10.scale)
        deleteButtonBottomConstraint.isActive = true
    }

    @objc func deleteTicketButtonTapped() {
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
        ticketsManager.deleteTicket(id: id) { result in
            switch result {
            case .success:
                // Handle success (e.g., show a success message or pop the view controller)
                print("Ticket deleted successfully")
                DispatchQueue.main.async {
                    ticketsManager.listTickets(forceUpdate: true) {
                        [weak self] result in
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
                
            case .failure(let error):
                // Handle failure by presenting an alert to the user
                print("Failed to delete the ticket: \(error)")
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "EditTicketViewController.DeleteFailed.Title".localized,
                        message: String(format: "EditTicketViewController.DeleteFailed.Message".localized, error.localizedDescription),
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

    @objc func saveTicketButtonTapped() {
        // Hide the title and show the activity indicator
        saveTicketButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        saveTicketButton.isEnabled = false // Disable the button

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
            DispatchQueue.main.async {
                // Stop the activity indicator and show the title
                self.activityIndicator.stopAnimating()
                self.saveTicketButton.setTitle("EditTicketViewController.SaveTicket".localized, for: .normal)
                self.saveTicketButton.isEnabled = true // Re-enable the button
            }
            switch result {
            case .success(let updatedTicket):
                // Handle success (e.g., show a success message or pop the view controller)
                print("Ticket updated successfully: \(updatedTicket)")
                DispatchQueue.main.async {
                    ticketsManager.listTickets(forceUpdate: true) {
                        [weak self] result in
                            self?.navigationController?.popViewController(animated: true)
                    }
                }
                
            case .failure(let error):
                // Handle failure by presenting an alert to the user
                print("Failed to update the ticket: \(error)")
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "EditTicketViewController.UpdateFailed.Title".localized,
                        message: String(format: "EditTicketViewController.UpdateFailed.Message".localized, error.localizedDescription),
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
    
    private func setupNavigationBarTitle() {
        guard let backButtonImage = UIImage(named: "EditBackButtonImage") else { return }
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.backgroundColor = .clear
        backButton.frame = CGRect(x: 0, y: 0, width: 140.scale, height: 26.scale)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)

        let barButtonItem = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = barButtonItem
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setNeedsDisplay()
    }
    @objc func handleBackButton() {
        navigationController?.popViewController(animated: true)
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .red//Appearance.mono200
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Appearance.mono200]
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TicketEditCell", for: indexPath) as! TicketEditCell
        if let ticket = self.ticket {
            cell.lotteries = self.lotteries
            cell.configure(ticket: ticket)
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
                          height: CGFloat(numbersStringArray.count) * (cellWidth + 6).scale + 41.scale + 15.scale + 50.scale + 30.scale )
        } else {
            return CGSize(width: 343.scale,
                          height: CGFloat(numbersStringArray.count) * (40 + 6).scale + 41.scale + 15.scale + 50.scale + 30.scale )
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
            
            saveButtonBottomConstraint.constant = -totalHeight * 0.55
            UIView.animate(withDuration: 0.35) {
                self.view.layoutIfNeeded()
            }
        }
    }

    // Handle keyboard disappearance
    @objc private func keyboardWillHide(_ notification: Notification) {
        saveButtonBottomConstraint.constant = -10.scale
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension EditTicketViewController: EditTicketViewControllerDelegate {
    func updateSizeOfEditCell(numbersStringArray: [[String]]) {
        self.numbersStringArray = numbersStringArray
        collectionView.collectionViewLayout.invalidateLayout()
    }
}
