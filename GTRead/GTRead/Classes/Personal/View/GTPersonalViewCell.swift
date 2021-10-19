//
//  GTPersonalViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/10/18.
//

import UIKit

class GTPersonalViewCell: UITableViewCell {
    
    var headImgView: UIImageView!
    var nicknameLabel: UILabel!
    var detailTxtLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        headImgView = UIImageView()
        headImgView.contentMode = .scaleAspectFill
        headImgView.layer.masksToBounds = true
        headImgView.layer.cornerRadius = headImgView.frame.width / 2
        self.contentView.addSubview(headImgView)
        headImgView.snp.makeConstraints { (make) in
            make.height.width.equalTo(70)
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        
        nicknameLabel = UILabel()
        nicknameLabel.font = nicknameLabel.font.withSize(23)
        nicknameLabel.textAlignment = .left
        nicknameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.contentView.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headImgView.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
        
        detailTxtLabel = UILabel()
        detailTxtLabel.font = detailTxtLabel.font.withSize(12)
        detailTxtLabel.textAlignment = .left
        detailTxtLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.contentView.addSubview(detailTxtLabel)
        detailTxtLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headImgView.snp.right).offset(16)
            make.top.equalTo(nicknameLabel.snp.bottom).offset(5)
        }
        
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set(newFrame) {
            var frame = newFrame
            let newWidth = UIScreen.main.bounds.width - 16 * 2
            let space = (frame.width - newWidth) / 2
            frame.size.width = newWidth
            frame.origin.x += space
            super.frame = frame
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
