//
//  EditTicketVIewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/12/24.
//

//
//  EditTicketVIewController.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/12/24.
//

import UIKit

class EditTicketViewController: UIViewController {
    
    // Properties to hold ticket data
    var ticket: Ticket?
    
    // UI Elements
    private let ticketImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let dateTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "MM/DD/YYYY"
        textField.font = Fonts.Inter.medium(size: 16.scale)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let numbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12.scale
        layout.minimumInteritemSpacing = 12.scale
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save ticket", for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 22.scale
        button.titleLabel?.font = Fonts.Inter.bold(size: 16.scale)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var numbers: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.main400
        setupUI()
        setupConstraints()
        setupNavigationBarTitle() // Set the custom title
        loadTicketData()
        setupNavigationBar()
        setupNavigationBarTitle()
    }
    private func setupNavigationBarTitle() {
        // Load the custom back button image
        guard let backButtonImage = UIImage(named: "EditBackButtonImage") else { return }
        // Create a UIButton with specific dimensions and set it as the custom view
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit 
        backButton.backgroundColor = .clear
        backButton.frame = CGRect(x: 0, y: 0, width: 140.scale, height: 26.scale)
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
    private func setupUI() {
        view.addSubview(ticketImageView)
        view.addSubview(dateTextField)
        view.addSubview(numbersCollectionView)
        view.addSubview(addButton)
        view.addSubview(saveButton)
        
        numbersCollectionView.dataSource = self
        numbersCollectionView.delegate = self
        numbersCollectionView.register(NumberTicketCell.self, forCellWithReuseIdentifier: NumberTicketCell.reuseIdentifier)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            ticketImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20.scale),
            ticketImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            ticketImageView.widthAnchor.constraint(equalToConstant: 200.scale),
            ticketImageView.heightAnchor.constraint(equalToConstant: 50.scale),
            
            dateTextField.centerYAnchor.constraint(equalTo: ticketImageView.centerYAnchor),
            dateTextField.leadingAnchor.constraint(equalTo: ticketImageView.trailingAnchor, constant: 20.scale),
            dateTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            dateTextField.heightAnchor.constraint(equalToConstant: 40.scale),
            
            numbersCollectionView.topAnchor.constraint(equalTo: ticketImageView.bottomAnchor, constant: 20.scale),
            numbersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            numbersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            numbersCollectionView.heightAnchor.constraint(equalToConstant: 50.scale),
            
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: numbersCollectionView.bottomAnchor, constant: 20.scale),
            addButton.widthAnchor.constraint(equalToConstant: 40.scale),
            addButton.heightAnchor.constraint(equalToConstant: 40.scale),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20.scale),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            saveButton.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
    }
    
    private func loadTicketData() {
        guard let ticket = ticket else { return }
        // Load the ticket data into the UI elements
        if let url = ticket.pictureUrl {
            loadImage(from: url)
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let ticketDate = Date(timeIntervalSince1970: ticket.date)
        dateTextField.text = formatter.string(from: ticketDate)
        numbers = ticket.numbers.flatMap { $0 }
        numbersCollectionView.reloadData()
    }
    
    private func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.ticketImageView.image = image
                }
            }
        }
    }
    
    
    @objc private func handleMenuTap() {
        // Handle the tap on the menu button here
        print("Menu button tapped")
    }
}

extension EditTicketViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumberTicketCell.reuseIdentifier, for: indexPath) as! NumberTicketCell
        // cell.configure(with: numbers[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40.scale, height: 40.scale)
    }
}
