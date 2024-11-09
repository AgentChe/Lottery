import UIKit

class FullTicketViewController: UIViewController, UICollectionViewDelegateFlowLayout,TicketDataCellDelegate {
    
    private let gamesManager: GamesManagerProtocol = GamesManager()
    private let ticketsManager: TicketsManagerProtocol = TicketsManager()
    var lotteries: [Lottery] = []
    var bonusIdx: [Int] = []
    var lotteryPatterns: [LotteryPattern] = []
    var ticket: Ticket!
    private var pastDraws: [Game] = [] {
        didSet {
            self.ticketDataCollectionView.reloadData()
        }
    }
    
    var isTheWinner: Bool = false {
        didSet {
           // updateWinnerAndEditButtonVisibility()
            ticketDataCollectionView.reloadData()
        }
    }
    
    var previousContentOffsetY: CGFloat = 0.0
    
    // Background view that will take up 90% of the main view's height
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 32.scale
        view.clipsToBounds = true
        return view
    }()
    
    // Collection view to display ticket data
    let ticketDataCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear//.red
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    func didTapEditButton(for ticket: Ticket) {
        let editVC = EditTicketViewController(ticket: ticket)
        editVC.lotteries = self.lotteries
        editVC.lotteryPatterns = self.lotteryPatterns
        self.navigationController?.pushViewController(editVC, animated: true)
    }

 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTickets()
    }
    func fetchTickets() {
        ticketsManager.listTickets(forceUpdate: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tickets):
                    for ticket in tickets {
                        if ticket.id == self?.ticket.id {
                            self?.ticket = ticket
                            // Update isTheWinner based on ticket.status
                            self?.isTheWinner = ticket.status == "Winner"
                            self?.ticketDataCollectionView.reloadData()
                            return
                        }
                    }
                    // Ticket not found, dismiss
                    NotificationCenter.default.post(name: .ticketDeleted, object: nil)
                    delay(0.8) { [weak self] in
                        self?.dismiss(animated: true, completion: nil)
                    }
                case .failure:
                    print("failure")
                }
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make navigation bar transparent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
    
        // Make the main view clear
        view.backgroundColor = UIColor.clear
        
        // Setup the background view
        setupBackgroundView()
        
        // Remove the custom transition setup code
        // transitioningDelegate = customTransitionManager
        // modalPresentationStyle = .overFullScreen
        // customTransitionManager.setupGestureRecognizer(in: self)
        
        // Add a tap gesture recognizer to the main view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap))
        view.addGestureRecognizer(tapGesture)
        
        // Setup the ticketDataCollectionView
        setupCollectionView()
        
        // Setup the winnerImageView and editButton
        
        
        // Fetch past games
        fetchPastGames(for: nil)
        
      //  updateWinnerAndEditButtonVisibility()
    }
    
  
    
    private func setupBackgroundView() {
        // Add backgroundView to the main view
        view.addSubview(backgroundView)
        
        // Set up constraints for backgroundView
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            backgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8)
        ])
    }
    
    private func setupCollectionView() {
        // Add collection view to the background view
        backgroundView.addSubview(ticketDataCollectionView)
        
        // Set the delegate and dataSource
        ticketDataCollectionView.delegate = self
        ticketDataCollectionView.dataSource = self
        ticketDataCollectionView.isScrollEnabled = true
        if #available(iOS 17.4, *) {
            ticketDataCollectionView.bouncesVertically = false
        } else {
            // Fallback on earlier versions
        }
        // Register the cell class
        ticketDataCollectionView.register(TicketDataCell.self, forCellWithReuseIdentifier: TicketDataCell.identifier)
        
        // Set up constraints for ticketDataCollectionView
        NSLayoutConstraint.activate([
            ticketDataCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1),
            ticketDataCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ticketDataCollectionView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            ticketDataCollectionView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
        ])
    }
    
    @objc private func handleViewTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: view)
        
        // Check if tap is below 20% of view's height
        if tapLocation.y < view.frame.height * 0.2 {
            // Dismiss the view controller when the tap is outside the top 20%
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension FullTicketViewController: UICollectionViewDataSource, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TicketDataCell", for: indexPath) as! TicketDataCell
        cell.ticket = ticket
        cell.isTheWinner = self.isTheWinner // Pass the updated isTheWinner value
        cell.bonusIdx = bonusIdx
        cell.lotteries = lotteries
        cell.delegate = self
        cell.lotteryPatterns = lotteryPatterns
        if !pastDraws.isEmpty {
            cell.pastDraws = pastDraws
        }
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension FullTicketViewController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: view.frame.height * 0.2, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var winningHeight: CGFloat = 0
        if !pastDraws.isEmpty {
            winningHeight = CGFloat(pastDraws.first!.winningNumbers?.count ?? 0) * (40.scale + 10.scale + 4.scale) + 50.scale + 3
        }
        let ticketHeight = CGFloat(ticket.numbers.count) * (40.scale + 10.scale + 4.scale) + 15.scale + 3
        return CGSize(width: collectionView.frame.width, height: 120.scale + winningHeight + 10.scale + ticketHeight)
    }
}

extension FullTicketViewController {
    func isSameDay(timeInterval1: TimeInterval, timeInterval2: TimeInterval) -> Bool {
        let calendar = Calendar.current
        let date1 = Date(timeIntervalSince1970: timeInterval1)
        let date2 = Date(timeIntervalSince1970: timeInterval2)
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    func fetchPastGames(for stateId: Int?) {
        gamesManager.fetchPastGames(stateId: nil, forceUpdate: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let games):
                    self?.pastDraws = []
                    for game in games {
                        if game.lotteryId == self?.ticket.lotteryId {
                            if let self = self {
                               // print("date: \(self.formatTimeIntervalAsDate(game.date))")
                                if self.isSameDay(timeInterval1: game.date,
                                                  timeInterval2: self.ticket.date) {
                                    self.pastDraws.append(game)
                                }
                            }
                        }
                    }
                    // Reload data
                    self?.ticketDataCollectionView.reloadData()
                case .failure(let error):
                    print("Failed to fetch past games: \(error)")
                }
            }
        }
    }
    
    func formatTimeIntervalAsDate(_ timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        return dateFormatter.string(from: date)
    }
}

extension FullTicketViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow both the collection view scroll and custom pan gesture to work
        if ticketDataCollectionView.contentOffset.y == 0 {
            return true
        } else {
            return false
        }
    }
}
