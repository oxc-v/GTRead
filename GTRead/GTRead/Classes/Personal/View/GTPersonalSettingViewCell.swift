//
//  GTPersonalSettingViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/10/19.
//

import UIKit

class GTPersonalSettingViewCell: UITableViewCell {
    
    var titleTxtLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleTxtLabel = UILabel()
        titleTxtLabel.font = titleTxtLabel.font.withSize(18)
        titleTxtLabel.textAlignment = .center
        titleTxtLabel.textColor = .red
        titleTxtLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.contentView.addSubview(titleTxtLabel)
        titleTxtLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
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
