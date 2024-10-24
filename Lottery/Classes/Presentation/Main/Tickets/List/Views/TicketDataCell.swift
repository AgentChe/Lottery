import UIKit
import Kingfisher // Assuming you're using Kingfisher for image loading

class TicketDataCell: UICollectionViewCell {
    
    static let identifier = "TicketDataCell"
    var ticket: Ticket! {
        didSet {
            configure()
        }
    }
    
    var pastDraws: [Game] = [] {
        didSet {
            // Configure the view when data is updated
            configure()
        }
    }
    var lotteries: [Lottery] = []
    var lotteryPatterns: [LotteryPattern] = []
    
    // Property to track if this ticket is a winning ticket
    var isTheWinner: Bool = false {
        didSet {
            updateCollectionViewHeights()
        }
    }
    
    // Ticket image view
    private let ticketImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "") // Placeholder image
        return imageView
    }()
    
    // Date label
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium) // Replace with your custom font if needed
        label.textColor = .lightGray // Replace with your custom color if needed
        return label
    }()
    
    // Winning numbers collection view
    private var winningNumbers: [Int] = []
    
    private lazy var winningNumberCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10.scale
        layout.minimumLineSpacing = 10.scale
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    // Ticket numbers collection view (newly added)
    private var ticketNumbers: [Int] = []
    
    private lazy var ticketNumbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10.scale
        layout.minimumLineSpacing = 10.scale
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    // Height constraints for collection views
    private var winningNumbersCollectionViewHeightConstraint: NSLayoutConstraint!
    private var ticketNumbersCollectionViewHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        winningNumberCollectionView.register(WinningNumbersHeaderView.self,
                                             forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                             withReuseIdentifier: WinningNumbersHeaderView.identifier)
        
        ticketNumbersCollectionView.register(TicketHeaderView.self,
                                             forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                             withReuseIdentifier: TicketHeaderView.identifier)
        winningNumberCollectionView.register(WinningNumberCell.self, forCellWithReuseIdentifier: WinningNumberCell.identifier)
        ticketNumbersCollectionView.register(TicketNumberCell.self, forCellWithReuseIdentifier: TicketNumberCell.identifier)
        
        setupViews()
        backgroundColor = .yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(ticketImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(winningNumberCollectionView)
        contentView.addSubview(ticketNumbersCollectionView)
        
      
          
        
        // Set constraints for ticketImageView
        NSLayoutConstraint.activate([
            ticketImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26.scale),
            ticketImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.scale),
            ticketImageView.widthAnchor.constraint(equalToConstant: 150.scale),
            ticketImageView.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
        
        // Set constraints for dateLabel
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: ticketImageView.bottomAnchor, constant: 10.scale),
            dateLabel.leadingAnchor.constraint(equalTo: ticketImageView.leadingAnchor, constant: 13.scale),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.scale),
            dateLabel.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
        
        // Set constraints for winningNumberCollectionView
        winningNumbersCollectionViewHeightConstraint = winningNumberCollectionView.heightAnchor.constraint(equalToConstant: 250.scale)
        NSLayoutConstraint.activate([
            winningNumberCollectionView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10.scale),
            winningNumberCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.scale),
            winningNumberCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.scale),
            winningNumbersCollectionViewHeightConstraint
        ])
        
        // Set constraints for ticketNumbersCollectionView (newly added collection view)
        ticketNumbersCollectionViewHeightConstraint = ticketNumbersCollectionView.heightAnchor.constraint(equalToConstant: 250.scale)
        NSLayoutConstraint.activate([
            ticketNumbersCollectionView.topAnchor.constraint(equalTo: winningNumberCollectionView.bottomAnchor, constant: 10.scale),
            ticketNumbersCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.scale),
            ticketNumbersCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.scale),
            ticketNumbersCollectionViewHeightConstraint,
         //   ticketNumbersCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.scale)
        ])
    }
    
    // Configure the cell with data
    private func configure() {
        guard let ticket = ticket else { return }
        
        // Format date
        let ticketDate = Date(timeIntervalSince1970: ticket.date) // Assuming ticket.date is TimeInterval
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        dateLabel.text = formatter.string(from: ticketDate).uppercased()
        
        // Update collection views with numbers
        winningNumberCollectionView.reloadData()
        ticketNumbersCollectionView.reloadData()
        
        // Load ticket image asynchronously
        if let lotteryLogoUrlString = lotteries.filter({ $0.id == ticket.lotteryId }).first?.logoUrl {
            self.ticketImageView.kf.setImage(with: lotteryLogoUrlString)
        } else {
            ticketImageView.image = nil
        }
        
        updateCollectionViewHeights() // Adjust heights based on `isTheWinner`
    }
    
    // Update the height of the collection views based on whether it's a winning ticket
    private func updateCollectionViewHeights() {
        winningNumbersCollectionViewHeightConstraint.constant = isTheWinner ? 250.scale : 0
        ticketNumbersCollectionViewHeightConstraint.constant = 250.scale
        layoutIfNeeded() // Apply the changes to the layout
    }
    
    
}

extension TicketDataCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // Provide the header view for the collection view
      func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
          if kind == UICollectionView.elementKindSectionHeader {
              if collectionView == winningNumberCollectionView {
                  let headerView = collectionView.dequeueReusableSupplementaryView(
                      ofKind: kind,
                      withReuseIdentifier: WinningNumbersHeaderView.identifier,
                      for: indexPath) as! WinningNumbersHeaderView
                  return headerView
              } else if collectionView == ticketNumbersCollectionView {
                  let headerView = collectionView.dequeueReusableSupplementaryView(
                      ofKind: kind,
                      withReuseIdentifier: TicketHeaderView.identifier,
                      for: indexPath) as! TicketHeaderView
                  return headerView
              }
          }
          return UICollectionReusableView()
      }
      
      // Define the size for the header view
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
          return CGSize(width: collectionView.frame.width, height: 50)
      }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == winningNumberCollectionView {
//            return winningNumbers.count // Number of winning numbers
//        } else if collectionView == ticketNumbersCollectionView {
//            return ticketNumbers.count // Number of ticket numbers
//        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == winningNumberCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WinningNumberCell.identifier, for: indexPath) as! WinningNumberCell
       //     let winningNumber = winningNumbers[indexPath.item]
            cell.configure(with: 1)
            return cell
        } else if collectionView == ticketNumbersCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TicketNumberCell.identifier, for: indexPath) as! TicketNumberCell
         //   let ticketNumber = ticketNumbers[indexPath.item]
            cell.configure(with: 1)
            return cell
        }
        return UICollectionViewCell()
    }
    
    // Define the size for the cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: 50) // Adjust the size as needed
    }
}
