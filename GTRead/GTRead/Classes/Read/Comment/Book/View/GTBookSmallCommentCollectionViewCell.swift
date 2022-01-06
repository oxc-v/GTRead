//
//  GTBookCommentCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/30.
//

import Foundation
import UIKit
import Cosmos

class GTBookSmallCommentCollectionViewCell: UICollectionViewCell {
    
    var commentTitleLabel: UILabel!
    var commentContentLabel: UILabel!
    var nicknameLabel: UILabel!
    var timeLabel: UILabel!
    var imgView: UIImageView!
    var starView: CosmosView!
    
    private let leftMargin = 10
    private let topMargin = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = UIColor(hexString: "#f2f1f6")
        self.contentView.layer.cornerRadius = 15
        
        commentTitleLabel = UILabel()
        commentTitleLabel.text = "评论标题一朝一暮的光阴，如涓涓流水，去而不返。一聚一散的无常，如花开花谢如花开花谢，来去有时。 过往之事不可追，未来之事不可猜。 余生，便做一个豁达之人，让眼底有光，无惧黑暗。"
        commentTitleLabel.textAlignment = .left
        commentTitleLabel.numberOfLines = 1
        commentTitleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        self.contentView.addSubview(commentTitleLabel)
        commentTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(topMargin)
            make.left.equalTo(leftMargin)
            make.right.equalTo(-leftMargin)
        }
        
        commentContentLabel = UILabel()
        commentContentLabel.text = "一朝一暮的光阴，如涓涓流水，去而不返。一聚一散的无常，如花开花谢，来去有时。 过往之事不可追，未来之事不可猜。 余生，便做一个豁达之人，让眼底有光，无惧黑暗。让心中有爱，不失温度。让灵魂有家，随处可栖。 有人说：眼睛，是心灵的窗户。 若一个人..."
        commentContentLabel.textAlignment = .left
        commentContentLabel.numberOfLines = 3
        commentContentLabel.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(commentContentLabel)
        commentContentLabel.snp.makeConstraints { make in
            make.top.equalTo(commentTitleLabel.snp.bottom).offset(topMargin)
            make.left.equalTo(leftMargin)
            make.right.equalTo(-leftMargin)
        }
        
        starView = CosmosView()
        starView.settings.fillMode = .precise
        starView.settings.updateOnTouch = false
        starView.settings.starSize = 12
        starView.settings.starMargin = 3
        starView.settings.filledImage = UIImage(named: "star_fill")
        starView.settings.emptyImage = UIImage(named: "star_empty")
        self.contentView.addSubview(starView)
        starView.snp.makeConstraints { make in
            make.top.equalTo(commentContentLabel.snp.bottom).offset(topMargin)
            make.left.equalTo(leftMargin)
            make.bottom.equalTo(-topMargin)
        }
        
        timeLabel = UILabel()
        timeLabel.text = "2022-01-02 16:00"
        timeLabel.textAlignment = .left
        timeLabel.numberOfLines = 0
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(commentContentLabel.snp.bottom).offset(topMargin)
            make.left.equalTo(starView.snp.right).offset(5)
            make.bottom.equalTo(-topMargin)
        }
        
        nicknameLabel = UILabel()
        nicknameLabel.text = "欧秀成"
        nicknameLabel.textAlignment = .left
        nicknameLabel.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(commentContentLabel.snp.bottom).offset(topMargin)
            make.left.equalTo(timeLabel.snp.right).offset(5)
            make.bottom.equalTo(-topMargin)
            make.width.lessThanOrEqualTo(50)
        }
        
        imgView = UIImageView()
        imgView.image = UIImage(named: "head_men")
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 9
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.height.width.equalTo(18)
            make.left.equalTo(nicknameLabel.snp.right).offset(5)
            make.centerY.equalTo(nicknameLabel.snp.centerY)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
