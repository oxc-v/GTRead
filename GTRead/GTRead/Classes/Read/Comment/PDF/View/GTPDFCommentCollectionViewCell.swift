//
//  GTPDFCommentCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2022/1/6.
//

import Foundation
import UIKit

class GTPDFCommentCollectionViewCell: UICollectionViewCell {
    
    var commentTitleLabel: UILabel!
    var commentContentLabel: UILabel!
    var nicknameLabel: UILabel!
    var timeLabel: UILabel!
    var imgView: UIImageView!
    var readMoreBtn: UIButton!
    var yesCommentBtn: UIButton!
    var noCommentBtn: UIButton!
    
    private let leftMargin = 20
    private let topMargin = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = UIColor(hexString: "#f2f1f6")
        self.contentView.layer.cornerRadius = 15
        
        commentTitleLabel = UILabel()
        commentTitleLabel.textAlignment = .left
        commentTitleLabel.numberOfLines = 0
        commentTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.contentView.addSubview(commentTitleLabel)
        commentTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(topMargin)
            make.left.equalTo(leftMargin)
            make.right.equalTo(-leftMargin)
        }
        
        commentContentLabel = UILabel()
        commentContentLabel.textAlignment = .left
        commentContentLabel.numberOfLines = 0
        commentContentLabel.font = UIFont.systemFont(ofSize: 15)
        self.contentView.addSubview(commentContentLabel)
        commentContentLabel.snp.makeConstraints { make in
            make.top.equalTo(commentTitleLabel.snp.bottom).offset(topMargin)
            make.left.equalTo(leftMargin)
            make.right.equalTo(-leftMargin)
        }
        
        timeLabel = UILabel()
        timeLabel.textAlignment = .left
        timeLabel.font = UIFont.systemFont(ofSize: 15)
        self.contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(commentContentLabel.snp.bottom).offset(topMargin)
            make.left.equalTo(leftMargin)
        }
        
        nicknameLabel = UILabel()
        nicknameLabel.textAlignment = .left
        nicknameLabel.font = UIFont.systemFont(ofSize: 15)
        self.contentView.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(commentContentLabel.snp.bottom).offset(topMargin)
            make.left.equalTo(timeLabel.snp.right).offset(5)
            make.width.lessThanOrEqualTo(50)
        }
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 10
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.height.width.equalTo(20)
            make.left.equalTo(nicknameLabel.snp.right).offset(5)
            make.centerY.equalTo(nicknameLabel.snp.centerY)
        }
        
        readMoreBtn = UIButton()
        readMoreBtn.isEnabled = false
        readMoreBtn.setTitleColor(.systemBlue, for: .normal)
        readMoreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        readMoreBtn.setImage(UIImage(named: "right_>_blue"), for: .normal)
        readMoreBtn.semanticContentAttribute = .forceRightToLeft
        readMoreBtn.contentHorizontalAlignment = .left
        self.contentView.addSubview(readMoreBtn)
        readMoreBtn.snp.makeConstraints { make in
            make.left.equalTo(leftMargin)
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
            make.bottom.equalTo(-topMargin)
        }
        
        noCommentBtn = UIButton()
        noCommentBtn.setImage(UIImage(named: "comment_no"), for: .normal)
        noCommentBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        noCommentBtn.setTitleColor(UIColor(hexString: "#b4b4b4"), for: .normal)
        noCommentBtn.imageView?.contentMode = .scaleAspectFit
        self.contentView.addSubview(noCommentBtn)
        noCommentBtn.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.right.equalTo(-leftMargin)
            make.centerY.equalTo(imgView.snp.centerY)
        }
        
        yesCommentBtn = UIButton()
        yesCommentBtn.setImage(UIImage(named: "comment_yes"), for: .normal)
        yesCommentBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        yesCommentBtn.setTitleColor(.systemBlue, for: .normal)
        yesCommentBtn.imageView?.contentMode = .scaleAspectFit
        self.contentView.addSubview(yesCommentBtn)
        yesCommentBtn.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.right.equalTo(-leftMargin)
            make.centerY.equalTo(imgView.snp.centerY)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        yesCommentBtn.zoomIn()
        noCommentBtn.zoomIn()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
