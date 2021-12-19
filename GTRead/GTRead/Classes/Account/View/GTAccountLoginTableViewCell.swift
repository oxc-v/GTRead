//
//  GTAccountLoginTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/30.
//

import Foundation
import UIKit

class GTAccountLoginTableViewCell: UITableViewCell {
    
    var textfield: UITextField!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textfield = UITextField()
        textfield.textAlignment = .left
        textfield.keyboardType = .asciiCapableNumberPad
        self.contentView.addSubview(textfield)
        textfield.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(35)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
