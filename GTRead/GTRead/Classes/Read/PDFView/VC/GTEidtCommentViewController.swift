//
//  GTEidtCommentView.swift
//  GTRead
//
//  Created by Dev on 2021/7/31.
//

import UIKit

class GTEidtCommentViewController: GTBaseViewController {
    
    var parentId: Int!
    var pageNum: Int = -1
    var titleView: UIView!
    var contentView: UIView!
    var titleLabel: UILabel!
    var sendBtn: UIButton!
    var closeBtn: UIButton!
    var textField: UITextField!
    var bookId: String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.view.layer.cornerRadius = 8
        self.view.layer.masksToBounds = true
        self.view.layer.borderColor = UIColor.gray.cgColor
        self.view.layer.borderWidth = 2
        
        contentView = UIView()
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor.white
        let tap = UITapGestureRecognizer(target: self, action: #selector(resignTextField))
        contentView.addGestureRecognizer(tap)
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
        }
        
        titleView = UIView()
        titleView.backgroundColor = UIColor.white
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(64)
        }
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = "编辑评论"
        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        sendBtn = UIButton(type: .custom)
        sendBtn.setImage(UIImage(named: "comment_send"), for: .normal)
        sendBtn.addTarget(self, action: #selector(sendButtonDidClicked), for: .touchUpInside)
        contentView.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalTo(contentView)
            make.width.equalTo(30)
            make.height.equalTo(40)
        }
        
        closeBtn = UIButton(type: .custom)
        closeBtn.setImage(UIImage(named: "comment_close"), for: .normal)
        closeBtn.backgroundColor = UIColor.white
        closeBtn.addTarget(self, action: #selector(closeButtonDidClicked), for: .touchUpInside)
        titleView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        textField = UITextField()
        textField.placeholder = "开始评论吧！"
        textField.borderStyle = .roundedRect;
        contentView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.centerY.equalTo(contentView)
            make.right.equalTo(sendBtn.snp.left).offset(-8)
            make.height.equalTo(40)
        }
    }
    
    init(bookId: String) {
        self.bookId = bookId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func resignTextField() {
        textField.resignFirstResponder()
    }
    
    // 发送评论
    @objc private func sendButtonDidClicked() {
        // 发送请求
        let date = Date.init()
        let timeStamp = date.timeIntervalSince1970
        GTNet.shared.addCommentList(success: {(json) in
            NotificationCenter.default.post(name: NotiReflashCommentContent, object: self)
            self.view.removeFromSuperview()
        }, bookId: self.bookId, pageNum: pageNum, parentId: parentId, timeStamp: String(timeStamp), commentContent: textField.text ?? "")
    }

    @objc private func closeButtonDidClicked() {
        self.view.removeFromSuperview()
    }
}
