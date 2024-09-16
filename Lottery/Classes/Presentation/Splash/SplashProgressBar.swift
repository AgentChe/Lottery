//
//  SplashProgressBar.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 9/5/24.
//

import UIKit

class SplashProgressBar: UIView {
    
    private var backgroundLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    
    let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.textColor = .white
        label.font = Fonts.Inter.medium(size: 14.scale)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupView()
        setupAnimations()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupAnimations()
    }
    
    private func setupView() {
        // Define the radius to fit the circle inside the view's bounds with some padding
        let radius = (frame.height/2 - 10).scale  // Adjust '10' for desired padding

        // Set up the background circular layer
        let circularPath = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        backgroundLayer.lineWidth = 2.5.scale
        backgroundLayer.position = CGPoint(x: frame.width / 2 + 0.scale, y: frame.height / 2 - 10.scale)
        layer.addSublayer(backgroundLayer)
        
        // Set up the animated progress circular layer
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = Appearance.mono100.cgColor
        progressLayer.lineWidth = 2.5.scale
        progressLayer.strokeEnd = 0.scale
        progressLayer.position = CGPoint(x: frame.width / 2 + 0.scale, y: frame.height / 2 - 10.scale)
        layer.addSublayer(progressLayer)
        
        // Add the progress label
        addSubview(progressLabel)
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: radius + 10.scale) // Adjust '20' for desired spacing beneath the circle
        ])
    }

    private func setupAnimations() {
        // Rotation animation
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2 * Double.pi
        rotationAnimation.duration = 0.5
        rotationAnimation.repeatCount = .infinity
        progressLayer.add(rotationAnimation, forKey: "rotationAnimation")
        
        // Animation to simulate trim (start)
        let startAnimation = CABasicAnimation(keyPath: "strokeStart")
        startAnimation.fromValue = 1 / 3
        startAnimation.toValue = 1 / 9
        startAnimation.duration = 0.5
        startAnimation.autoreverses = true
        startAnimation.repeatCount = .infinity
        startAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.add(startAnimation, forKey: "startAnimation")
        
        // Animation to simulate trim (end)
        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.fromValue = 2 / 5
        endAnimation.toValue = 1
        endAnimation.duration = 0.5
        endAnimation.autoreverses = true
        endAnimation.repeatCount = .infinity
        endAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.add(endAnimation, forKey: "endAnimation")
    }
    
    func updateProgressText(_ text: String) {
        progressLabel.text = text
    }
    
    func stopLoading() {
        progressLayer.removeAllAnimations()
        removeFromSuperview()
    }
}

