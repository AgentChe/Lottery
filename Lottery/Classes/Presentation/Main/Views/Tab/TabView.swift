//
//  TabView.swift
//  Lottery
//
//  Created by Андрей Чернышев on 23.05.2024.
//

import UIKit

final class TabView: UIView {
    enum Tab {
        case draws, luckyNumbers, myTickets
    }
    
    lazy var divider = makeDivider()
    lazy var drawsItem = makeItem(code: "Main.Draws")
    lazy var luckyNumbersItem = makeItem(code: "Main.LuckyNumbers")
    lazy var myTicketsItem = makeItem(code: "Main.MyTickets")
    
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
        luckyNumbersItem.marked = selectedTab == .luckyNumbers
        myTicketsItem.marked = selectedTab == .myTickets
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
            drawsItem.widthAnchor.constraint(equalTo: luckyNumbersItem.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            luckyNumbersItem.leadingAnchor.constraint(equalTo: drawsItem.trailingAnchor),
            luckyNumbersItem.bottomAnchor.constraint(equalTo: bottomAnchor),
            luckyNumbersItem.topAnchor.constraint(equalTo: divider.bottomAnchor),
            luckyNumbersItem.widthAnchor.constraint(equalTo: myTicketsItem.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            myTicketsItem.leadingAnchor.constraint(equalTo: luckyNumbersItem.trailingAnchor),
            myTicketsItem.bottomAnchor.constraint(equalTo: bottomAnchor),
            myTicketsItem.topAnchor.constraint(equalTo: divider.bottomAnchor),
            myTicketsItem.trailingAnchor.constraint(equalTo: trailingAnchor)
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
