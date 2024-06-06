//
//  CustomSegmentControl.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/6/24.
//

import UIKit

class SSSegmentedControl: UIView {
    
    // MARK: - Properties
    private var stackView: UIStackView = UIStackView()
    private var buttonsCollection: [UIButton] = []
    private var currentIndexView: UIView = UIView(frame: .zero)
    
    var buttonPadding: CGFloat = 5 {
        didSet {
            setupStackView()
        }
    }
    
    var stackViewSpacing: CGFloat = 0 {
        didSet {
            setupStackView()
        }
    }
    
    // MARK: - Callback
    var didTapSegment: ((Int) -> ())?
    
    // MARK: - Properties
    var currentIndex: Int = 0 {
        didSet {
            setCurrentIndex()
        }
    }
    
    var currentIndexTitleColor: UIColor = .white {
        didSet {
            updateTextColors()
        }
    }
    
    var currentIndexBackgroundColor: UIColor = .systemTeal {
        didSet {
            setCurrentViewBackgroundColor()
        }
    }
    
    var otherIndexTitleColor: UIColor = .gray {
        didSet {
            updateTextColors()
        }
    }
    
    var cornerRadius: CGFloat = 15 {
        didSet {
            setCornerRadius()
        }
    }
    
    var buttonCornerRadius: CGFloat = 10 {
        didSet {
            setButtonCornerRadius()
        }
    }
    
    var borderColor: UIColor = .systemTeal {
        didSet {
            setBorderColor()
        }
    }
    
    var borderWidth: CGFloat = 1 {
        didSet {
            setBorderWidth()
        }
    }
    
    var numberOfSegments: Int = 2 {
        didSet {
            addSegments()
        }
    }
    
    var segmentsTitle: String = "Segment 1,Segment 2" {
        didSet {
            updateSegmentTitles()
        }
    }
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setCurrentIndex(animated: false)
    }
}

// MARK: - Public Methods
extension SSSegmentedControl {
    
    @objc func segmentTapped(_ sender: UIButton) {
        didTapSegment?(sender.tag)
        currentIndex = sender.tag
    }
}

// MARK: - Private Methods
private extension SSSegmentedControl {
    
    func commonInit() {
        backgroundColor = .clear
        setupStackView()
        addSegments()
        setCurrentIndexView()
        setCurrentIndex(animated: false)
        setCornerRadius()
        setButtonCornerRadius()
        setBorderColor()
        setBorderWidth()
    }
    
    func setCurrentIndexView() {
        setCurrentViewBackgroundColor()
        addSubview(currentIndexView)
        sendSubviewToBack(currentIndexView)
    }
    
    func setCurrentIndex(animated: Bool = true) {
        stackView.subviews.enumerated().forEach { (index, view) in
            let button: UIButton? = view as? UIButton
            if index == currentIndex {
                let buttonWidth = (frame.width - (buttonPadding * 2)) / CGFloat(numberOfSegments)
                if animated {
                    UIView.animate(withDuration: 0.3) {
                        self.currentIndexView.frame = CGRect(x: self.buttonPadding + (buttonWidth * CGFloat(index)),
                                                             y: self.buttonPadding,
                                                             width: buttonWidth,
                                                             height: self.frame.height - (self.buttonPadding * 2))
                    }
                } else {
                    self.currentIndexView.frame = CGRect(x: self.buttonPadding + (buttonWidth * CGFloat(index)),
                                                         y: self.buttonPadding,
                                                         width: buttonWidth,
                                                         height: self.frame.height - (self.buttonPadding * 2))
                }
                button?.setTitleColor(currentIndexTitleColor, for: .normal)
            } else {
                button?.setTitleColor(otherIndexTitleColor, for: .normal)
            }
        }
    }
    
    func updateTextColors() {
        stackView.subviews.enumerated().forEach { (index, view) in
            let button: UIButton? = view as? UIButton
            if index == currentIndex {
                button?.setTitleColor(currentIndexTitleColor, for: .normal)
            } else {
                button?.setTitleColor(otherIndexTitleColor, for: .normal)
            }
        }
    }
    
    func setCurrentViewBackgroundColor() {
        currentIndexView.backgroundColor = currentIndexBackgroundColor
        currentIndexView.layer.cornerRadius = 20
        currentIndexView.clipsToBounds = true
    }
    
    func setupStackView() {
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = stackViewSpacing
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonPadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -buttonPadding),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: buttonPadding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -buttonPadding)
        ])
    }
    
    func addSegments() {
        buttonsCollection.removeAll()
        stackView.subviews.forEach { view in
            (view as? UIButton)?.removeFromSuperview()
        }
        
        let titles = segmentsTitle.split(separator: ",")
        
        for index in 0 ..< numberOfSegments {
            let button = UIButton()
            button.tag = index
            
            if titles.indices.contains(index) {
                button.setTitle(String(titles[index]), for: .normal)
            } else {
                button.setTitle("<Segment>", for: .normal)
            }
            
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            button.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
            buttonsCollection.append(button)
        }
    }
    
    func updateSegmentTitles() {
        let titles = segmentsTitle.split(separator: ",")
        
        stackView.subviews.enumerated().forEach { (index, view) in
            if titles.indices.contains(index) {
                (view as? UIButton)?.setTitle(String(titles[index]), for: .normal)
            } else {
                (view as? UIButton)?.setTitle("<Segment>", for: .normal)
            }
        }
    }
    
    func setCornerRadius() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
    func setButtonCornerRadius() {
        stackView.subviews.forEach { view in
            (view as? UIButton)?.layer.cornerRadius = cornerRadius
        }
        currentIndexView.layer.cornerRadius = cornerRadius
    }
    
    func setBorderColor() {
        layer.borderColor = borderColor.cgColor
    }
    
    func setBorderWidth() {
        layer.borderWidth = borderWidth
    }
}
