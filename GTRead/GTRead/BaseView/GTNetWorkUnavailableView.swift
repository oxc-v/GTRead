//
//  GTNetWorkUnavailableView.swift
//  GTRead
//
//  Created by Dev on 2021/11/11.
//

import Foundation
import UIKit

class GTNetWorkUnavailableView: UIView {
    
    private var imageView: UIImageView!
    private var button: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "network_unavailable")
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.height.width.equalTo(250)
        }
        
        button = UIButton()
        button.setTitle("重新加载", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.layer.cornerRadius = 25
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 0.0, height: -3.0)
        button.layer.shadowOpacity = 0.1
        button.addTarget(self, action: #selector(buttonDidClicked), for: .touchUpInside)
        button.backgroundColor = .black
        self.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(130)
            make.height.equalTo(50)
            make.top.equalTo(imageView.snp.bottom).offset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 重新加载网络
    @objc private func buttonDidClicked() {
        NotificationCenter.default.post(name: .GTLoadNetwork, object: self)
    }
}
