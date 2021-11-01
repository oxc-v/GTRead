//
//  GTBookCollectionCell.swift
//  GTRead
//
//  Created by YangJie on 2021/3/22.
//

import UIKit
import SDWebImage

class GTBookCollectionCell: UICollectionViewCell {
    
    lazy var selectedStatu: Bool = false
    
    lazy var pdfImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.shadowRadius = 5
        imageView.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        imageView.layer.shadowOpacity = 0.1
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingMiddle
        label.font = UIFont.systemFont(ofSize: 15)
        return label
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

        self.contentView.addSubview(pdfImageView)
        self.contentView.addSubview(circleImageView)
        self.contentView.addSubview(rightImageView)
        self.contentView.addSubview(titleLabel)
        
        pdfImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.9)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(pdfImageView.snp.bottom).offset(10)
            make.width.equalTo(pdfImageView.snp.width)
            make.centerX.equalToSuperview()
        }
        circleImageView.snp.makeConstraints { (make) in
            make.right.equalTo(pdfImageView.snp.right).offset(15)
            make.top.equalTo(pdfImageView.snp.top).offset(-15)
            make.width.height.equalTo(30)
        }
        rightImageView.snp.makeConstraints { (make) in
            make.right.equalTo(pdfImageView.snp.right).offset(15)
            make.top.equalTo(pdfImageView.snp.top).offset(-15)
            make.width.height.equalTo(30)
        }
        
        
        
        let longGress = UILongPressGestureRecognizer()
        longGress.addTarget(self, action: #selector(StartEdit))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateData(imageURL: String, title: String) {
        pdfImageView.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "book_placeholder"))
        titleLabel.text = title
    }
    
    // 开启编辑模式
    @objc func StartEdit() {
        selectedStatu = false
        circleImageView.zoomInWithEasing()
        circleImageView.isHidden = false
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
