//
//  EditTicketVIewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/12/24.
//

//
//  EditTicketViewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/12/24.
//

import UIKit

class EditTicketViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Properties to hold ticket data
    var ticket: Ticket?
    var collectionView: UICollectionView!
    
    // Save Ticket Button
    private let saveTicketButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save ticket", for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 14.scale)
        button.layer.cornerRadius = 20.scale // Half of the height for rounded corners
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTicketButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.main400
        // Set up navigation bar
        setupNavigationBar()
        setupNavigationBarTitle()
        
        // Set up the collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical // or .horizontal based on your design
        
        // Initialize the collection view
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = Appearance.main400
        // Register the custom cell class
        collectionView.register(TicketEditCell.self, forCellWithReuseIdentifier: "TicketEditCell")
        
        collectionView.contentInset = UIEdgeInsets(top: 40.scale, left: 0, bottom: 30.scale, right: 0)
        
        // Add collection view to the view hierarchy
        view.addSubview(collectionView)
        
        // Add Save Ticket Button to the view hierarchy
        view.addSubview(saveTicketButton)
        
        // Set constraints for the collection view
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: saveTicketButton.topAnchor, constant: -10.scale), // Make space for the button
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Set constraints for the Save Ticket Button
            saveTicketButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            saveTicketButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            saveTicketButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30.scale),
            saveTicketButton.heightAnchor.constraint(equalToConstant: 50.scale) // Adjust height as needed
        ])
    }
    
    // Action for Save Ticket Button
    @objc func saveTicketButtonTapped() {
        // Code to save the ticket
        // This can include any logic to save or submit the ticket data
        print("Save ticket button tapped")
    }
    
    // Setup navigation bar title with a custom back button
    private func setupNavigationBarTitle() {
        // Load the custom back button image
        guard let backButtonImage = UIImage(named: "EditBackButtonImage") else { return }
        
        // Create a UIButton with specific dimensions and set it as the custom view
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.backgroundColor = .clear
        backButton.frame = CGRect(x: 0, y: 0, width: 140, height: 26)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)

        // Create a UIBarButtonItem using the custom UIButton
        let barButtonItem = UIBarButtonItem(customView: backButton)
        
        // Set the custom back button as the left bar button item
        self.navigationItem.leftBarButtonItem = barButtonItem
    }

    @objc func handleBackButton() {
        // Code to execute when the back button is tapped
        navigationController?.popViewController(animated: true)
    }

    // Setup the navigation bar's appearance
    private func setupNavigationBar() {
        // Ensure the navigation bar does not obscure the view
        navigationController?.navigationBar.isTranslucent = true
        
        // Set navigation bar background and shadow images to empty, making it transparent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // Optional: Set navigation bar elements to a specific color to ensure they are visible
        navigationController?.navigationBar.tintColor = Appearance.mono200
        
        // Setting the title with custom attributes if needed
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Appearance.mono200]
    }

    // UICollectionViewDataSource methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 // Only one cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TicketEditCell", for: indexPath) as! TicketEditCell
        if let ticket = self.ticket {
            cell.configure(ticket: ticket)
        }
        cell.layer.cornerRadius = 20.scale
        return cell
    }
    
    // UICollectionViewDelegateFlowLayout method
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate the cell size
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        return CGSize(width: 343.scale, height: 300.scale) // Full size of the collection view
    }
}
