//
//  GTAccountManagerTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/27.
//

import Foundation
import UIKit

class GTAccountManagerCommonTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel!
    var detailLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .black
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        detailLabel = UILabel()
        detailLabel.font = UIFont.boldSystemFont(ofSize: 17)
        detailLabel.textColor = UIColor(hexString: "#b4b4b4")
        detailLabel.textAlignment = .center
        self.contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        detailLabel.text = ""
    }
}
