import UIKit

class FullTicketViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    let customTransitionManager = FullTicketCustomTransitionManager()
    
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
        collectionView.backgroundColor = .red
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }()
    
    var lotteries: [Lottery] = []
    var lotteryPatterns: [LotteryPattern] = []
    var ticket: Ticket!
    
    private let gamesManager: GamesManagerProtocol = GamesManager()
    private var pastDraws: [Game] = [] {
        didSet {
            self.ticketDataCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Make the main view clear
        view.backgroundColor = UIColor.clear
        
        // Setup the background view
        setupBackgroundView()
        
        // Setup custom transition manager
        transitioningDelegate = customTransitionManager
        modalPresentationStyle = .overFullScreen
        
        // Setup the swipe gesture
        customTransitionManager.setupGestureRecognizer(in: self)
        
        // Add a tap gesture recognizer to the main view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap))
        view.addGestureRecognizer(tapGesture)
        
        // Setup the ticketDataCollectionView
        setupCollectionView()
        
        // Fetch past games
        fetchPastGames(for: nil)
    }
    
    private func setupBackgroundView() {
        // Add backgroundView to the main view
        view.addSubview(backgroundView)
        
        // Set up constraints for backgroundView
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),  // Adjust width as needed
            backgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8) // 90% of main view's height
        ])
    }
    
    private func setupCollectionView() {
        // Add collection view to the background view
        backgroundView.addSubview(ticketDataCollectionView)
        
        // Set the delegate and dataSource
        ticketDataCollectionView.delegate = self
        ticketDataCollectionView.dataSource = self
        ticketDataCollectionView.isScrollEnabled = true // Initially, scrolling is enabled
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
    
    @objc private func handleViewTap() {
        // Dismiss the view controller when the view is tapped
        dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension FullTicketViewController: UICollectionViewDataSource, UIScrollViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TicketDataCell", for: indexPath) as! TicketDataCell
        cell.isTheWinner = true
        cell.lotteries = lotteries
        cell.lotteryPatterns = lotteryPatterns
        cell.ticket = ticket
        if !pastDraws.isEmpty {
            cell.pastDraws = pastDraws
        }
        return cell
    }
    
//    // Monitor scrolling behavior
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let contentOffsetY = scrollView.contentOffset.y
//        print("offset")
//        // Detect scroll direction
//        
//        if contentOffsetY > previousContentOffsetY {
//            print("Scrolling Down")
//            ticketDataCollectionView.isScrollEnabled = true
//           
//        } else if contentOffsetY < previousContentOffsetY {
//            print("Scrolling Up")
//            if contentOffsetY <= 0 {
//                ticketDataCollectionView.isScrollEnabled = false
//            } else {
//                ticketDataCollectionView.isScrollEnabled = true
//            }
//        }
//        
//       
//    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FullTicketViewController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: view.frame.height * 0.2, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 1200.scale) // Adjust size as needed
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
