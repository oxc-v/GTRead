//
//  GTPDFReplyCommentCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2022/1/6.
//

import Foundation
import UIKit

class GTPDFReplyCommentCollectionViewCell: UICollectionViewCell {
    
    private var titleLab: UILabel!
    private var separatorView: UIView!
    private var separatorView_1: UIView!
    
    var timeBtn: UIButton!
    var likeBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    private func setupView() {
        
        titleLab = UILabel()
        titleLab.text = "全部回复"
        titleLab.textAlignment = .left
        titleLab.font = UIFont.boldSystemFont(ofSize: 18)
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(30)
        }
        
        timeBtn = UIButton()
        timeBtn.setTitle("时间", for: .normal)
        timeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        timeBtn.setTitleColor(.lightGray, for: .normal)
        timeBtn.setTitleColor(.black, for: .disabled)
        self.contentView.addSubview(timeBtn)
        timeBtn.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.centerY.equalTo(titleLab.snp.centerY)
        }
        
        separatorView = UIView()
        separatorView.backgroundColor = UIColor(hexString: "#cacacc")
        self.contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.width.equalTo(0.5)
            make.height.equalTo(timeBtn.snp.height).multipliedBy(0.5)
            make.right.equalTo(timeBtn.snp.left).offset(-5)
            make.centerY.equalTo(timeBtn.snp.centerY)
        }
        
        likeBtn = UIButton()
        likeBtn.setTitle("热门", for: .normal)
        likeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        likeBtn.setTitleColor(.lightGray, for: .normal)
        likeBtn.setTitleColor(.black, for: .disabled)
        self.contentView.addSubview(likeBtn)
        likeBtn.snp.makeConstraints { make in
            make.right.equalTo(separatorView.snp.left).offset(-5)
            make.centerY.equalTo(titleLab.snp.centerY)
        }
        
        separatorView_1 = UIView()
        separatorView_1.backgroundColor = UIColor(hexString: "#cacacc")
        self.contentView.addSubview(separatorView_1)
        separatorView_1.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.width.equalToSuperview()
            make.top.equalTo(titleLab.snp.bottom).offset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 70)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
