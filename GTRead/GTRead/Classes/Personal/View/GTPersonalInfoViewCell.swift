//
//  GTPersonalInfoViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/10/18.
//

import UIKit

class GTPersonalInfoViewCell: UITableViewCell {
    
    var imgView: UIImageView!
    var titleTxtLabel: UILabel!
    var detailTextField: UITextField!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.masksToBounds = false
        imgView.layer.cornerRadius = 25
        imgView.clipsToBounds = true
        self.contentView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.height.width.equalTo(50)
            make.centerY.equalToSuperview()
        }
        
        titleTxtLabel = UILabel()
        titleTxtLabel.font = titleTxtLabel.font.withSize(18)
        titleTxtLabel.textAlignment = .left
        titleTxtLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.contentView.addSubview(titleTxtLabel)
        titleTxtLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        
        detailTextField = UITextField()
        detailTextField.textAlignment = .right
        self.contentView.addSubview(detailTextField)
        detailTextField.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
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
