//
//  GTCommentViewController.swift
//  GTRead
//
//  Created by YangJie on 2021/4/21.
//

import UIKit
import SwiftyJSON

let maxCount = 1
let rowHeight = 50

class GTCommentViewController: GTBaseViewController {
    var contentView: UIView!
    var titleView: UIView!
    var closeBtn: UIButton!
    var titleLabel: UILabel!
    var tableView: UITableView!
    var commentView: UIView!
    var sendBtn: UIButton!
    var textField: UITextField!
    var dataModel: GTCommentModel?
    var selectedIndex: Int = -1
    var pageNum: Int = -1
    var isExpandCell: Bool = false
    var cellRowIndex: Int = -1
    var emptyView: UIImageView = {
        let imageview = UIImageView()
        imageview.isUserInteractionEnabled = false
        imageview.contentMode = .scaleAspectFill
        imageview.image = UIImage(named: "comment_empty")
        return imageview
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        contentView = UIView()
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor.white
        let tap = UITapGestureRecognizer(target: self, action: #selector(resignTextField))
        contentView.addGestureRecognizer(tap)
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.top.equalTo(88)
            make.bottom.equalTo(-98)
        }
        
        titleView = UIView()
        titleView.backgroundColor = UIColor.white
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(64)
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
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = "本页评论"
        titleView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        contentView.addSubview(emptyView)
        emptyView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(300)
        }
        
        commentView = UIView()
        commentView.backgroundColor = UIColor.white
        contentView.addSubview(commentView)
        commentView.snp.makeConstraints { (make) in
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.bottom.equalTo(-32)
            make.height.equalTo(50)
        }
        
        sendBtn = UIButton(type: .custom)
        sendBtn.setImage(UIImage(named: "comment_send"), for: .normal)
        sendBtn.addTarget(self, action: #selector(sendButtonDidClicked), for: .touchUpInside)
        commentView.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.centerY.equalTo(commentView)
            make.width.equalTo(30)
            make.height.equalTo(40)
        }
        
        textField = UITextField()
        textField.placeholder = "开始评论吧！"
        textField.borderStyle = .roundedRect;
        commentView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalTo(commentView)
            make.right.equalTo(sendBtn.snp.left).offset(-8)
            make.height.equalTo(40)
        }
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(GTCommentViewCell.self, forCellReuseIdentifier: "GTCommentViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.bottom.equalTo(commentView.snp.top)
            make.left.equalTo(16)
            make.right.equalTo(-16);
        }
        
        // 获取评论请求
        requestCommentContent()
        
        // 注册编辑评论通知
        NotificationCenter.default.addObserver(self, selector: #selector(openEditCommentView), name: NSNotification.Name("OpenEditCommentView"), object: nil)
        
        // 注册刷新评论内容通知
        NotificationCenter.default.addObserver(self, selector: #selector(requestCommentContent), name: NotiReflashCommentContent, object: nil)
        
        // 注册评论内容折叠状态改变通知
        NotificationCenter.default.addObserver(self, selector: #selector(changedCellFoldState), name: NotiCommentContentFoldStateChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("OpenEditCommentView"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NotiReflashCommentContent, object: nil)
        NotificationCenter.default.removeObserver(self, name: NotiCommentContentFoldStateChanged, object: nil)
    }
    
    // 折叠和展开Cell
    @objc private func changedCellFoldState(noti: Notification) {
        let userInfo = noti.userInfo
        self.isExpandCell = userInfo?["isExpand"] as? Bool ?? false
        self.cellRowIndex = userInfo?["rowIndex"] as? Int ?? -1
        self.tableView.reloadData()
    }
    
    // 请求评论内容
    @objc private func requestCommentContent() {
        GTNet.shared.getCommentList(success: { (json) in
            self.tableView.isHidden = false
            self.emptyView.isHidden = true
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            self.dataModel = try! decoder.decode(GTCommentModel.self, from: data!)
            self.tableView.reloadData()
        }, error: { (error) in
            self.tableView.isHidden = true
            self.emptyView.isHidden = false
        }, bookId: "123", pageNum: self.pageNum)
    }
    
    // 打开评论编辑视图
    @objc private func openEditCommentView(noti: Notification) {
        let commentVC = GTEidtCommentViewController()
        let userInfo = noti.userInfo
        commentVC.parentId = userInfo?["parentId"] as? Int
        commentVC.pageNum = pageNum
        self.addChild(commentVC)
        self.view.addSubview(commentVC.view)
        commentVC.view.snp.makeConstraints { (make) in
            make.width.equalTo(400)
            make.height.equalTo(180)
            make.center.equalToSuperview()
        }
    }
    
    @objc private func closeButtonDidClicked() {
        self.view.removeFromSuperview()
    }
    
    // 发送评论
    @objc private func sendButtonDidClicked() {
        let date = Date.init()
        let timeStamp = date.timeIntervalSince1970
        GTNet.shared.addCommentList(success: {(json) in
            self.requestCommentContent()
            self.textField.text = ""
        }, pageNum: pageNum, timeStamp: String(timeStamp), commentContent: textField.text ?? "")
    }
    
    @objc private func resignTextField() {
        textField.resignFirstResponder()
    }
}

extension GTCommentViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.dataModel?.lists?.count ?? 0 > indexPath.row {
            guard let lists = self.dataModel?.lists else {
                return 0
            }
            let model: GTCommentItem = lists[indexPath.row]
            
            if self.cellRowIndex == indexPath.row {
                return self.isExpandCell ? CGFloat(rowHeight + rowHeight * model.childCount) : CGFloat(rowHeight);
            } else {
                return CGFloat(rowHeight)
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataModel?.lists?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GTCommentViewCell", for: indexPath) as! GTCommentViewCell
        if self.dataModel?.lists?.count ?? 0 > indexPath.row {
            guard let lists = self.dataModel?.lists else {
                return cell
            }
            let model: GTCommentItem = lists[indexPath.row]
            cell.updateWithData(model: model)
        }
        return cell
    }
}
