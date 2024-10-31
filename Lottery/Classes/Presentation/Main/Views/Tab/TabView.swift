//
//  TabView.swift
//  Lottery
//
//  Created by Андрей Чернышев on 23.05.2024.
//

import UIKit

final class TabView: UIView {
    enum Tab {
        case draws, generator
    }
    
    lazy var divider = makeDivider()
    lazy var drawsItem = makeItem(code: "Main.Draws")
    lazy var generatorItem = makeItem(code: "Main.Generator")
  
    var selectedTab = Tab.draws {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension TabView {
    func update() {
        drawsItem.marked = selectedTab == .draws
        generatorItem.marked = selectedTab == .generator
    }
}

// MARK: Make constraints
private extension TabView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.topAnchor.constraint(equalTo: topAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
        
        NSLayoutConstraint.activate([
            drawsItem.leadingAnchor.constraint(equalTo: leadingAnchor),
            drawsItem.bottomAnchor.constraint(equalTo: bottomAnchor),
            drawsItem.topAnchor.constraint(equalTo: divider.bottomAnchor),
            drawsItem.widthAnchor.constraint(equalTo: generatorItem.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            generatorItem.leadingAnchor.constraint(equalTo: drawsItem.trailingAnchor),
            generatorItem.bottomAnchor.constraint(equalTo: bottomAnchor),
            generatorItem.topAnchor.constraint(equalTo: divider.bottomAnchor),
            generatorItem.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension TabView {
    func makeDivider() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.main400
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeItem(code: String) -> TabItemView {
        let view = TabItemView(code: code)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
