//
//  NotchedBackgroundView.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 6/12/24.
//

import UIKit

class NotchedBackgroundView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Define the path for the notch
        let notchPath = UIBezierPath()
        
        // Define the radius and center points for the notches
        let notchRadius: CGFloat = 15.scale
        let leftNotchCenter = CGPoint(x: 0, y: rect.midY)
        let rightNotchCenter = CGPoint(x: rect.width, y: rect.midY)
        
        // Draw the left notch
        notchPath.addArc(withCenter: leftNotchCenter, radius: notchRadius, startAngle: CGFloat.pi / 2, endAngle: -CGFloat.pi / 2, clockwise: false)
        
        // Draw the right notch
        notchPath.addArc(withCenter: rightNotchCenter, radius: notchRadius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi / 2, clockwise: false)
        
        // Draw the top and bottom edges
        notchPath.move(to: CGPoint(x: 0, y: 0))
        notchPath.addLine(to: CGPoint(x: rect.width, y: 0))
        notchPath.move(to: CGPoint(x: 0, y: rect.height))
        notchPath.addLine(to: CGPoint(x: rect.width, y: rect.height))
        
        // Set the notch color
        UIColor.white.setFill()
        UIColor.lightGray.setStroke()
        
        // Fill and stroke the path
        notchPath.fill()
        notchPath.stroke()
    }
}

