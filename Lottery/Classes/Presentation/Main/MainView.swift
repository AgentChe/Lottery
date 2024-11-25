//
//  MainView.swift
//  Printer
//
//  Created by Андрей Чернышев on 24.04.2024.
//

import UIKit

final class MainView: UIView {
    lazy var container = makeContainer()
    lazy var tabView = makeTabView()
    
    // Stored properties for constraints
    var containerBottomConstraint: NSLayoutConstraint?
    var tabViewBottomConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        tabView.alpha = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints

private extension MainView {
    func makeConstraints() {
        // Activate constraints for the container
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        // Create and store the container's bottom constraint
        containerBottomConstraint = container.bottomAnchor.constraint(equalTo: bottomAnchor)
        containerBottomConstraint?.isActive = true
        
        // Activate constraints for the tabView
        NSLayoutConstraint.activate([
            tabView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabView.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 100.scale : 80.scale)
        ])
        
        // Create and store the tabView's bottom constraint
        tabViewBottomConstraint = tabView.bottomAnchor.constraint(equalTo: bottomAnchor)
        tabViewBottomConstraint?.isActive = true
    }
}

// MARK: Lazy initialization
private extension MainView {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.main400
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTabView() -> TabView {
        let view = TabView()
        view.backgroundColor = Appearance.main400
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
