//
//  GTBookCollectionCell.swift
//  GTRead
//
//  Created by YangJie on 2021/3/22.
//

import UIKit
import SDWebImage

class GTShelfCollectionViewCell: UICollectionViewCell {
    
    lazy var selectedStatu: Bool = false
    
    lazy var gtImageView: GTShadowImageView = {
        let imageView = GTShadowImageView(opacity: 0.25)
        imageView.imgView.contentMode = .scaleAspectFill
        imageView.imgView.layer.cornerRadius = 5
        imageView.imgView.clipsToBounds = true
        return imageView
    }()
    
    lazy var pdfImageView: UIImageView = {
        return gtImageView.imgView
    }()
    
    lazy var circleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "shelf_circle")
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "shelf_right")
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)

        self.contentView.addSubview(gtImageView)
        self.contentView.addSubview(circleImageView)
        self.contentView.addSubview(rightImageView)

        gtImageView.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview()
        }
        circleImageView.snp.makeConstraints { (make) in
            make.right.equalTo(gtImageView.snp.right)
            make.top.equalTo(gtImageView.snp.top)
            make.width.height.equalTo(30)
        }
        rightImageView.snp.makeConstraints { (make) in
            make.right.equalTo(gtImageView.snp.right)
            make.top.equalTo(gtImageView.snp.top)
            make.width.height.equalTo(30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateData(imgURL: String) {
        self.pdfImageView.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage(named: "book_placeholder"))
    }
    
    // 开启编辑模式
    func startEdit() {
        selectedStatu = false
        circleImageView.isHidden = false
        circleImageView.zoomInWithEasing()
    }

    // 关闭编辑模式
    func endEdit() {
        circleImageView.zoomOutWithEasing()
        rightImageView.zoomOutWithEasing()
        circleImageView.isHidden = true
        rightImageView.isHidden = true
    }

    // 选中与非选中
    func hiddenRightImageView(hidden: Bool) {
        selectedStatu = !hidden
        rightImageView.isHidden = hidden

        if selectedStatu == true {
            circleImageView.zoomOutWithEasing()
            rightImageView.zoomInWithEasing()
        } else {
            circleImageView.zoomInWithEasing()
            rightImageView.zoomOutWithEasing()
        }
    }
}
