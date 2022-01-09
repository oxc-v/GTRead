//
//  GTPDFEditCommentTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2022/1/6.
//

import Foundation
import UIKit

class GTPDFEditCommentTableViewCell: UITableViewCell {
    
    private var baseView: UIView!
    private var separatorView: UIView!

    var commentTitleTextfield: UITextField!
    var commentContentTextView: UITextView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {

        baseView = UIView()
        baseView.backgroundColor = UIColor(hexString: "#f2f1f6")
        baseView.layer.cornerRadius = 15
        self.contentView.addSubview(baseView)
        baseView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(160)
            make.left.equalTo(GTViewMargin)
            make.right.equalTo(-GTViewMargin)
            make.height.equalTo(300)
        }
        
        commentTitleTextfield = UITextField()
        commentTitleTextfield.attributedPlaceholder = NSAttributedString(string: "评论标题", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        commentTitleTextfield.font = UIFont.boldSystemFont(ofSize: 17)
        baseView.addSubview(commentTitleTextfield)
        commentTitleTextfield.snp.makeConstraints { make in
            make.left.top.equalTo(20)
            make.right.equalTo(-20)
        }
        
        separatorView = UIView()
        separatorView.backgroundColor = UIColor(hexString: "#cacacc")
        baseView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.top.equalTo(commentTitleTextfield.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        commentContentTextView = UITextView()
        commentContentTextView.backgroundColor = UIColor(hexString: "#f2f1f6")
        commentContentTextView.textColor = .lightGray
        commentContentTextView.font = UIFont.systemFont(ofSize: 17)
        baseView.addSubview(commentContentTextView)
        commentContentTextView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(20)
            make.bottom.equalTo(-20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
    }
}
