//
//  GTAccountManagerButtonTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/28.
//

import Foundation
import UIKit

class GTAccountManagerButtonTableViewCell: UITableViewCell {
    
    var btn: UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        btn = UIButton()
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.setTitleColor(UIColor(hexString: "#b4b4b4"), for: .disabled)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.titleLabel?.textAlignment = .left
        self.contentView.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.height.width.equalToSuperview()
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        btn.isEnabled = true
        btn.setTitleColor(.systemBlue, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
