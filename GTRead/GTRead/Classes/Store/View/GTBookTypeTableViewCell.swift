//
//  GTBookTypeTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/26.
//

import Foundation
import UIKit

class GTBookTypeTableViewCell: UITableViewCell {
    
    var imgView: UIImageView!
    var titleLab: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set(newFrame) {
            var frame = newFrame
            let newWidth = UIScreen.main.bounds.width - GTViewMargin * 2
            let space = (frame.width - newWidth) / 2
            frame.size.width = newWidth
            frame.origin.x += space
            super.frame = frame
        }
    }
    
    private func setupView() {
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.bottom.equalTo(-20)
            make.top.equalTo(15)
            make.width.equalTo(imgView.snp.height)
            make.left.equalToSuperview()
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
