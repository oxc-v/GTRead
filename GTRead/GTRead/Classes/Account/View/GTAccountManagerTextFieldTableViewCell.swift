//
//  GTAccountManagerTextFieldTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/27.
//

import Foundation
import UIKit

class GTAccountManagerTextFieldTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel!
    var textField: UITextField!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textAlignment = .left
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.width.lessThanOrEqualTo(40)
            make.centerY.equalToSuperview()
        }
        
        textField = UITextField()
        textField.textAlignment = .left
        textField.keyboardType = .asciiCapableNumberPad
        self.contentView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(20)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(35)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textField.isSecureTextEntry = false
    }
}
