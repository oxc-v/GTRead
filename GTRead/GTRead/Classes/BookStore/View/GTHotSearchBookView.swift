//
//  GTHotSearchBookView.swift
//  GTRead
//
//  Created by Dev on 2021/11/16.
//

import Foundation
import UIKit

class GTHotSearchBookView: UIView {
    
    var numberImgView: UIImageView!
    var bookImgView: UIImageView!
    var hotBookImgView: UIImageView!
    var bookNameLable: UILabel!
    var bookDetailLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        numberImgView = UIImageView()
        numberImgView.contentMode = .scaleAspectFill
        self.addSubview(numberImgView)
        numberImgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
            make.width.equalTo(10)
            make.height.equalTo(20)
        }
        
        bookImgView = UIImageView()
        bookImgView.contentMode = .scaleAspectFill
        bookImgView.clipsToBounds = true
        bookImgView.layer.cornerRadius = 6
        self.addSubview(bookImgView)
        bookImgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(numberImgView.snp.right).offset(16)
            make.width.equalTo(60)
            make.height.equalTo(80)
        }
        
        bookNameLable = UILabel()
        bookNameLable.textAlignment = .left
        bookNameLable.font = UIFont.boldSystemFont(ofSize: 17)
        bookNameLable.lineBreakMode = .byTruncatingMiddle
        self.addSubview(bookNameLable)
        bookNameLable.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-15)
            make.left.equalTo(bookImgView.snp.right).offset(16)
            make.width.lessThanOrEqualTo(500)
        }
        
        bookDetailLabel = UILabel()
        bookDetailLabel.textAlignment = .left
        bookDetailLabel.textColor = UIColor(hexString: "#b4b4b4")
        bookDetailLabel.font = UIFont.boldSystemFont(ofSize: 13)
        bookDetailLabel.lineBreakMode = .byTruncatingMiddle
        self.addSubview(bookDetailLabel)
        bookDetailLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(15)
            make.left.equalTo(bookImgView.snp.right).offset(16)
            make.width.lessThanOrEqualTo(500)
        }
        
        hotBookImgView = UIImageView()
        hotBookImgView.image = UIImage(named: "hot_book")
        hotBookImgView.isHidden = true
        hotBookImgView.contentMode = .scaleAspectFill
        hotBookImgView.clipsToBounds = true
        self.addSubview(hotBookImgView)
        hotBookImgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-15)
            make.left.equalTo(bookNameLable.snp.right).offset(10)
            make.width.height.equalTo(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
