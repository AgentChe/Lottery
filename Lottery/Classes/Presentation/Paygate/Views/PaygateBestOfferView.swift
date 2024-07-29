//
//  PaygateBestOfferView.swift
//  LocationTracker
//
//  Created by Андрей Чернышев on 20.05.2024.
//

import UIKit

final class PaygateBestOfferView: UIView {
    lazy var label = makeLabel()
    
    private lazy var selectedAttrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.Inter.medium(size: 12.scale))
        .lineHeight(19.6.scale)
        .textAlignment(.center)
    private lazy var deselectedAttrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.Inter.medium(size: 12.scale))
        .lineHeight(19.6.scale)
        .textAlignment(.center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension PaygateBestOfferView {
    func update(marked: Bool) {
        let attrs = marked ? selectedAttrs : deselectedAttrs
        label.attributedText = "Paygate.BestOffer".localized.attributed(with: attrs)
        
        backgroundColor = marked ? Appearance.main100 : Appearance.mono100
        
        layer.borderWidth = marked ? 0 : 1.scale
        layer.borderColor = marked ? UIColor.clear.cgColor : Appearance.main500.cgColor
    }
}

// MARK: Private
private extension PaygateBestOfferView {
    func initialize() {
        layer.cornerRadius = 8.scale
    }
}

// MARK: Make constraints
private extension PaygateBestOfferView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 3.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateBestOfferView {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
