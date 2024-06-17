//
//  EditTicketVIewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/12/24.
//

import UIKit

class EditTicketViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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
        button.setTitle("Save ticket", for: .normal)
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
            saveTicketButton.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
        
        // Initialize the bottom constraint
        saveButtonBottomConstraint = saveTicketButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30.scale)
        saveButtonBottomConstraint.isActive = true
    }
    
    @objc func saveTicketButtonTapped() {
        print("Save ticket button tapped")
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
        return CGSize(width: 343.scale,
                      height: CGFloat(numbersStringArray.count) * (40 + 10).scale + 41.scale + 15.scale + 50.scale + 30.scale )
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

extension EditTicketViewController: EditTicketViewControllerDelegate {
    func updateSizeOfEditCell(numbersStringArray: [[String]]) {
        self.numbersStringArray = numbersStringArray
        collectionView.collectionViewLayout.invalidateLayout()
    }
}
