//
//  GTThumbnailCollectionViewCell.swift
//  GTRead
//
//  Created by YangJie on 2021/4/21.
//

import UIKit

class GTThumbnailCollectionViewCell: UICollectionViewCell {
    private var imageView: GTShadowImageView!
    var pageLab: UILabel!
    var image: UIImage? = nil {
        didSet {
            imageView.imgView.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = GTShadowImageView(opacity: 0.2)
        imageView.imgView.layer.cornerRadius = 10
        imageView.imgView.clipsToBounds = true
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        pageLab = UILabel()
        pageLab.textAlignment = .center
        pageLab.textColor = UIColor(hexString: "#4b4b4b")
        pageLab.font = UIFont.boldSystemFont(ofSize: 15)
        self.contentView.addSubview(pageLab)
        pageLab.snp.makeConstraints { (make) in
            make.left.right.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
