//
//  GTAccountSecurityViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/10/20.
//

import UIKit

class GTAccountSecurityViewCell: UITableViewCell {
    
    var txtLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        txtLabel = UILabel()
        txtLabel.font = txtLabel.font.withSize(18)
        txtLabel.textAlignment = .left
        txtLabel.textColor = .black
        txtLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.contentView.addSubview(txtLabel)
        txtLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set(newFrame) {
            var frame = newFrame
            let newWidth = UIScreen.main.bounds.width - 16 * 2
            let space = (frame.width - newWidth) / 2
            frame.size.width = newWidth
            frame.origin.x += space
            super.frame = frame
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

