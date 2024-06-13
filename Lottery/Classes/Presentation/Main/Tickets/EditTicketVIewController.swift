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
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "EDIT TICKET"
        label.font = Fonts.Inter.bold(size: 20.scale)
        label.textColor = Appearance.mono200
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        loadTicketData()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
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
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20.scale),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.scale),
            
            ticketImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.scale),
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
