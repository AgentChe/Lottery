//
//  DimViewWithProgressBar.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 9/5/24.
//

import UIKit

class DimViewWithProgressBar: UIView {
    
    private var backgroundLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    
    private var isCircleRotating = true
    private var animateStart = false
    private var animateEnd = true
    
     let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
     let dimView: UIView = {
        let view = UIView()
        view.backgroundColor =  UIColor.black.withAlphaComponent(0.5) // Dimmed background
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Create a button below the progress label
     let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor( Appearance.mono200, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = Appearance.mono100
        button.layer.cornerRadius = 20.scale
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    @objc func cancel() {
        
        if let pvc = parentViewController as? EditScanViewController {
            pvc.weDo = false
            pvc.touchDown.isEnabled = true
            pvc.continueButton.isUserInteractionEnabled = false
            
            let session = pvc.scanScratchManager.session
            DispatchQueue.main.async {
                session.getAllTasks { tasks in
                    tasks.forEach { $0.cancel() }
                }
            }
        }
        stopLoading()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupAnimations()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupAnimations()
    }
    
    private func setupView() {
        // Add the dim view
        addSubview(dimView)
        
        // Set constraints for dim view
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: self.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        // Set up the background circular layer
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 75, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        backgroundLayer.lineWidth = 6.scale
        backgroundLayer.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        layer.addSublayer(backgroundLayer)
        
        // Set up the animated progress circular layer
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = Appearance.mono100.cgColor
        progressLayer.lineWidth = 6.scale
        progressLayer.strokeEnd = 0
        progressLayer.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        layer.addSublayer(progressLayer)
        
        // Add the progress label
        addSubview(progressLabel)
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 100) // Beneath the circle
        ])
        
        // Add the action button
        addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 30.scale),
            actionButton.widthAnchor.constraint(equalToConstant: 200.scale),
            actionButton.heightAnchor.constraint(equalToConstant: 44.scale)
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
        if let pvc = parentViewController as? EditScanViewController {
            pvc.continueButton.isUserInteractionEnabled = true
        }
        removeFromSuperview()
    }
}
