//
//  LuckyNumbersRowCollecitonViewCell.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 9/23/24.
//

import UIKit

class LuckyNumbersRowCollecitonViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    static let reuseIdentifier = "LuckyNumbersRowCollecitonViewCell"
    
    var numbers: [Int] = []

    lazy var myLuckyNumbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 20.scale
        layout.itemSize = CGSize(width: 40.scale, height: 40.scale) // Adjust item size to match NumberCell
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(NumberCell.self, forCellWithReuseIdentifier: "NumberCell")
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        // Listen for scroll sync notifications
        NotificationCenter.default.addObserver(self, selector: #selector(synchronizeScroll(notification:)), name: .syncScroll, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollectionView() {
        contentView.addSubview(myLuckyNumbersCollectionView)

        NSLayoutConstraint.activate([
            myLuckyNumbersCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            myLuckyNumbersCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            myLuckyNumbersCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            myLuckyNumbersCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberCell", for: indexPath) as! NumberCell
        if numbers.count > indexPath.item {
            let number = numbers[indexPath.item]
            cell.configure(with: "\(number)")
        }
        return cell
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: .syncScroll, object: nil, userInfo: ["offset": scrollView.contentOffset])
    }

    // MARK: - Synchronize Scroll
    @objc private func synchronizeScroll(notification: Notification) {
        guard let userInfo = notification.userInfo, let offset = userInfo["offset"] as? CGPoint else { return }
        myLuckyNumbersCollectionView.contentOffset = offset
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.scale,
                            left: 0.scale,
                            bottom: 0.scale,
                            right:  0.scale)
    }
    
}

extension Notification.Name {
    static let syncScroll = Notification.Name("syncScroll")
}
