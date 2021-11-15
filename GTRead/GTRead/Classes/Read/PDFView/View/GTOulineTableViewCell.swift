//
//  GTOulineTableViewCell.swift
//  GTRead
//
//  Created by YangJie on 2021/4/21.
//

import UIKit

class GTOulineTableViewCell: UITableViewCell {
    var openBtn: UIButton!
    var textLab: UILabel!
    var openBtnEvent:((_ sender: UIButton) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        openBtn = UIButton(type: .custom)
        openBtn.addTarget(self, action: #selector(openButtontnClick(sender:)), for: .touchUpInside)
        openBtn.setImage(UIImage(named: "arrow_right"), for: .normal)
        self.contentView.addSubview(openBtn)
        openBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(30)
        }
        
        textLab = UILabel()
        textLab.textAlignment = .left
        textLab.font = UIFont.boldSystemFont(ofSize: 17)
        textLab.textColor = UIColor(hexString: "#4b4b4b")
        self.contentView.addSubview(textLab)
        textLab.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.lessThanOrEqualTo(openBtn.snp.left).offset(5)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func openButtontnClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        openBtnEvent?(sender)
    }
}
