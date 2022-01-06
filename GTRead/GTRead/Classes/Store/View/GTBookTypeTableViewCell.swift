//
//  GTBookTypeTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/26.
//

import Foundation
import UIKit

class GTBookTypeTableViewCell: UITableViewCell {
    
    private var separatorView: UIView!
    var imgView: UIImageView!
    var titleLab: UILabel!
    
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
        imgView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.bottom.equalTo(-20)
            make.top.equalTo(separatorView.snp.bottom).offset(20)
            make.width.equalTo(imgView.snp.height)
            make.left.equalTo(GTViewMargin)
        }
        
        titleLab = UILabel()
        titleLab.textColor = .black
        titleLab.textAlignment = .left
        titleLab.font = UIFont.systemFont(ofSize: 17)
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(30)
            make.centerY.equalToSuperview()
        }
    }
}
