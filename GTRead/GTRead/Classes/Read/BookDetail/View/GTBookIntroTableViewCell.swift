//
//  GTBookIntroViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/24.
//

import Foundation
import UIKit
import SnapKit
import ExpandableLabel

class GTBookIntroTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel!
    var detailLabel: ExpandableLabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.text = "来自出版社的简介"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(GTViewMargin - 10)
            make.left.equalTo(GTViewMargin)
            make.height.equalTo(20)
        }
        
        detailLabel = ExpandableLabel()
        detailLabel.collapsedAttributedLink = NSAttributedString(string: "更多", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)])
        detailLabel.expandedAttributedLink = NSAttributedString(string: "收起", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)])
        detailLabel.ellipsis = NSAttributedString(string: "...")
        detailLabel.textAlignment = .left
        detailLabel.numberOfLines = 8
        detailLabel.shouldCollapse = true
        detailLabel.font = UIFont.systemFont(ofSize: 16)
        self.contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.equalTo(GTViewMargin)
            make.right.equalTo(-GTViewMargin)
            make.bottom.equalToSuperview().offset(-GTViewMargin + 10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
