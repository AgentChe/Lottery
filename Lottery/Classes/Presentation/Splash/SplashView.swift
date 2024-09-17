//
//  SplashView.swift
//  Soccer
//
//  Created by Андрей Чернышев on 05.07.2022.
//

import UIKit

final class SplashView: UIView {
    lazy var imageView = makeImageView()
    lazy var progressBarView = makeProgressBarView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension SplashView {
    func initialize() {
        backgroundColor = Appearance.main400
    }
}

// MARK: Make constraints
private extension SplashView {
    func makeConstraints() {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let windowWidth = window?.bounds.width ?? UIScreen.main.bounds.width
        let windowHeight = window?.bounds.height ?? UIScreen.main.bounds.height
     
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: windowWidth),
            imageView.heightAnchor.constraint(equalToConstant: windowHeight),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            progressBarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressBarView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -70.scale),
            progressBarView.widthAnchor.constraint(equalToConstant: 50.scale), // Set size for progress bar view
            progressBarView.heightAnchor.constraint(equalToConstant: 50.scale)
        ])
        
     
    }
}

// MARK: Lazy initialization
private extension SplashView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: "Splash.Image")
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeProgressBarView() -> SplashProgressBar {
        let view = SplashProgressBar(frame: CGRect(x: 0, y: 0, width: 44.scale, height: 44.scale))
     
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLoadingLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200.withAlphaComponent(0.6))
            .font(Fonts.Inter.medium(size: 17.scale))
            .letterSpacing(-0.44.scale)
            .lineHeight(20.scale)
        
        let view = UILabel()
        view.attributedText = "Splash.Loading".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func updateProgressText(_ text: String) {
        progressBarView.updateProgressText(text)
    }
}
