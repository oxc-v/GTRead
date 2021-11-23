//
//  GTBookShelfSearchViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/2.
//

import UIKit

class GTBookSearchResultsViewCell: UITableViewCell {
    
    var imgView: UIImageView!
    var titleLabel: UILabel!
    var detailLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.accessoryType = .none
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 10
        imgView.clipsToBounds = true
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.height.equalTo(120)
            make.width.equalTo(100)
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byTruncatingMiddle
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.width.lessThanOrEqualTo(300)
            make.left.equalTo(imgView.snp.right).offset(16)
            make.centerY.equalToSuperview().offset(-15)
        }
        
        detailLabel = UILabel()
        detailLabel.textColor = UIColor(hexString: "#b4b4b4")
        detailLabel.font = UIFont.systemFont(ofSize: 13)
        detailLabel.textAlignment = .left
        detailLabel.lineBreakMode = .byTruncatingMiddle
        self.contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.width.lessThanOrEqualTo(300)
            make.left.equalTo(imgView.snp.right).offset(16)
            make.centerY.equalToSuperview().offset(15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
