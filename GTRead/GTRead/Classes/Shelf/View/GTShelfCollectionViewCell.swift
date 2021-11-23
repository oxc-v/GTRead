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
    
    lazy var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.addShadow(offset: CGSize(width: 3, height: 3), color: UIColor.black, radius: 5, opacity: 0.2)
        return view
    }()
    
    lazy var pdfImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
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

        self.contentView.addSubview(baseView)
        baseView.addSubview(pdfImageView)
        self.contentView.addSubview(circleImageView)
        self.contentView.addSubview(rightImageView)
        
        baseView.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.9)
        }
        pdfImageView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalTo(self.contentView.snp.centerX)
        }
        circleImageView.snp.makeConstraints { (make) in
            make.right.equalTo(pdfImageView.snp.right)
            make.top.equalTo(pdfImageView.snp.top)
            make.width.height.equalTo(30)
        }
        rightImageView.snp.makeConstraints { (make) in
            make.right.equalTo(pdfImageView.snp.right)
            make.top.equalTo(pdfImageView.snp.top)
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
