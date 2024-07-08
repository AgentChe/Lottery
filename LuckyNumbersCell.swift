//
//  LuckyNumbersCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 7/3/24.
//

import UIKit
import Kingfisher

class LuckyNumbersCell: UICollectionViewCell {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("Touch!")
    }
    var game: Game!
    var lotteries: [Lottery]!
    weak var delegate: LuckyNumbersViewController?
    private let logoImageView = UIImageView()
    private let dateLabelContainer = UIView()
    private let dateLabel = UILabel()
    var logoImageLeadingConstraint: NSLayoutConstraint!
    var logoImageWidthConstraint: NSLayoutConstraint!

    let dashedLineImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PastDraws.DashedLine")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var myLuckyNumbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 6.scale
        layout.minimumLineSpacing = 6.scale
        layout.itemSize = CGSize(width: 40.scale, height: 40.scale)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isUserInteractionEnabled = false
        collectionView.register(NumberCell.self, forCellWithReuseIdentifier: "NumberCell")
        return collectionView
    }()
    
    let editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "LuckyNumbers.Edit"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 40.scale).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40.scale).isActive = true
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let removeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "LuckyNumbers.Remove"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 40.scale).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40.scale).isActive = true
        button.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Arrays to hold the nested numbers
    private var myLuckyNumbers: [[Int]] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 16.scale
        setupUI()
        setupLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func editButtonTapped() {
        print("LuckyNumbersCell.EditButton".localized)
        
        for lottery in lotteries {
            if lottery.id == game.lotteryId {
                
                let ticket: Ticket = Ticket(id: 0,
                                            lotteryId: game.lotteryId,
                                            pictureUrl: lottery.logoUrl,
                                            date: game.date,
                                            numbers: game.myLuckyNumbers ?? [])
                
                let editLuckyNumbersVC = EditLuckyNumbersViewController(ticket: ticket, game: game, lotteries: lotteries)
                delegate?.navigationController?.pushViewController(editLuckyNumbersVC, animated: true)
            }
        }
    }
    
    @objc private func removeButtonTapped() {
        let alertVC = LuckyNumbersAlertViewController()
        
        alertVC.onConfirmDelete = { [weak self] in
            guard let self = self else { return }
            let lotteryId = self.game.lotteryId
            let date = self.game.date
            
            let gamesManager = GamesManager()
            gamesManager.addLuckyNumbers(lotteryId: lotteryId, date: date, numbers: []) { [weak self] result in
                switch result {
                case .success(let success):
                    if success {
                        // Handle success case
                        print("LuckyNumbersCell.RemoveButton".localized)
                        DispatchQueue.main.async {
                            self?.delegate?.fetchLotteries(for: nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.showErrorAlert(message: "LuckyNumbersCell.ErrorMessage".localized)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showErrorAlert(message: "LuckyNumbersCell.ErrorMessage".localized)
                    }
                }
            }
        }
        
        alertVC.onCancel = {
            // Code to handle cancellation (if any)
        }
        
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        
        if let parentVC = self.parentViewController {
            parentVC.present(alertVC, animated: false, completion: nil)
        }
    }
    
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "LuckyNumbersCell.ErrorTitle".localized, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: nil)
        alertController.addAction(okAction)
        delegate?.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Public Methods
extension LuckyNumbersCell {
    func configure(game: Game, lotteries: [Lottery]) {
        self.game = game
        self.lotteries = lotteries
        logoImageView.image = UIImage(named: "placeholderImage")
        logoImageView.contentMode = .scaleAspectFit
        for lottery in lotteries {
            if lottery.id == game.lotteryId {
                logoImageView.kf.setImage(with: lottery.logoUrl)
                if doesURLContain(lottery.logoUrl.absoluteString, word: "mega") || doesURLContain(lottery.logoUrl.absoluteString, word: "2by2") {
                    logoImageLeadingConstraint.isActive = false
                    logoImageWidthConstraint.isActive = false
                    logoImageLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -15.scale)
                    logoImageWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 188.scale)
                    logoImageLeadingConstraint.isActive = true
                    logoImageWidthConstraint.isActive = true
                    setNeedsLayout()
                }
                if doesURLContain(lottery.logoUrl.absoluteString, word: "power") || doesURLContain(lottery.logoUrl.absoluteString, word: "lotto") {
                    logoImageLeadingConstraint.isActive = false
                    logoImageWidthConstraint.isActive = false
                    logoImageLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale)
                    logoImageWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 160.scale)
                    logoImageLeadingConstraint.isActive = true
                    logoImageWidthConstraint.isActive = true
                    setNeedsLayout()
                }
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let formattedDate = dateFormatter.string(from: Date(timeIntervalSince1970: game.date))
        dateLabel.text = formattedDate.uppercased()
        
        // Assign data to arrays (use the full double array)
        myLuckyNumbers = game.myLuckyNumbers ?? []
        
        // Reload collection views with new data
        myLuckyNumbersCollectionView.reloadData()
    }
    
    private func formatToMillions(_ value: String) -> String {
        guard let number = Double(value.filter { "0123456789.".contains($0) }) else {
            return value
        }
        
        let million = number / 1_000_000
        return String(format: "$%.0f M.", million)
    }
    
    func doesURLContain(_ urlString: String, word: String) -> Bool {
        return urlString.lowercased().contains(word)
    }
}

// MARK: - Setup Methods
private extension LuckyNumbersCell {
    func setupUI() {
        backgroundColor = .white
        
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        dateLabelContainer.layer.shadowColor = Appearance.dropShadowColor?.cgColor
        dateLabelContainer.layer.shadowOpacity = 0.5
        dateLabelContainer.layer.shadowRadius = 3.scale
        dateLabelContainer.layer.shadowOffset = CGSize(width: 0, height: 2.scale)
        
        dateLabel.font = Fonts.Inter.medium(size: 12.5.scale)
        dateLabel.textAlignment = .center
        dateLabel.textColor = Appearance.main300
        dateLabel.backgroundColor = Appearance.mono100
        dateLabel.layer.cornerRadius = 17.scale
        dateLabel.layer.masksToBounds = true
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(logoImageView)
        addSubview(dateLabelContainer)
        dateLabelContainer.addSubview(dateLabel)
        addSubview(myLuckyNumbersCollectionView)
        addSubview(dashedLineImageView)
        addSubview(editButton)
        addSubview(removeButton)
    }
    
    func setupLayoutConstraints() {
        logoImageLeadingConstraint = logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -15.scale)
        logoImageWidthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 188.scale)
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: -29.scale),
            logoImageLeadingConstraint,
            logoImageWidthConstraint,
            logoImageView.heightAnchor.constraint(equalToConstant: 58.scale),
            
            dateLabelContainer.topAnchor.constraint(equalTo: topAnchor, constant: -16.scale),
            dateLabelContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30.scale),
            dateLabelContainer.widthAnchor.constraint(equalToConstant: 112.scale),
            dateLabelContainer.heightAnchor.constraint(equalToConstant: 32.scale),
            
            dateLabel.centerXAnchor.constraint(equalTo: dateLabelContainer.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: dateLabelContainer.centerYAnchor),
            dateLabel.widthAnchor.constraint(equalTo: dateLabelContainer.widthAnchor),
            dateLabel.heightAnchor.constraint(equalTo: dateLabelContainer.heightAnchor),
            
            // My Lucky Numbers CollectionView
            myLuckyNumbersCollectionView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 21.scale),
            myLuckyNumbersCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            myLuckyNumbersCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            myLuckyNumbersCollectionView.bottomAnchor.constraint(equalTo: dashedLineImageView.topAnchor, constant: -20.scale),
            
            // Dashed Line View
            dashedLineImageView.bottomAnchor.constraint(equalTo: editButton.topAnchor, constant: -25.scale),
            dashedLineImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.scale),
            dashedLineImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.scale),
            dashedLineImageView.heightAnchor.constraint(equalToConstant: 1.scale),
            
            // Edit Button
            editButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20.scale),
            editButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28.scale),
            
            // Remove Button
            removeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20.scale),
            removeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28.scale),
        ])
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension LuckyNumbersCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return myLuckyNumbers.count // Using the first set of numbers for simplicity
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myLuckyNumbers.first?.count ?? 0 // Using the first set of numbers for simplicity
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberCell", for: indexPath) as? NumberCell else {
            fatalError("Could not dequeue cell with identifier: NumberCell")
        }
        configureCellForLuckyNumbers(cell, at: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.scale,
                            left: myLuckyNumbers.first?.count == 6 ? 0.scale : 58.scale,
                            bottom: 14.scale,
                            right: myLuckyNumbers.first?.count == 6 ? 0.scale : -58.scale)
    }
    
    private func configureCellForLuckyNumbers(_ cell: NumberCell, at indexPath: IndexPath) {
        let number = myLuckyNumbers[indexPath.section][indexPath.item]
        configureCell(cell, withNumber: number, indexPath: indexPath)
    }
    
    private func configureCell(_ cell: NumberCell, withNumber number: Int, indexPath: IndexPath) {
        cell.configure(with: String(number))
        cell.layer.borderColor = Appearance.main500.cgColor
        if myLuckyNumbers.first?.count == 6 {
            let lastIndex = myLuckyNumbers[indexPath.section].count - 1
            if indexPath.item == lastIndex {
                cell.backgroundColor = Appearance.main100
                cell.setNumberLabelColor(Appearance.mono100)
            } else {
                cell.setNumberLabelColor(Appearance.mono200)
                cell.backgroundColor = Appearance.mono100
                cell.layer.borderColor = Appearance.main500.cgColor
            }
        }
        if myLuckyNumbers.first?.count == 4 {
            if indexPath.item == 0 || indexPath.item == 1 {
                cell.backgroundColor = Appearance.main100
                cell.setNumberLabelColor(Appearance.mono100)
            }
            if indexPath.item == 2 || indexPath.item == 3 {
                cell.backgroundColor = Appearance.mono100
                cell.setNumberLabelColor(Appearance.mono200)
                cell.layer.borderColor = Appearance.main500.cgColor
            }
        }
    }
}
