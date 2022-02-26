//
//  GTNoDataTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2022/2/24.
//

import Foundation
import UIKit

class GTNoDataTableViewCell: UITableViewCell {
    
    private var lab: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        lab = UILabel()
        lab.text = "暂无数据"
        lab.textColor = .black
        lab.font = UIFont.systemFont(ofSize: 18)
        self.contentView.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
