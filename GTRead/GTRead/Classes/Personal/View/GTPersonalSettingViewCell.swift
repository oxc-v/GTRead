//
//  GTPersonalSettingViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/10/19.
//

import UIKit

class GTPersonalSettingViewCell: UITableViewCell {
    
    var titleTxtLabel: UILabel!
    var txtLabel: UILabel!
    var detailTxtLabel: UILabel!
    
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
        
        titleTxtLabel = UILabel()
        titleTxtLabel.font = titleTxtLabel.font.withSize(18)
        titleTxtLabel.textAlignment = .center
        titleTxtLabel.textColor = .red
        titleTxtLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.contentView.addSubview(titleTxtLabel)
        titleTxtLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        detailTxtLabel = UILabel()
        detailTxtLabel.font = UIFont.boldSystemFont(ofSize: 17)
        detailTxtLabel.textColor = UIColor(hexString: "#b4b4b4")
        detailTxtLabel.textAlignment = .center
        detailTxtLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.contentView.addSubview(detailTxtLabel)
        detailTxtLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
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
