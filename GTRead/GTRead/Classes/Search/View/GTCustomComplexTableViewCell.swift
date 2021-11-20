//
//  GTCustomTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/16.
//

import Foundation
import UIKit

class GTCustomComplexTableViewCell: UITableViewCell {

    var imgView: UIImageView!
    var titleLabel: UILabel!
    var detailLabel: UILabel!
    var baseView: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        baseView = UIView()
        baseView.backgroundColor = .clear
        baseView.addShadow(offset: CGSize(width: 3, height: 3), color: UIColor.black, radius: 5, opacity: 0.3)
        self.contentView.addSubview(baseView)
        baseView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(20)
            make.width.equalTo(70)
            make.height.equalTo(100)
        }
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.masksToBounds = true
        imgView.layer.cornerRadius = 10
        baseView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.contentView.snp.left)
            make.width.equalTo(70)
            make.height.equalTo(95)
        }
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.lineBreakMode = .byTruncatingMiddle
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-15)
            make.left.equalTo(imgView.snp.right).offset(16)
            make.width.lessThanOrEqualTo(300)
        }
        
        
        detailLabel = UILabel()
        detailLabel.textAlignment = .left
        detailLabel.textColor = UIColor(hexString: "#b4b4b4")
        detailLabel.font = UIFont.boldSystemFont(ofSize: 13)
        detailLabel.lineBreakMode = .byTruncatingMiddle
        self.contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(15)
            make.left.equalTo(imgView.snp.right).offset(16)
            make.width.lessThanOrEqualTo(300)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.titleLabel.text = ""
        self.detailLabel.text = ""
        self.imgView.image = UIImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
