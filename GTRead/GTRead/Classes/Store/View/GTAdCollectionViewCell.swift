//
//  GTAdCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/23.
//

import Foundation
import UIKit

class GTAdCollectionViewCell: UICollectionViewCell {
    
    private var baseView: GTShadowView!
    
    var titleLabel: UILabel!
    var imgView: UIImageView!
    var bgView: GTShadowView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.width.top.equalToSuperview()
            make.height.equalTo(55)
        }
        
        bgView = GTShadowView(opacity: 0.1)
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 15
        self.contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.width.equalToSuperview()
        }
        
        baseView = GTShadowView(opacity: 0.15)
        baseView.backgroundColor = .clear
        self.bgView.addSubview(baseView)
        baseView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalToSuperview().multipliedBy(0.8)
        }
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 5
        imgView.clipsToBounds = true
        self.baseView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.center.equalTo(self.bgView.snp.center)
            make.height.width.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
