//
//  GTSlideCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/12.
//

import Foundation
import UIKit

class GTSearchStoreCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var titleBtn: UIButton!
    

    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        self.contentView.backgroundColor = UIColor(hexString: "#f4f5fb")
        self.contentView.layer.cornerRadius = 16
        
        imageView = UIImageView()
        imageView.isHidden = true
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "hot_search")
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(5)
            make.width.height.equalTo(20)
        }
        
        titleBtn = UIButton()
        titleBtn.setTitleColor(.black, for: .normal)
        titleBtn.titleLabel?.textAlignment = .center
        titleBtn.titleLabel?.lineBreakMode = .byTruncatingMiddle
        titleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        self.contentView.addSubview(titleBtn)
        titleBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualTo(searStoreCollectViewCellBtnMaxWidth)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
