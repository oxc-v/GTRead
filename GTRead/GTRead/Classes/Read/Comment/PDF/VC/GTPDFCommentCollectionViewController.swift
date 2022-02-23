//
//  GTPDFCommentCollectionViewController.swift
//  GTRead
//
//  Created by Dev on 2022/1/6.
//

import Foundation
import UIKit
import MJRefresh

class GTPDFCommentCollectionViewController: GTCollectionViewController {
    
    private var cancelBtn: UIButton!
    private var editCommentBtn: UIButton!
    
    private let userId: Int
    private let bookId: String
    private let pdfImg: UIImage
    private let pdfPage: Int
    private var offset: Int
    private var filterIndex = 0
    private let maxCount = 10
    private let filterInfo = ["最有帮助", "最少点赞", "最新发表"]
    
    private var commentDataModel: GTPDFCommentDataModel?
    
    init (pdfImg: UIImage, page: Int, bookId: String, userId: Int, layout: UICollectionViewLayout) {
        self.bookId = bookId
        self.userId = userId
        self.pdfImg = pdfImg
        self.offset = 0
        self.pdfPage = page
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setupCollectionView()
        
        // 评论筛选值变化
        NotificationCenter.default.addObserver(self, selector: #selector(handleGTCommentFilterValueChangedNotification(notif:)), name: .GTCommentFilterValueChanged, object: nil)
        
        // 刷新评论内容
        NotificationCenter.default.addObserver(self, selector: #selector(reloadComment), name: .GTReflashPDFComment, object: nil)
    }
    
    private func setupNavigationBar() {
        
        self.navigationItem.title = "本页用户评论"
        
        cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancelBtn.setTitleColor(.black, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnDidClicked(sender:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBtn)
        
        editCommentBtn = UIButton(type: .custom)
        editCommentBtn.setImage(UIImage(named: "edit_comment"), for: .normal)
        editCommentBtn.addTarget(self, action: #selector(editCommentBtnDidClicked(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editCommentBtn)
    }
    
    private func setupCollectionView() {
        
        let footer = MJRefreshAutoNormalFooter()
        footer.setTitle("释放加载", for: .pulling)
        footer.setTitle("正在加载...", for: .refreshing)
        footer.setTitle("已经到底啦～", for: .noMoreData)
        footer.setRefreshingTarget(self, refreshingAction: #selector(refreshCommentData(refreshControl:)))
        self.collectionView.mj_footer = footer
        self.collectionView.mj_footer?.beginRefreshing()
        
        collectionView.backgroundColor = .white
        collectionView.register(GTCommentFiltrateCollectionViewcell.self, forCellWithReuseIdentifier: "GTCommentFiltrateCollectionViewcell")
        collectionView.register(GTPDFCommentCollectionViewCell.self, forCellWithReuseIdentifier: "GTPDFCommentCollectionViewCell")
    }
    
    // 刷新评论内容
    @objc private func reloadComment() {
        self.offset = 0
        self.commentDataModel?.lists?.removeAll()
        self.commentDataModel?.count = 0
        self.collectionView.reloadData()
        self.collectionView.mj_footer?.beginRefreshing()
    }
    
    // 取消按钮点击事件
    @objc private func cancelBtnDidClicked(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // 处理编辑评论按钮点击事件
    @objc private func editCommentBtnDidClicked(sender: UIButton) {
        let vc = GTCommentNavigationController(rootViewController: GTPDFEdiCommentTableViewController(commentId: nil, type: 0, userId: self.userId, bookId: self.bookId, page: self.pdfPage, img: self.pdfImg, style: .plain))
        self.present(vc, animated: true)
    }
    
    // 筛选按钮点击事件
    @objc private func filtrateBtnDidClicked(sender: UIButton) {
        let popoverVC = GTCommentFiltrateTableViewController(cellInfo: self.filterInfo)
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: 250, height: 150)
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: sender.frame.size.width / 2.0, y: sender.frame.size.height, width: 0, height: 0)
            popoverController.permittedArrowDirections = .up
        }
        self.present(popoverVC, animated: true)
    }
    
    // 处理评论内容筛选选项变化的通知
    @objc private func handleGTCommentFilterValueChangedNotification(notif: Notification) {
        if let info = notif.userInfo {
            let cell = self.collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as! GTCommentFiltrateCollectionViewcell
            cell.filtrateBtn.setTitle(info["selectedStr"] as? String, for: .normal)
            self.filterIndex = info["selectedIndex"] as! Int
            
            if self.commentDataModel != nil && self.commentDataModel?.count != 0 {
                self.commentDataModel?.lists?.removeAll()
                self.commentDataModel?.count = 0
                self.offset = 0
                self.collectionView.reloadData()
                
                // 重新刷新评论内容
                self.collectionView.mj_footer?.beginRefreshing()
            }
        }
    }
    
    // 获取评论内容列表
    @objc private func getPDFCommentLists() {
        var pattern: GTPDFCommentPattern = .hit
        var reverse = false
        switch self.filterIndex {
        case 0:
            pattern = .hit
            reverse = true
        case 1:
            pattern = .hit
            reverse = false
        case 2:
            pattern = .time
            reverse = true
        default:
            break
        }
        
        GTNet.shared.getTopPDFCommentFun(observer: self.userId, offset: self.offset, count: self.maxCount, bookId: self.bookId, pattern: pattern, reverse: reverse, page: self.pdfPage, failure: { error in
            self.collectionView.mj_footer?.endRefreshing()
            
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }, success: { json in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            if let dataModel = try? decoder.decode(GTPDFCommentDataModel.self, from: data!) {
                print(dataModel)
                if dataModel.count > 0 {
                    self.offset += dataModel.count
                    self.commentDataModel = dataModel
                    
                    if dataModel.count < self.maxCount {
                        self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                    } else {
                        self.collectionView.mj_footer?.endRefreshing()
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } else {
                    self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                }
            } else {
                self.collectionView.mj_footer?.endRefreshing()
                self.showNotificationMessageView(message: "服务器数据错误")
            }
        })
    }
    
    @objc private func noCommentBtnDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.1, completion: { _ in
            GTNet.shared.hitPDFCommentFun(userId: self.userId, praised: self.commentDataModel!.lists![sender.tag].reviewer, bookId: self.bookId, page: self.pdfPage, commentId: self.commentDataModel!.lists![sender.tag].commentId, failure: { error in
                if GTNet.shared.networkAvailable() {
                    self.showNotificationMessageView(message: "服务器连接中断")
                } else {
                    self.showNotificationMessageView(message: "网络连接不可用")
                }
            }, success: { json in
                let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                let decoder = JSONDecoder()
                if let dataModel = try? decoder.decode(GTErrorDataModel.self, from: data!) {
                    if dataModel.code == 1 {
                        self.commentDataModel!.lists![sender.tag].isHited = 1
                        self.commentDataModel!.lists![sender.tag].hitCount += 1
                        let commentItem = self.commentDataModel!.lists![sender.tag]
                        
                        let cell = self.collectionView.cellForItem(at: IndexPath(row: sender.tag + 1, section: 0)) as! GTPDFCommentCollectionViewCell
                        sender.zoomOut()
                        sender.isHidden = commentItem.isHited == 1 ? true : false
                        cell.yesCommentBtn.isHidden = commentItem.isHited == 0 ? true : false
                        cell.yesCommentBtn.zoomIn()
                        cell.yesCommentBtn.setTitle(String(commentItem.hitCount), for: .normal)
                        cell.noCommentBtn.setTitle(String(commentItem.hitCount), for: .normal)
                    } else {
                        self.showNotificationMessageView(message: "点赞失败")
                    }
                } else {
                    self.showNotificationMessageView(message: "服务器数据错误")
                }
            })
        })
    }
    
    @objc private func yesCommentBtnDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.1, completion: { _ in
            GTNet.shared.cancelHitPDFCommentFun(userId: self.userId, praised: self.commentDataModel!.lists![sender.tag].reviewer, bookId: self.bookId, page: self.pdfPage, commentId: self.commentDataModel!.lists![sender.tag].commentId, failure: { error in
                if GTNet.shared.networkAvailable() {
                    self.showNotificationMessageView(message: "服务器连接中断")
                } else {
                    self.showNotificationMessageView(message: "网络连接不可用")
                }
            }, success: { json in
                let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                let decoder = JSONDecoder()
                if let dataModel = try? decoder.decode(GTErrorDataModel.self, from: data!) {
                    if dataModel.code == 1 {
                        self.commentDataModel!.lists![sender.tag].isHited = 0
                        self.commentDataModel!.lists![sender.tag].hitCount -= 1
                        let commentItem = self.commentDataModel!.lists![sender.tag]
                        
                        let cell = self.collectionView.cellForItem(at: IndexPath(row: sender.tag + 1, section: 0)) as! GTPDFCommentCollectionViewCell
                        sender.zoomOut()
                        sender.isHidden = commentItem.isHited == 0 ? true : false
                        cell.noCommentBtn.isHidden = commentItem.isHited == 1 ? true : false
                        cell.noCommentBtn.zoomIn()
                        cell.yesCommentBtn.setTitle(String(commentItem.hitCount), for: .normal)
                        cell.noCommentBtn.setTitle(String(commentItem.hitCount), for: .normal)
                    } else {
                        print(dataModel.errorRes)
                        self.showNotificationMessageView(message: "取消点赞失败")
                    }
                } else {
                    self.showNotificationMessageView(message: "服务器数据错误")
                }
            })
        })
    }
    
    // 上拉刷新
    @objc private func refreshCommentData(refreshControl: UIRefreshControl) {
        self.getPDFCommentLists()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.commentDataModel?.count ?? 0) + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTCommentFiltrateCollectionViewcell", for: indexPath) as! GTCommentFiltrateCollectionViewcell
            cell.filtrateBtn.addTarget(self, action: #selector(filtrateBtnDidClicked(sender:)), for: .touchUpInside)
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTPDFCommentCollectionViewCell", for: indexPath) as! GTPDFCommentCollectionViewCell
            let commentItem = self.commentDataModel!.lists![indexPath.row - 1]
            cell.commentTitleLabel.text = commentItem.title
            cell.commentContentLabel.text = commentItem.content
            cell.timeLabel.text = commentItem.remarkTime.timeIntervalChangeToTimeStr()
            cell.nicknameLabel.text = commentItem.nickname
            cell.imgView.sd_setImage(with: URL(string: commentItem.headUrl), placeholderImage: UIImage(named: "head_men"))
            cell.readMoreBtn.setTitle(String(self.commentDataModel!.lists![indexPath.row - 1].replyCount) + " 条回复", for: .normal)
            
            cell.yesCommentBtn.setTitle(String(commentItem.hitCount), for: .normal)
            cell.noCommentBtn.setTitle(String(commentItem.hitCount), for: .normal)
            cell.noCommentBtn.isHidden = commentItem.isHited == 1 ? true : false
            cell.yesCommentBtn.isHidden = commentItem.isHited == 0 ? true : false
            cell.noCommentBtn.tag = indexPath.row - 1
            cell.yesCommentBtn.tag = indexPath.row - 1
            cell.noCommentBtn.addTarget(self, action: #selector(noCommentBtnDidClicked(sender:)), for: .touchUpInside)
            cell.yesCommentBtn.addTarget(self, action: #selector(yesCommentBtnDidClicked(sender:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = GTCommentCollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: GTViewMargin, bottom: 0, right: GTViewMargin)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        let vc = GTPDFReplyCommentCollectionViewController(comment: self.commentDataModel!.lists![indexPath.row - 1], commentId: self.commentDataModel!.lists![indexPath.row - 1].commentId, img: self.pdfImg, page: self.pdfPage, bookId: self.bookId, userId: self.userId, layout: layout)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
