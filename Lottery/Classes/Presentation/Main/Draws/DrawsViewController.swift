import UIKit
import AVFoundation
import Lottie

class DrawsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    struct ScrollViewState {
        var previousScrollOffset: CGFloat = 0.0
        var initialContentOffset: CGFloat = 0.0
        var hasRecordedInitialOffset: Bool = false
    }

    private var scrollStates: [UIScrollView: ScrollViewState] = [:]
    
    var profile: Profile!
    var games: [Game] = []
    var dimView: UIView!
    var isDrawScan: Bool = false
    var isScratchScan: Bool = false
    var lotteryPatterns: [LotteryPattern] = []
    private var previousVC: UIViewController?
    var menuButton: UIButton!
    var changeStateButton: UIButton!
    var scanOptionButton: UIButton!
    var luckyNumbersButton: UIButton!
    var ticketsButton: UIButton!
    private var upperMenuView: UIImageView!
    private var upperMenuHeightConstraint: NSLayoutConstraint!
    private var segmentTopConstraint : NSLayoutConstraint!
    private var premiumAnimationView: LottieAnimationView!
    let maxUpperMenuHeight: CGFloat = ScreenSize.isIphoneXFamily ? 180.scale : 135.scale
    let minUpperMenuHeight: CGFloat = ScreenSize.isIphoneXFamily ? 130.scale : 115.scale
    let segmentedControlBackgroundView = UIView()

    lazy var luckyNumbersVC = NavigationController(rootViewController: luckyNumbersController)
    lazy var myTicketsVC = NavigationController(rootViewController: myTicketsController)
    private lazy var luckyNumbersController = LuckyNumbersViewController()
    private lazy var myTicketsController = TicketsViewController()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func findSubviewsConnectedToNavigationBar() -> [UIView] {
        var connectedSubviews: [UIView] = []
        if let navigationController = self.navigationController {
            let navigationBarSubviews = navigationController.navigationBar.subviews
            connectedSubviews.append(contentsOf: navigationBarSubviews)
            if let toolbarSubviews = navigationController.toolbar?.subviews {
                connectedSubviews.append(contentsOf: toolbarSubviews)
            }
        }
        return connectedSubviews
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarTitle()
      //  fetchStateAndGames()
        isDrawScan = false
        isScratchScan = false
        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()
        if let currentCollectionView = segmentedControl.currentIndex == 0 ? nextDrawsCollectionView : pastDrawsCollectionView {
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchStateAndGames()
    }
    func fetchLotteriesPatterns(for stateId: Int? = nil) {
        contentManager.fetchLotteriesPattern(forceUpdate: false, stateId: nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let patterns):
                    self?.lotteryPatterns = patterns
                    if let stateId = stateId {
                        self?.fetchNextGames(for: stateId)
                        self?.fetchPastGames(for: stateId)
                    }
                case .failure(let error):
                    print("Failed to fetch lottery patterns: \(error)")
                }
            }
        }
    }

    private var segmentedControl: SSSegmentedControl = SSSegmentedControl()
    private var profileManager: ProfileManagerProtocol = ProfileManager()
    private var contentManager: ContentManagerProtocol = ContentManager()
    private var nextDrawsCollectionView: UICollectionView!
    private var pastDrawsCollectionView: UICollectionView!
    private var scanButton: UIButton!
    private var noGamesAddedImageView: UIImageView!
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to settings", for: .normal)
        button.backgroundColor = Appearance.main100
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.Inter.bold(size: 16.scale)
        button.layer.cornerRadius = 22.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 195.scale).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44.scale).isActive = true
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    @objc func addButtonTapped() {
        if SessionManager().hasActiveSubscriptions() {
            let scanOnboardingViewController = ScanOnboardingViewController.make()
            scanOnboardingViewController.immediateGameChoose = true
            scanOnboardingViewController.fromMenu = true
            let profileManager = ProfileManager()
            profileManager.getProfile(forceUpdate: false) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let profile):
                        if let stateId = profile.state {
                            scanOnboardingViewController.selectedState = stateId
                            scanOnboardingViewController.showSelectLotteriesViewController()
                        } else {
                            print("State ID is not available in profile")
                        }
                    case .failure(let error):
                        print("Failed to fetch profile: \(error)")
                    }
                }
            }
            if let navigationController = self.navigationController {
                navigationController.pushViewController(scanOnboardingViewController, animated: false)
                if let navigationController = getRootViewController() as? NavigationController,
                   let mainViewController = navigationController.viewControllers.first as? MainViewController {
                    updateMainViewControllerConstraints(for: mainViewController)
                }
            } else {
                present(scanOnboardingViewController, animated: true, completion: nil)
            }
        } else {
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }

    private var nextDraws: [Game] = [] {
        didSet {
            nextDraws.sort { $0.date > $1.date }
            noGamesAddedImageView.isHidden = profile.lotteries?.count != 0
            addButton.isHidden = profile.lotteries?.count != 0
        }
    }

    private var pastDraws: [Game] = [] {
        didSet {
            pastDraws.sort { $0.date > $1.date }
            nextDrawsCollectionView.reloadData()
        }
    }

    private var lotteries: [Lottery] = []

    private let gamesManager: GamesManagerProtocol = GamesManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.main400
        setupCollectionViews()
        setupSegmentedControl()
        setupUpperMenuView()
        setupNoGamesAddedImageView()
        setupLayoutConstraints()
        setupPremiumAnimationView()
    }

    private var previousScrollOffset: CGFloat = .zero
    private var initialContentOffset: CGFloat = 0.0
    private var hasRecordedInitialOffset = false

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var scrollState = scrollStates[scrollView] ?? ScrollViewState()

        let currentOffset = scrollView.contentOffset.y
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0

        if !scrollState.hasRecordedInitialOffset {
            scrollState.initialContentOffset = currentOffset
            scrollState.hasRecordedInitialOffset = true
        }

        let deltaYFromInitial = currentOffset - scrollState.initialContentOffset

        let minHeight = topPadding + minUpperMenuHeight
        let maxHeight = maxUpperMenuHeight + 45.scale

        var newHeight = maxHeight - deltaYFromInitial
        newHeight = max(minHeight, min(maxHeight, newHeight))
        upperMenuHeightConstraint.constant = newHeight

        let alpha = (newHeight - minHeight) / (maxHeight - minHeight)
        menuButton.alpha = alpha
        changeStateButton.alpha = alpha

        view.layoutIfNeeded()

        scrollState.previousScrollOffset = currentOffset
        scrollStates[scrollView] = scrollState
    }
}

extension DrawsViewController {
    private func setupPremiumAnimationView() {
        premiumAnimationView = LottieAnimationView(name: "Premium")
        premiumAnimationView.translatesAutoresizingMaskIntoConstraints = false
        premiumAnimationView.contentMode = .scaleAspectFit
        premiumAnimationView.loopMode = .loop
        premiumAnimationView.play()
        view.addSubview(premiumAnimationView)

        NSLayoutConstraint.activate([
            premiumAnimationView.widthAnchor.constraint(equalToConstant: 199.scale),
            premiumAnimationView.heightAnchor.constraint(equalToConstant: 66.scale),
            premiumAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.scale),
            premiumAnimationView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20.scale)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePremiumAnimationTap))
        premiumAnimationView.isUserInteractionEnabled = true
        premiumAnimationView.addGestureRecognizer(tapGesture)
        if SessionManager().hasActiveSubscriptions() {
            premiumAnimationView.alpha = 0
        } else {
            premiumAnimationView.alpha = 1
        }
    }

    @objc private func handlePremiumAnimationTap() {
        let vc = PaygateViewController.make()
        present(vc, animated: true)
    }

    func setupUpperMenuView() {
        upperMenuView = UIImageView()
        upperMenuView.contentMode = .scaleAspectFill
        upperMenuView.layer.masksToBounds = true
        if let image = UIImage(named: "upperMenuButtonImageView") {
            upperMenuView.image = image
        }
        upperMenuView.isUserInteractionEnabled = true
        upperMenuView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(upperMenuView)

        scanOptionButton = createButton(imageName: "ScanButtonImage")
        luckyNumbersButton = createButton(imageName: "NumbersButtonImage")
        ticketsButton = createButton(imageName: "MyTicketsButtonImage")
        menuButton = createMenuButton(imageName: "whiteBurger")
        scanOptionButton.addTarget(self, action: #selector(chooseScanOption), for: .touchUpInside)
        luckyNumbersButton.addTarget(self, action: #selector(numbersButtonTapped), for: .touchUpInside)
        ticketsButton.addTarget(self, action: #selector(myTicketsButtonTapped), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(handleMenuTap), for: .touchUpInside)

        changeStateButton = UIButton(type: .custom)
        if let changeStateImage = UIImage(named: "changeState") {
            changeStateButton.setImage(changeStateImage, for: .normal)
        }
        changeStateButton.translatesAutoresizingMaskIntoConstraints = false
        upperMenuView.addSubview(changeStateButton)
        changeStateButton.addTarget(self, action: #selector(changeStateButtonTapped), for: .touchUpInside)

        let label1 = createLabel(text: "DrawsViewController.Scan".localized)
        let label2 = createLabel(text: "DrawsViewController.Numbers".localized)
        let label3 = createLabel(text: "DrawsViewController.MyTickets".localized)

        upperMenuView.addSubview(scanOptionButton)
        upperMenuView.addSubview(luckyNumbersButton)
        upperMenuView.addSubview(ticketsButton)
        upperMenuView.addSubview(menuButton)
        upperMenuView.addSubview(label1)
        upperMenuView.addSubview(label2)
        upperMenuView.addSubview(label3)

        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top ?? 0
            upperMenuHeightConstraint = upperMenuView.heightAnchor.constraint(equalToConstant: topPadding + maxUpperMenuHeight)

            NSLayoutConstraint.activate([
                upperMenuView.topAnchor.constraint(equalTo: view.topAnchor),
                upperMenuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                upperMenuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                upperMenuHeightConstraint
            ])
        }

        NSLayoutConstraint.activate([
            scanOptionButton.leadingAnchor.constraint(equalTo: upperMenuView.leadingAnchor, constant: 16.scale * 2.2),
            scanOptionButton.bottomAnchor.constraint(equalTo: upperMenuView.bottomAnchor, constant: -48.scale),
            scanOptionButton.widthAnchor.constraint(equalToConstant: 68.scale),
            scanOptionButton.heightAnchor.constraint(equalToConstant: 68.scale),
            label1.centerXAnchor.constraint(equalTo: scanOptionButton.centerXAnchor),
            label1.topAnchor.constraint(equalTo: scanOptionButton.bottomAnchor, constant: 4.scale),
            ticketsButton.centerXAnchor.constraint(equalTo: upperMenuView.centerXAnchor),
            ticketsButton.bottomAnchor.constraint(equalTo: upperMenuView.bottomAnchor, constant: -48.scale),
            ticketsButton.widthAnchor.constraint(equalToConstant: 68.scale),
            ticketsButton.heightAnchor.constraint(equalToConstant: 68.scale),
            label2.centerXAnchor.constraint(equalTo: luckyNumbersButton.centerXAnchor),
            label2.topAnchor.constraint(equalTo: luckyNumbersButton.bottomAnchor, constant: 4.scale),
            luckyNumbersButton.trailingAnchor.constraint(equalTo: upperMenuView.trailingAnchor, constant: -16.scale * 2.2),
            luckyNumbersButton.bottomAnchor.constraint(equalTo: upperMenuView.bottomAnchor, constant: -48.scale),
            luckyNumbersButton.widthAnchor.constraint(equalToConstant: 68.scale),
            luckyNumbersButton.heightAnchor.constraint(equalToConstant: 68.scale),
            label3.centerXAnchor.constraint(equalTo: ticketsButton.centerXAnchor),
            label3.topAnchor.constraint(equalTo: ticketsButton.bottomAnchor, constant: 4.scale),
            menuButton.trailingAnchor.constraint(equalTo: upperMenuView.trailingAnchor, constant: -16.scale),
            menuButton.bottomAnchor.constraint(equalTo: luckyNumbersButton.topAnchor, constant: -22.scale),
            menuButton.widthAnchor.constraint(equalToConstant: 24.scale),
            menuButton.heightAnchor.constraint(equalToConstant: 24.scale),
            changeStateButton.trailingAnchor.constraint(equalTo: menuButton.leadingAnchor, constant: -16.scale),
            changeStateButton.topAnchor.constraint(equalTo: ticketsButton.topAnchor, constant: -47.scale),
            changeStateButton.widthAnchor.constraint(equalToConstant: 82.scale),
            changeStateButton.heightAnchor.constraint(equalToConstant: 26.scale)
        ])
    }

    @objc func changeStateButtonTapped() {
        let scanOnboardingViewController = ScanOnboardingViewController.make()
        scanOnboardingViewController.fromDrawsViewController = true
        if let navigationController = self.navigationController {
            navigationController.setNavigationBarHidden(false, animated: false)
            navigationController.pushViewController(scanOnboardingViewController, animated: true)
        } else {
            present(scanOnboardingViewController, animated: true, completion: nil)
        }
    }

    @objc func chooseScanOption() {
        if !SessionManager().hasActiveSubscriptions() {
            dimView = UIView(frame: self.view.bounds)
            dimView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            dimView.alpha = 0
            view.addSubview(dimView)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissScanOption))
            dimView.addGestureRecognizer(tapGesture)

            let chooseScanOptionView = ChooseScanOptionView()
            chooseScanOptionView.translatesAutoresizingMaskIntoConstraints = false
            chooseScanOptionView.layer.cornerRadius = 20.scale
            view.addSubview(chooseScanOptionView)

            NSLayoutConstraint.activate([
                chooseScanOptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.scale),
                chooseScanOptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.scale),
                chooseScanOptionView.heightAnchor.constraint(equalToConstant: 200.scale),
                chooseScanOptionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 200.scale)
            ])

            view.layoutIfNeeded()

            UIView.animate(withDuration: 0.3) {
                self.dimView.alpha = 0.7
                chooseScanOptionView.transform = CGAffineTransform(translationX: 0, y: -250.scale)
                self.view.layoutIfNeeded()
            }
            
            let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissScanOption))
                   dimView.addGestureRecognizer(dismissTapGesture)
            dimView.addGestureRecognizer(dismissTapGesture)
            
            chooseScanOptionView.dismissButton.addTarget(self, action: #selector(dismissChooseScanOptionView(_:)), for: .touchUpInside)
        } else {
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }

    @objc func dismissChooseScanOptionView(_ sender: UIButton) {
        if let chooseScanOptionView = view.subviews.first(where: { $0 is ChooseScanOptionView }) as? ChooseScanOptionView {
            UIView.animate(withDuration: 0.3, animations: {
                chooseScanOptionView.transform = .identity
                self.dimView.alpha = 0
            }, completion: { _ in
                chooseScanOptionView.removeFromSuperview()
                self.dimView.removeFromSuperview()
            })
        }
    }

    @objc func dismissScanOption() {
        dismissChooseScanOptionView(scanOptionButton)
    }

    func dismissAndPresentreScanDraw(chooseScanOptionView: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            chooseScanOptionView.transform = .identity
            self.dimView.alpha = 0
        }, completion: { _ in
            chooseScanOptionView.removeFromSuperview()
            self.dimView.removeFromSuperview()
            self.rescanButtonTapped()
        })
    }

    func dismissAndPresentScanDraw(chooseScanOptionView: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            chooseScanOptionView.transform = .identity
            self.dimView.alpha = 0
        }, completion: { _ in
            chooseScanOptionView.removeFromSuperview()
            self.dimView.removeFromSuperview()
            self.scanButtonTapped()
        })
    }

    @objc func numbersButtonTapped() {
        if let navigationController = self.navigationController {
            navigationController.pushViewController(luckyNumbersController, animated: true)
            navigationController.setNavigationBarHidden(false, animated: false)
        } else {
            present(luckyNumbersVC, animated: true, completion: nil)
        }
    }

    @objc func myTicketsButtonTapped() {
        if let navigationController = self.navigationController {
            navigationController.pushViewController(myTicketsController, animated: true)
            navigationController.setNavigationBarHidden(false, animated: false)
        } else {
            present(myTicketsVC, animated: true, completion: nil)
        }
    }

    func createButton(imageName: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor(hex: "#D9E2FA", alpha: 0.2)
        button.layer.cornerRadius = 34.scale
        button.clipsToBounds = true
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24.scale),
            imageView.heightAnchor.constraint(equalToConstant: 24.scale)
        ])
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    func createMenuButton(imageName: String) -> UIButton {
        let button = UIButton(type: .custom)
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 16.scale),
            imageView.heightAnchor.constraint(equalToConstant: 12.scale)
        ])
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = Fonts.Inter.medium(size: 14.scale)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.layer.cornerRadius = 5.scale
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func setupSegmentedControl() {
        segmentedControlBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControlBackgroundView.backgroundColor = Appearance.main400
        view.addSubview(segmentedControlBackgroundView)
        segmentedControl.currentIndexTitleColor = UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1)
        segmentedControl.otherIndexTitleColor = UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1)
        segmentedControl.currentIndexBackgroundColor = Appearance.main400
        segmentedControl.cornerRadius = 24.scale
        segmentedControl.buttonPadding = 4.scale
        segmentedControl.buttonCornerRadius = 20.scale
        segmentedControl.numberOfSegments = 2
        segmentedControl.segmentsTitle = "\("DrawsViewController.NextDraws".localized),\("DrawsViewController.PastDraws".localized)"
        segmentedControl.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        segmentedControl.layer.borderColor = UIColor.clear.cgColor

        segmentedControl.didTapSegment = { [weak self] index in
            self?.segmentedControlChanged(index: index)
            self?.fetchStateAndGames()
        }

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
    }

    func setupCollectionViews() {
        let nextDrawsCollectionViewLayout = UICollectionViewFlowLayout()
        nextDrawsCollectionViewLayout.scrollDirection = .vertical
        nextDrawsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: nextDrawsCollectionViewLayout)
        nextDrawsCollectionView.backgroundColor = .clear
        nextDrawsCollectionView.delegate = self
        nextDrawsCollectionView.dataSource = self
        nextDrawsCollectionView.register(NextGameCell.self, forCellWithReuseIdentifier: "NextGameCell")
        nextDrawsCollectionView.showsVerticalScrollIndicator = false
        nextDrawsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        nextDrawsCollectionView.layer.masksToBounds = false
        view.addSubview(nextDrawsCollectionView)

        let pastDrawsCollectionViewLayout = UICollectionViewFlowLayout()
        pastDrawsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: pastDrawsCollectionViewLayout)
        pastDrawsCollectionView.backgroundColor = .clear
        pastDrawsCollectionView.delegate = self
        pastDrawsCollectionView.dataSource = self
        pastDrawsCollectionView.register(PastGameCell.self, forCellWithReuseIdentifier: "PastGameCell")
        pastDrawsCollectionView.showsVerticalScrollIndicator = false
        pastDrawsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pastDrawsCollectionView.layer.masksToBounds = false
        view.addSubview(pastDrawsCollectionView)
        pastDrawsCollectionView.isHidden = true
    }

    func setupNoGamesAddedImageView() {
        noGamesAddedImageView = UIImageView(image: UIImage(named: "NextDraws.NoGames"))
        noGamesAddedImageView.translatesAutoresizingMaskIntoConstraints = false
        noGamesAddedImageView.contentMode = .scaleAspectFit
        noGamesAddedImageView.isHidden = true
        view.addSubview(noGamesAddedImageView)
        view.addSubview(addButton)
    }

    func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            segmentedControlBackgroundView.topAnchor.constraint(equalTo: upperMenuView.bottomAnchor, constant: 0),
            segmentedControlBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedControlBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentedControlBackgroundView.heightAnchor.constraint(equalToConstant: 72.scale),
            segmentedControl.topAnchor.constraint(equalTo: segmentedControlBackgroundView.topAnchor, constant: 16.scale),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: 285.scale),
            segmentedControl.heightAnchor.constraint(equalToConstant: 48.scale),
            nextDrawsCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            nextDrawsCollectionView.widthAnchor.constraint(equalToConstant: 343.scale),
            nextDrawsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            nextDrawsCollectionView.centerXAnchor.constraint(equalTo: segmentedControl.centerXAnchor),
            pastDrawsCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            pastDrawsCollectionView.widthAnchor.constraint(equalToConstant: 343.scale),
            pastDrawsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            pastDrawsCollectionView.centerXAnchor.constraint(equalTo: segmentedControl.centerXAnchor),
            noGamesAddedImageView.widthAnchor.constraint(equalToConstant: 344.scale),
            noGamesAddedImageView.heightAnchor.constraint(equalToConstant: 235.scale),
            noGamesAddedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noGamesAddedImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30.scale),
            addButton.widthAnchor.constraint(equalToConstant: 195.scale),
            addButton.heightAnchor.constraint(equalToConstant: 44.scale),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: noGamesAddedImageView.bottomAnchor, constant: 30.scale)
        ])
    }
}

extension DrawsViewController {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth: CGFloat = 343.scale
        var cellHeight: CGFloat

        if collectionView == nextDrawsCollectionView {
            let game = nextDraws[indexPath.item]
            for lottery in lotteries {
                if lottery.id == game.lotteryId {
                    if doesURLContain(lottery.logoUrl.absoluteString, word: "power") || doesURLContain(lottery.logoUrl.absoluteString, word: "cash4") {
                        return CGSize(width: cellWidth, height: 204.scale)
                    } else {
                        return CGSize(width: cellWidth, height: 232.scale)
                    }
                }
            }
            return CGSize(width: cellWidth, height: 232.scale)
        } else {
            let game = pastDraws[indexPath.item]
            cellHeight = 176.scale
            if let myLuckyNumbers = game.myLuckyNumbers, let winningNumbers = game.winningNumbers {
                for lottery in lotteries {
                    if lottery.id == game.lotteryId {
                        if doesURLContain(lottery.logoUrl.absoluteString, word: "power") || doesURLContain(lottery.logoUrl.absoluteString, word: "cash4") {
                            if myLuckyNumbers.isEmpty {
                                cellHeight = 204.scale
                            } else {
                                cellHeight = 116.scale + 12.scale + 24.scale + 20.scale + 15.scale + 24.scale + 20.scale + CGFloat(max(0, winningNumbers.count)) * CGFloat(40.scale + 8.scale) + CGFloat(max(0, myLuckyNumbers.count)) * CGFloat(40.scale + 8.scale) + 3.scale
                            }
                        } else {
                            if myLuckyNumbers.isEmpty {
                                cellHeight = 232.scale
                            } else {
                                cellHeight = 144.scale + 12.scale + 24.scale + 20.scale + 15.scale + 24.scale + 20.scale + CGFloat(max(0, winningNumbers.count)) * CGFloat(40.scale + 8.scale) + CGFloat(max(0, myLuckyNumbers.count)) * CGFloat(40.scale + 8.scale) - 5.scale
                            }
                        }
                    }
                }
            }
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16.scale
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let bottomInset: CGFloat = SessionManager().hasActiveSubscriptions() ? 10.scale : 100.scale
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        return UIEdgeInsets(top: maxUpperMenuHeight + 45.scale + (ScreenSize.isIphoneXFamily ? 30.scale : 70.scale), left: 0, bottom: bottomInset, right: 0)
    }
}

extension DrawsViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == nextDrawsCollectionView {
            return nextDraws.count
        } else {
            return pastDraws.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == nextDrawsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NextGameCell", for: indexPath) as! NextGameCell
            let game = nextDraws[indexPath.item]
            for pastDraw in self.pastDraws {
                if pastDraw.lotteryId == game.lotteryId {
                    if let pattern: LotteryPattern = lotteryPatterns.filter({ $0.id == game.lotteryId }).first {
                        cell.bonusIdx = pattern.bonusIdx
                    }
                    cell.winningNumbers = pastDraw.winningNumbers ?? []
                    cell.winningNumbersCollectionView.reloadData()
                    break
                }
            }
            cell.configure(game: game, lotteries: lotteries)
            cell.layer.cornerRadius = 20.scale
            cell.setNeedsLayout()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PastGameCell", for: indexPath) as! PastGameCell
            let game = pastDraws[indexPath.item]
            if let pattern: LotteryPattern = lotteryPatterns.filter({ $0.id == game.lotteryId }).first {
                cell.bonusIdx = pattern.bonusIdx
            }
            cell.configure(game: game, lotteries: lotteries)
            cell.layer.cornerRadius = 20.scale
            cell.layer.masksToBounds = true
            if let myLuckyNumbers = game.myLuckyNumbers {
                if myLuckyNumbers.isEmpty {
                    cell.dashedLineImageView.alpha = 0
                    cell.myLuckyNumbersTitleLabel.alpha = 0
                } else {
                    cell.dashedLineImageView.alpha = 1
                    cell.myLuckyNumbersTitleLabel.alpha = 1
                }
            }
            cell.setNeedsLayout()
            return cell
        }
    }
}

private extension DrawsViewController {
    func setupNavigationBarTitle() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.titleView = nil
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isUserInteractionEnabled = false
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @objc func handleMenuTap() {
        let menuVC = MenuViewController()
        let navController = NavigationController(rootViewController: menuVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }

    func segmentedControlChanged(index: Int) {
        let newCollectionView: UICollectionView
        if index == 0 {
            nextDrawsCollectionView.isHidden = false
            pastDrawsCollectionView.isHidden = true
            newCollectionView = nextDrawsCollectionView
        } else {
            nextDrawsCollectionView.isHidden = true
            pastDrawsCollectionView.isHidden = false
            newCollectionView = pastDrawsCollectionView
        }

        if scrollStates[newCollectionView] == nil {
            var scrollState = ScrollViewState()
            scrollState.initialContentOffset = newCollectionView.contentOffset.y
            scrollState.previousScrollOffset = newCollectionView.contentOffset.y
            scrollState.hasRecordedInitialOffset = true
            scrollStates[newCollectionView] = scrollState
        }
        scrollViewDidScroll(newCollectionView)
    }

    func fetchStateAndGames() {
        profileManager.getProfile(forceUpdate: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    if let stateId = profile.state {
                        self?.profile = profile
                        self?.fetchLotteries(for: stateId)
                    } else {
                        print("State ID is not available in profile")
                    }
                case .failure(let error):
                    print("Failed to fetch profile: \(error)")
                }
            }
        }
    }

    func fetchNextGames(for stateId: Int) {
        gamesManager.fetchNextGames(stateId: nil, forceUpdate: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let games):
                    self?.nextDraws = []
                    for game in games {
                        if let lotteries = self?.profile.lotteries {
                            if lotteries.count > 0 {
                                for lottery in lotteries {
                                    if game.lotteryId == lottery {
                                        self?.nextDraws.append(game)
                                    }
                                }
                            } else {
                                self?.nextDraws.append(game)
                            }
                        }
                    }
                    if games.count != 0 {
                        self?.noGamesAddedImageView.isHidden = true
                        self?.addButton.isHidden = true
                    }
                    delay(0.05) {
                        self?.nextDrawsCollectionView.reloadData()
                    }
                case .failure(let error):
                    print("Failed to fetch next games: \(error)")
                }
            }
        }
    }

    func fetchPastGames(for stateId: Int) {
        gamesManager.fetchPastGames(stateId: nil, forceUpdate: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let games):
                    self?.pastDraws = []
                    for game in games {
                        if let lotteries = self?.profile.lotteries {
                            if lotteries.count > 0 {
                                for lottery in lotteries {
                                    if game.lotteryId == lottery {
                                        self?.pastDraws.append(game)
                                    }
                                }
                            } else {
                                self?.pastDraws.append(game)
                            }
                        }
                    }
                    delay(0.09) {
                        self?.pastDrawsCollectionView.reloadData()
                    }
                case .failure(let error):
                    print("Failed to fetch past games: \(error)")
                }
            }
        }
    }

    func fetchLotteries(for stateId: Int) {
        contentManager.fetchLotteries(forceUpdate: false, stateId: nil) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lotteries):
                    self?.lotteries = []
                    for lottery in lotteries {
                        if let profile = self?.profile {
                            if let profileLotteries = profile.lotteries {
                                if profileLotteries.count > 0 {
                                    if profileLotteries.contains(lottery.id) {
                                        self?.lotteries.append(lottery)
                                    }
                                } else {
                                    self?.lotteries.append(lottery)
                                }
                            }
                        }
                    }
                    self?.fetchLotteriesPatterns(for: stateId)
                case .failure(let error):
                    print("Failed to fetch lotteries: \(error)")
                }
            }
        }
    }
}

private extension DrawsViewController {
    @objc func scanButtonTapped() {
        let scanOnboardingViewController = ScanOnboardingViewController.make()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(scanOnboardingViewController, animated: true)
            navigationController.setNavigationBarHidden(false, animated: false)
            if let navigationController = getRootViewController() as? NavigationController,
               let mainViewController = navigationController.viewControllers.first as? MainViewController {
                updateMainViewControllerConstraints(for: mainViewController)
            }
        }
    }

    @objc func rescanButtonTapped() {
        let scanViewController = ScanMenuViewController()
        scanViewController.stateId = 888
        scanViewController.lotteryId = 888
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    if granted {
                        let scanViewController = ScanViewController()
                        scanViewController.stateId = 888
                        scanViewController.lotteryId = 888
                        if let navigationController = self.navigationController {
                            navigationController.pushViewController(scanViewController, animated: true)
                            navigationController.setNavigationBarHidden(false, animated: false)
                        } else {
                            self.present(scanViewController, animated: true, completion: nil)
                        }
                    } else {
                        print("Camera access denied.")
                    }
                }
            }
        case .restricted, .denied:
            self.showCameraAccessDeniedAlert()
        case .authorized:
            DispatchQueue.main.async {
                let scanViewController = ScanViewController()
                scanViewController.stateId = 888
                scanViewController.lotteryId = 888
                if let navigationController = self.navigationController {
                    navigationController.pushViewController(scanViewController, animated: true)
                    navigationController.setNavigationBarHidden(false, animated: false)
                } else {
                    self.present(scanViewController, animated: true, completion: nil)
                }
            }
        @unknown default:
            fatalError("Unknown camera authorization status.")
        }
    }

    func showCameraAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "ScanMenuViewController.CameraAccessNeededTitle".localized,
            message: "ScanMenuViewController.CameraAccessNeededMessage".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ScanMenuViewController.OpenSettingsButton".localized, style: .default, handler: { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "ScanMenuViewController.CancelButton".localized, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func updateMainViewControllerConstraints(for mainViewController: MainViewController, newConstant: CGFloat = ScreenSize.isIphoneXFamily ? 100.scale : 80.scale) {
        let mainView = mainViewController.mainView
        let tabView = mainView.tabView
        if mainView.tabViewBottomConstraint?.constant != newConstant {
            if let oldTabViewBottomConstraint = mainView.tabViewBottomConstraint {
                oldTabViewBottomConstraint.isActive = false
                mainView.tabViewBottomConstraint = nil
            }
            let newTabViewBottomConstraint = tabView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: newConstant)
            mainView.tabViewBottomConstraint = newTabViewBottomConstraint
            newTabViewBottomConstraint.isActive = true
            mainView.layoutIfNeeded()
        }
    }
}

private extension DrawsViewController {
    func doesURLContain(_ urlString: String, word: String) -> Bool {
        return urlString.lowercased().contains(word)
    }
}

func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
