//
//  GTCommentViewCell.swift
//  GTRead
//
//  Created by YangJie on 2021/4/21.
//

import UIKit
import SDWebImage

extension UITableViewCell {
    //返回cell所在的UITableView
    func superTableView() -> UITableView? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let tableView = view as? UITableView {
                return tableView
            }
        }
        return nil
    }
}

class GTCommentViewCell: UITableViewCell {
    
    var isExpand: Bool = false      // Cell是否展开
    var commentId: Int!             // 评论ID
    var headImgView: UIImageView!   // 头像
    var userLabel: UILabel!         // 用户名
    var contentLabel: UILabel!      // 评论内容
    var commentBtn: UIButton!       // 发表评论按钮
    var commentShowBtn: UIButton!   // 折叠和展开评论内容按钮
    var tableView: UITableView!
    var itemModel: GTCommentItem?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // 头像
        headImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        headImgView.contentMode = .scaleAspectFill
        headImgView.layer.masksToBounds = true
        headImgView.layer.cornerRadius = headImgView.frame.width / 2
        self.contentView.addSubview(headImgView)
        
        // 用户名
        userLabel = UILabel()
        userLabel.text = "书友"
        userLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.contentView.addSubview(userLabel)
        userLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headImgView.snp.right).offset(10)
            make.top.equalToSuperview()
            make.height.equalTo(20)
        }
        
        // 评论内容
        contentLabel = UILabel()
        contentLabel.text = "这章内容很精彩呀！"
        self.contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualTo(headImgView.snp.right).offset(10)
            make.top.greaterThanOrEqualTo(userLabel.snp.bottom).offset(-10)
            make.height.equalTo(50)
        }
        
        // 评论按钮
        commentBtn = UIButton(type: .custom)
        commentBtn.setImage(UIImage(named: "comment_edit"), for: .normal)
        commentBtn.addTarget(self, action: #selector(commentBtnDidClicked), for: .touchUpInside)
        self.contentView.addSubview(commentBtn)
        commentBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-50)
        }
        
        // 评论内容折叠按钮
        commentShowBtn = UIButton(type: .custom)
        commentShowBtn.setImage(UIImage(named: "comment_hidden"), for: .normal)
        commentShowBtn.addTarget(self, action: #selector(commentShowBtnClicked), for: .touchUpInside)
        self.contentView.addSubview(commentShowBtn)
        commentShowBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.commentBtn.snp.left).offset(-10)
        }
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(GTCommentViewCell.self, forCellReuseIdentifier: "GTSubCommentViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        self.contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(rowHeight)
            make.bottom.equalToSuperview()
            make.left.equalTo(20)
            make.right.equalTo(0);
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 更新数据
    func updateWithData(model: GTCommentItem) {
        itemModel = model
        commentId = model.commentId
        userLabel.text = model.nickName
        contentLabel.text = model.commentContent
        headImgView.sd_setImage(with: URL(string: model.headUrl!), placeholderImage: UIImage(named: "profile"))
        self.tableView.reloadData()
    }
    
    // 折叠按钮点击处理
    @objc private func commentShowBtnClicked() {
        if isExpand == false {
            isExpand = true
            self.commentShowBtn.setImage(UIImage(named: "comment_expand"), for: .normal)
        } else {
            isExpand = false
            self.commentShowBtn.setImage(UIImage(named: "comment_hidden"), for: .normal)
        }
        NotificationCenter.default.post(name: NotiCommentContentFoldStateChanged, object: self, userInfo: ["isExpand" : self.isExpand, "rowIndex": self.superTableView()?.indexPath(for: self)?.row])
    }
    
    // 评论编辑按钮点击处理
    @objc private func commentBtnDidClicked() {
        NotificationCenter.default.post(name: NSNotification.Name("OpenEditCommentView"), object: self, userInfo: ["parentId" : commentId ?? 0])
    }
}

extension GTCommentViewCell : UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(rowHeight)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let childCount = itemModel?.childCount else {
            return 0
        }
        return childCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTSubCommentViewCell", for: indexPath) as! GTCommentViewCell
        cell.commentShowBtn.isHidden = true
        if itemModel?.childComments?.count ?? 0 > indexPath.row {
            guard let childList = itemModel?.childComments else {
                return cell
            }
            let item = childList[indexPath.row]
            cell.updateWithData(model: item)
        }
        
        return cell
    }
}

