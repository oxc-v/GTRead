//
//  GTPartitionTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/26.
//

import Foundation
import UIKit

class GTPartitionTableViewCell: UITableViewCell {
    
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
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.bottom.equalTo(-20)
            make.top.equalTo(20)
            make.width.equalTo(imgView.snp.height)
            make.left.equalTo(20)
        }
        
        titleLab = UILabel()
        titleLab.textColor = .black
        titleLab.textAlignment = .left
        titleLab.font = UIFont.systemFont(ofSize: 18)
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(20)
            make.centerY.equalToSuperview()
        }
    }
}
