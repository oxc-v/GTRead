//
//  GTAccountManagerImgTableView.swift
//  GTRead
//
//  Created by Dev on 2021/11/28.
//

import Foundation
import UIKit

class GTAccountManagerImgTableViewCell: UITableViewCell {
    
    var imgView: UIImageView!
    var nameLabel: UILabel!
    var profileLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 25
        imgView.clipsToBounds = true
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.height.width.equalTo(50)
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }

        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 19)
        nameLabel.textAlignment = .left
        self.contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.bottom.equalTo(self.contentView.snp.centerY).offset(-2)
        }

        profileLabel = UILabel()
        profileLabel.font = UIFont.systemFont(ofSize: 14)
        profileLabel.textColor = UIColor(hexString: "#b4b4b4")
        profileLabel.textAlignment = .left
        self.contentView.addSubview(profileLabel)
        profileLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.width.lessThanOrEqualTo(100)
            make.top.equalTo(self.contentView.snp.centerY).offset(2)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
