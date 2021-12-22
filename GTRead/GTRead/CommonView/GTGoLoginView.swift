//
//  GTGoLoginAndRegisterView.swift
//  GTRead
//
//  Created by Dev on 2021/11/11.
//

import Foundation
import UIKit

class GTGoLoginView: UIView {
    
    private var imageView: UIImageView!
    private var button: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "login_unavailable")
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.height.width.equalTo(250)
        }
        
        button = UIButton()
        button.setTitle("登录账号", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.layer.cornerRadius = 25
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 0.0, height: -3.0)
        button.layer.shadowOpacity = 0.1
        button.addTarget(self, action: #selector(buttonDidClicked(sender:)), for: .touchUpInside)
        button.backgroundColor = .black
        button.isUserInteractionEnabled = true
        self.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(190)
            make.height.equalTo(50)
            make.top.equalTo(imageView.snp.bottom).offset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // button clicked
    @objc private func buttonDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.1, completion: {_ in
            NotificationCenter.default.post(name: .GTOpenLoginView, object: self)
        })
    }
}
