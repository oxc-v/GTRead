//
//  GTLoadingStrokeColorAnimation.swift
//  GTRead
//
//  Created by Dev on 2021/11/22.
//

import Foundation
import UIKit

class GTLoadingStrokeColorAnimation: CAKeyframeAnimation {
    
    override init() {
        super.init()
    }
    
    init(colors: [CGColor], duration: Double) {
        
        super.init()
        
        self.keyPath = "strokeColor"
        self.values = colors
        self.duration = duration
        self.repeatCount = .greatestFiniteMagnitude
        self.timingFunction = .init(name: .easeInEaseOut)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
