//
//  GTCustomPlainTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/17.
//

import Foundation
import UIKit

class GTCustomPlainTableViewCell: UITableViewCell {

    var imgView: UIImageView!
    var titleLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.lineBreakMode = .byTruncatingMiddle
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(imgView.snp.right).offset(16)
            make.width.lessThanOrEqualTo(300)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.titleLabel.text = ""
        self.imgView.image = UIImage()
    }
}
