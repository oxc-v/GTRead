//
//  GTPDFReplyCommentCollectionViewController.swift
//  GTRead
//
//  Created by Dev on 2022/1/6.
//

import Foundation
import UIKit
import MJRefresh

class GTPDFReplyCommentCollectionViewController: GTCollectionViewController {
    
    private var editCommentBtn: UIButton!
    
    private let userId: Int
    private let bookId: String
    private let pdfPage: Int
    private let pdfImg: UIImage
    private let commentId: Int
    private let parentComment: GTPDFCommentItem
    
    private var pattern: GTPDFCommentPattern = .hit
    private let maxCount = 10
    private var offset: Int
    private var commentDataModel: GTPDFCommentDataModel?
    
    init (comment: GTPDFCommentItem, commentId: Int, img: UIImage, page: Int, bookId: String, userId: Int, layout: UICollectionViewLayout) {
        self.bookId = bookId
        self.userId = userId
        self.pdfPage = page
        self.pdfImg = img
        self.commentId = commentId
        self.parentComment = comment
        self.offset = 0
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setupCollectionView()

        // 刷新评论内容
        NotificationCenter.default.addObserver(self, selector: #selector(reloadComment), name: .GTReflashPDFComment, object: nil)
    }
    
    private func setupNavigationBar() {
        
        self.navigationItem.title = "评论"
        
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
//        collectionView.register(GTPDFCommentCollectionViewCell.self, forCellWithReuseIdentifier: "GTPDFCommentCollectionViewCell")
        collectionView.register(GTPDFReplyCommentCollectionViewCell.self, forCellWithReuseIdentifier: "GTPDFReplyCommentCollectionViewCell")
        collectionView.register(GTPDFParentCommentCollectionViewCell.self, forCellWithReuseIdentifier: "GTPDFParentCommentCollectionViewCell")
    }
    
    // 刷新评论内容
    @objc private func reloadComment() {
        self.offset = 0
        self.commentDataModel?.lists?.removeAll()
        self.commentDataModel?.count = 0
        self.collectionView.reloadData()
        self.collectionView.mj_footer?.beginRefreshing()
    }
    
    // 上拉刷新
    @objc private func refreshCommentData(refreshControl: UIRefreshControl) {
        self.getPDFCommentLists()
    }
    
    @objc private func getPDFCommentLists() {
        let reverse = true
        
        GTNet.shared.getSubPDFCommentFun(observer: self.userId, offset: self.offset, count: self.maxCount, bookId: self.bookId, pattern: self.pattern, reverse: reverse, page: self.pdfPage, parentId: self.commentId, failure: { error in
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
                if dataModel.count > 0 {
                    self.offset += dataModel.count
                    self.commentDataModel = dataModel
                    
                    if dataModel.count < 10 {
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
    
    // 处理编辑评论按钮点击事件
    @objc private func editCommentBtnDidClicked(sender: UIButton) {
        let vc = GTCommentNavigationController(rootViewController: GTPDFEdiCommentTableViewController(commentId: self.commentId, type: 1, userId: self.userId, bookId: self.bookId, page: self.pdfPage, img: self.pdfImg, style: .plain))
        self.present(vc, animated: true)
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
                        
                        let cell = self.collectionView.cellForItem(at: IndexPath(row: sender.tag + 2, section: 0)) as! GTPDFParentCommentCollectionViewCell
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
                        
                        let cell = self.collectionView.cellForItem(at: IndexPath(row: sender.tag + 2, section: 0)) as! GTPDFParentCommentCollectionViewCell
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
    
    // 筛选按钮点击事件
    @objc private func filterBtnDidClicked(sender: UIButton) {
        let cell = self.collectionView.cellForItem(at: IndexPath(row: 1, section: 0)) as! GTPDFReplyCommentCollectionViewCell
        
        if sender.tag == 0 {
            self.pattern = .hit
            cell.timeBtn.isEnabled = true
            cell.likeBtn.isEnabled = false
        } else {
            self.pattern = .time
            cell.timeBtn.isEnabled = false
            cell.likeBtn.isEnabled = true
        }
        
        self.offset = 0
        self.commentDataModel?.lists?.removeAll()
        self.commentDataModel?.count = 0
        self.collectionView.reloadData()
        self.collectionView.mj_footer?.beginRefreshing()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.commentDataModel?.count ?? 0) + 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTPDFParentCommentCollectionViewCell", for: indexPath) as! GTPDFParentCommentCollectionViewCell
            cell.commentTitleLabel.text = self.parentComment.title
            cell.commentContentLabel.text = self.parentComment.content
            cell.timeLabel.text = self.parentComment.remarkTime.timeIntervalChangeToTimeStr()
            cell.nicknameLabel.text = self.parentComment.nickname
            cell.imgView.sd_setImage(with: URL(string: self.parentComment.headUrl), placeholderImage: UIImage(named: "head_men"))
            
            cell.yesCommentBtn.setTitle(String(self.parentComment.hitCount), for: .normal)
            cell.noCommentBtn.setTitle(String(self.parentComment.hitCount), for: .normal)
            cell.noCommentBtn.isHidden = self.parentComment.isHited == 1 ? true : false
            cell.yesCommentBtn.isHidden = self.parentComment.isHited == 0 ? true : false
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTPDFReplyCommentCollectionViewCell", for: indexPath) as! GTPDFReplyCommentCollectionViewCell
            cell.timeBtn.tag = 1
            cell.likeBtn.tag = 0
            cell.likeBtn.isEnabled = self.pattern == .hit ? false : true
            cell.likeBtn.addTarget(self, action: #selector(filterBtnDidClicked(sender:)), for: .touchUpInside)
            cell.timeBtn.addTarget(self, action: #selector(filterBtnDidClicked(sender:)), for: .touchUpInside)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTPDFParentCommentCollectionViewCell", for: indexPath) as! GTPDFParentCommentCollectionViewCell
            let commentItem = self.commentDataModel!.lists![indexPath.row - 2]
            cell.commentTitleLabel.text = commentItem.title
            cell.commentContentLabel.text = commentItem.content
            cell.timeLabel.text = commentItem.remarkTime.timeIntervalChangeToTimeStr()
            cell.nicknameLabel.text = commentItem.nickname
            cell.imgView.sd_setImage(with: URL(string: commentItem.headUrl), placeholderImage: UIImage(named: "head_men"))
//            cell.readMoreBtn.setTitle(String(self.commentDataModel!.lists![indexPath.row - 2].replyCount) + " 条回复", for: .normal)
            
            cell.yesCommentBtn.setTitle(String(commentItem.hitCount), for: .normal)
            cell.noCommentBtn.setTitle(String(commentItem.hitCount), for: .normal)
            cell.noCommentBtn.isHidden = commentItem.isHited == 1 ? true : false
            cell.yesCommentBtn.isHidden = commentItem.isHited == 0 ? true : false
            cell.noCommentBtn.tag = indexPath.row - 2
            cell.yesCommentBtn.tag = indexPath.row - 2
            cell.noCommentBtn.addTarget(self, action: #selector(noCommentBtnDidClicked(sender:)), for: .touchUpInside)
            cell.yesCommentBtn.addTarget(self, action: #selector(yesCommentBtnDidClicked(sender:)), for: .touchUpInside)
            
            return cell
        }
    }
}
