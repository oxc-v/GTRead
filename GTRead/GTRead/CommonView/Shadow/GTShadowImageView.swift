//
//  GTShadowImageView.swift
//  GTRead
//
//  Created by Dev on 2021/12/25.
//

import Foundation
import UIKit

class GTShadowImageView: UIView {
    
    private var opacity: Float
    private var baseView: GTShadowView!
    var imgView: UIImageView!

    init(opacity: Float = 0.3){
        self.opacity = opacity
        
        super.init(frame: CGRect.zero)
        
        self.setupShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupShadow() {
        baseView = GTShadowView(opacity: self.opacity)
        self.addSubview(baseView)
        baseView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        
        imgView = UIImageView()
        baseView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
    }
}
