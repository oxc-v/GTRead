//
//  GTRankingListBookTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/25.
//

import Foundation
import UIKit

class GTRankingListBookTableViewCell: UITableViewCell {
    
    private var baseView: GTShadowView!
    
    var imgView: UIImageView!
    var numberLab: UILabel!
    var bookNameLab: UILabel!
    var authorNameLab: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        baseView = GTShadowView()
        self.contentView.addSubview(baseView)
        baseView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.width.equalTo(baseView.snp.height).multipliedBy(0.7)
        }
        
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 5
        imgView.clipsToBounds = true
        self.baseView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.equalTo(self.contentView.snp.left)
            make.height.width.equalToSuperview()
        }
        
        numberLab = UILabel()
        numberLab.textAlignment = .left
        numberLab.font = UIFont.systemFont(ofSize: 26)
        self.contentView.addSubview(numberLab)
        numberLab.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(20)
            make.centerY.equalToSuperview()
        }
        
        bookNameLab = UILabel()
        bookNameLab.textAlignment = .left
        bookNameLab.font = UIFont.boldSystemFont(ofSize: 16)
        self.contentView.addSubview(bookNameLab)
        bookNameLab.snp.makeConstraints { make in
            make.left.equalTo(numberLab.snp.right).offset(20)
            make.centerY.equalToSuperview().offset(-10)
        }
        
        authorNameLab = UILabel()
        authorNameLab.textAlignment = .left
        authorNameLab.textColor = UIColor(hexString: "b4b4b4")
        authorNameLab.font = UIFont.systemFont(ofSize: 14)
        self.contentView.addSubview(authorNameLab)
        authorNameLab.snp.makeConstraints { make in
            make.left.equalTo(numberLab.snp.right).offset(20)
            make.centerY.equalToSuperview().offset(10)
        }
    }
}
