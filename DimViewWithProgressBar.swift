//
//  DimViewWithProgressBar.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 9/5/24.
//

import UIKit

class DimViewWithProgressBar: UIView {
    
    private let progressImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Scan.ProgressBg"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Explicitly set the anchor point to center (default is (0.5, 0.5))
        imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return imageView
    }()
    
    private let progressMessages = [
        "Analyzing the ticket...",
        "Your lucky moment is loading...",
        "Hold tight, luck is on its way...",
        "Drawing your luck..."
    ]
    
    private var messageIndex = 0
    private var timer: Timer?
    
    let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "Analyzing the ticket..."
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16.scale, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(Appearance.mono200, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.scale, weight: .medium)
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
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetMessageIndex() {
        messageIndex = 0
        progressLabel.text = progressMessages[messageIndex]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupAnimations()
        // startTextRotation() // Uncomment if needed
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupAnimations()
        // startTextRotation() // Uncomment if needed
    }
    
    private func setupView() {
        // Add the dim view
        addSubview(dimView)
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: self.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        // Add the progress image view directly to the main view
        addSubview(progressImageView)
        NSLayoutConstraint.activate([
            progressImageView.widthAnchor.constraint(equalToConstant: 100.scale),
            progressImageView.heightAnchor.constraint(equalToConstant: 100.scale),
            progressImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            progressImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -34.scale)
        ])
        
        // Add the progress label
        addSubview(progressLabel)
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 30.scale)
        ])
        
        // Add the action button
        addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 103.scale),
            actionButton.widthAnchor.constraint(equalToConstant: 200.scale),
            actionButton.heightAnchor.constraint(equalToConstant: 44.scale)
        ])
    }
    
    private func setupAnimations() {
        // Apply a continuous rotation animation to the progress image view
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2 * Double.pi
        rotationAnimation.duration = 0.5
        rotationAnimation.repeatCount = .infinity
        progressImageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func startTextRotation() {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateText), userInfo: nil, repeats: true)
    }
    
    @objc private func updateText() {
        if messageIndex < progressMessages.count - 1 {
            messageIndex += 1
            progressLabel.text = progressMessages[messageIndex]
        } else {
            progressLabel.text = progressMessages[messageIndex]
            timer?.invalidate()
        }
    }
    
    func updateProgressText(_ text: String) {
        progressLabel.text = text
    }
    
    func stopLoading() {
        progressImageView.layer.removeAllAnimations()
        timer?.invalidate()
        if let pvc = parentViewController as? EditScanViewController {
            pvc.continueButton.isUserInteractionEnabled = true
        }
        removeFromSuperview()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}
