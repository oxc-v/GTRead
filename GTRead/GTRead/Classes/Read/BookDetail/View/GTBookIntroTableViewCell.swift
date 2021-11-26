//
//  GTBookIntroViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/24.
//

import Foundation
import UIKit
import SnapKit

class GTBookIntroTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel!
    var detailLabel: UILabel!
    var isExpanded = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.text = "来自出版社的简介"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(GTViewMargin - 10)
            make.left.equalToSuperview()
        }
        
        detailLabel = UILabel()
        detailLabel.textAlignment = .left
        detailLabel.numberOfLines = 5
        detailLabel.font = UIFont.systemFont(ofSize: 16)
        self.contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-GTViewMargin + 10)
        }
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set(newFrame) {
            var frame = newFrame
            let newWidth = 704 - GTViewMargin * 2
            let space = (frame.width - newWidth) / 2
            frame.size.width = newWidth
            frame.origin.x += space
            super.frame = frame
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func toggleExpanded() {
        detailLabel.lineBreakMode = .byWordWrapping
        detailLabel.numberOfLines = 0
        isExpanded = true
    }
}
