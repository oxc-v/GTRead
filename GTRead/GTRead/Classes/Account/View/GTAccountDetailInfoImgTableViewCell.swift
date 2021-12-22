//
//  GTAccountDetailInfoImgTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/29.
//

import Foundation
import UIKit

class GTAccountDetailInfoImgTableViewCell: UITableViewCell {
    
    var imgView: UIImageView!
    var titleLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.masksToBounds = false
        imgView.layer.cornerRadius = 15
        imgView.clipsToBounds = true
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.height.width.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textAlignment = .left
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
