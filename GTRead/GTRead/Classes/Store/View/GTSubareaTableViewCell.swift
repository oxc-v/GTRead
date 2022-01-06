//
//  GTPartitionTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/26.
//

import Foundation
import UIKit

class GTSubareaTableViewCell: UITableViewCell {
    
    private var separatorView: UIView!
    private var imgView: UIImageView!
    private var btn: UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        separatorView = UIView()
        separatorView.backgroundColor = UIColor(hexString: "#cacacc")
        self.contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.top.equalToSuperview()
            make.left.equalTo(GTViewMargin)
            make.right.equalTo(-GTViewMargin)
        }
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.image = UIImage(named: "partition")
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.bottom.equalTo(-15)
            make.top.equalTo(separatorView.snp.bottom).offset(15)
            make.width.equalTo(imgView.snp.height)
            make.left.equalTo(GTViewMargin)
        }
        
        btn = UIButton()
        btn.isEnabled = false
        btn.setTitle("浏览分区", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.setImage(UIImage(named: "right_>"), for: .normal)
        btn.semanticContentAttribute = .forceRightToLeft
        btn.contentHorizontalAlignment = .left
        self.contentView.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
    }
}
