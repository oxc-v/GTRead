//
//  GTShadowView.swift
//  GTRead
//
//  Created by Dev on 2021/12/25.
//

import Foundation
import UIKit

class GTShadowView: UIView {
    
    private var opacity: Float

    init(opacity: Float = 0.3){
        self.opacity = opacity
        
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.setupShadow()
    }
    
    private func setupShadow() {
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowOpacity = self.opacity
        layer.shadowRadius = 5
        layer.shadowPath = shadowPath.cgPath
    }
}
