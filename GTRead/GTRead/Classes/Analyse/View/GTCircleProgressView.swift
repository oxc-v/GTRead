//
//  GTCircleProgressView.swift
//  GTRead
//
//  Created by Dev on 2021/11/8.
//

import Foundation
import UIKit

class GTCircleProgressView: UIView {
    
    let circleLayer = CAShapeLayer()
    let progressLayer = CAShapeLayer()
    let gradientLayer = CAGradientLayer()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        circleLayer.frame = self.bounds
        self.layer.addSublayer(circleLayer)
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor(hexString: "#f2f2f7").cgColor
        circleLayer.lineWidth = 10
        circleLayer.lineCap = .round

        let path = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height), radius: frame.size.width / 2.0, startAngle: .pi, endAngle: .pi * 2, clockwise: true)
                                
        circleLayer.path = path.cgPath
        
        progressLayer.frame = self.bounds
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor(hexString: "#199dd7").cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 10
        progressLayer.path = path.cgPath
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        
        self.layer.addSublayer(progressLayer)
    }
    
    // 设置进度
    func setProgress(_ progress: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeIn))
        CATransaction.setAnimationDuration(1.0)
        progressLayer.strokeEnd = progress
        CATransaction.commit()
    }
}
