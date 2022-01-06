//
//  GTCommentFiltrateTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2022/1/3.
//

import Foundation
import UIKit

class GTCommentFiltrateTableViewCell: UITableViewCell {
    
    var titleLab: UILabel!
    var imgView: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 18)
        titleLab.textAlignment = .left
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-20)
            make.width.height.equalTo(36)
        }
    }
    
    override func prepareForReuse() {
        imgView.image = nil
    }
}
