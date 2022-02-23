//
//  GTBookCommentCollectionViewController.swift
//  GTRead
//
//  Created by Dev on 2022/1/2.
//

import Foundation
import UIKit
import SwiftEntryKit
import SDWebImage
import MJRefresh
import Fuse

class GTBookCommentCollectionViewController: GTCollectionViewController {
    
    private var editCommentBtn: UIButton!
    
    private var commentDataModel: GTBookCommentDataModel
    private let bookScore: Float
    private let remarkCount: Int
    private let userId: Int
    private let bookId: String
    private let imgUrl: String
    private var offset: Int
    private let filterInfo = ["最有帮助", "最高评价", "最低评价", "最新发表"]
    private var filterIndex = 0
    
    init (imgUrl: String, bookId: String, userId: Int, bookScore: Float, remarkCount: Int, commentDataModel: GTBookCommentDataModel, layout: UICollectionViewLayout) {
        self.bookId = bookId
        self.userId = userId
        self.imgUrl = imgUrl
        self.commentDataModel = commentDataModel
        self.bookScore = bookScore
        self.remarkCount = remarkCount
        self.offset = self.commentDataModel.count
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NavigationBar
        self.setupNavigationBar()
        // CollectionView
        self.setupCollectionView()
        
        // 评论筛选值变化
        NotificationCenter.default.addObserver(self, selector: #selector(handleGTCommentFilterValueChangedNotification(notif:)), name: .GTCommentFilterValueChanged, object: nil)
    }
    
    // NavigationBar
    private func setupNavigationBar() {
        self.navigationItem.title = "用户评论"
        
        editCommentBtn = UIButton(type: .custom)
        editCommentBtn.setImage(UIImage(named: "edit_comment"), for: .normal)
        editCommentBtn.addTarget(self, action: #selector(editCommentBtnDidClicked(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editCommentBtn)
    }
    
    // CollectionView
    private func setupCollectionView() {
        let footer = MJRefreshAutoNormalFooter()
        footer.setTitle("释放加载", for: .pulling)
        footer.setTitle("正在加载...", for: .refreshing)
        footer.setTitle("已经到底啦～", for: .noMoreData)
        footer.setRefreshingTarget(self, refreshingAction: #selector(refreshCommentData(refreshControl:)))
        self.collectionView.mj_footer = footer
        if self.commentDataModel.count < 10 {
            self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
        }
        
        self.collectionView.contentInsetAdjustmentBehavior = .always
        self.collectionView.backgroundColor = .white
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.register(GTBookGradeCollectionViewCell.self, forCellWithReuseIdentifier: "GTBookGradeCollectionViewCell")
        self.collectionView.register(GTCommentFiltrateCollectionViewcell.self, forCellWithReuseIdentifier: "GTCommentFiltrateCollectionViewcell")
        self.collectionView.register(GTBookBigCommentCollectionViewCell.self, forCellWithReuseIdentifier: "GTBookBigCommentCollectionViewCell")
    }
    
    // 上拉刷新
    @objc private func refreshCommentData(refreshControl: UIRefreshControl) {
        var pattern: GTBookCommentPattern = .hit
        var reverse = false
        switch self.filterIndex {
        case 0:
            pattern = .hit
            reverse = true
        case 1:
            pattern = .score
            reverse = true
        case 2:
            pattern = .score
            reverse = false
        case 3:
            pattern = .time
            reverse = true
        default:
            break
        }
        
        GTNet.shared.getBookCommentLists(observer: self.userId, offset: self.offset, count: 10, bookId: self.bookId, pattern: pattern, reverse: reverse, failure: { error in
            self.collectionView.mj_footer?.endRefreshing()
            
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
        }, success: { json in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            if let dataModel = try? decoder.decode(GTBookCommentDataModel.self, from: data!) {
                if dataModel.count > 0 {
                    for item in dataModel.lists! {
                        self.commentDataModel.lists!.append(item)
                    }
                    self.commentDataModel.count = self.commentDataModel.lists!.count
                    
                    if dataModel.count < 10 {
                        self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                    } else {
                        self.collectionView.mj_footer?.endRefreshing()
                    }
 
                    self.offset += dataModel.count
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } else {
                    self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                }
            } else {
                self.showNotificationMessageView(message: "服务器数据错误")
                self.collectionView.mj_footer?.endRefreshing()
            }
        })
    }
    
    @objc private func noCommentBtnDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.1, completion: { _ in
            GTNet.shared.hitBookComment(userId: self.userId, praised: self.commentDataModel.lists![sender.tag - 2].praised, bookId: self.bookId, failure: { error in
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
                        self.commentDataModel.lists![sender.tag - 2].isHit = true
                        self.commentDataModel.lists![sender.tag - 2].hitCount += 1
                        let commentItem = self.commentDataModel.lists![sender.tag - 2]
                        
                        let cell = self.collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as! GTBookBigCommentCollectionViewCell
                        sender.zoomOut()
                        sender.isHidden = commentItem.isHit
                        cell.yesCommentBtn.isHidden = !commentItem.isHit
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
            GTNet.shared.cancelHitBookComment(userId: self.userId, praised: self.commentDataModel.lists![sender.tag - 2].praised, bookId: self.bookId, failure: { error in
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
                        self.commentDataModel.lists![sender.tag - 2].isHit = false
                        self.commentDataModel.lists![sender.tag - 2].hitCount -= 1
                        let commentItem = self.commentDataModel.lists![sender.tag - 2]
                        
                        let cell = self.collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as! GTBookBigCommentCollectionViewCell
                        sender.zoomOut()
                        sender.isHidden = !commentItem.isHit
                        cell.noCommentBtn.isHidden = commentItem.isHit
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
    
    @objc private func filtrateBtnDidClicked(sender: UIButton) {
        let popoverVC = GTCommentFiltrateTableViewController(cellInfo: self.filterInfo)
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: 250, height: 200)
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
            let cell = self.collectionView.cellForItem(at: IndexPath(row: 1, section: 0)) as! GTCommentFiltrateCollectionViewcell
            cell.filtrateBtn.setTitle(info["selectedStr"] as? String, for: .normal)
            self.filterIndex = info["selectedIndex"] as! Int
            
            self.commentDataModel.lists!.removeAll()
            self.commentDataModel.count = 0
            self.offset = 0
            self.collectionView.reloadData()
            
            // 重新刷新评论内容
            self.collectionView.mj_footer?.beginRefreshing()
        }
    }
    
    // 处理编辑评论按钮点击事件
    @objc private func editCommentBtnDidClicked(sender: UIButton) {
        let vc = GTCommentNavigationController(rootViewController: GTBookCommentEditTableViewController(style: .plain, userId: self.userId, bookId: self.bookId, imgUrl: self.imgUrl))
        self.present(vc, animated: true)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.commentDataModel.count + 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookGradeCollectionViewCell", for: indexPath) as! GTBookGradeCollectionViewCell
            cell.gradeLab.text = String(format: "%.1f", self.bookScore)
            cell.numberLab.text = String(self.remarkCount) + "个评分"
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTCommentFiltrateCollectionViewcell", for: indexPath) as! GTCommentFiltrateCollectionViewcell
            cell.filtrateBtn.addTarget(self, action: #selector(filtrateBtnDidClicked(sender:)), for: .touchUpInside)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookBigCommentCollectionViewCell", for: indexPath) as! GTBookBigCommentCollectionViewCell
            
            let commentItem = self.commentDataModel.lists![indexPath.row - 2]
            cell.commentTitleLabel.text = commentItem.title
            cell.commentContentLabel.text = commentItem.content
            cell.starView.rating = Double(commentItem.score)
            cell.timeLabel.text = commentItem.remarkTime.timeIntervalChangeToTimeStr()
            cell.nicknameLabel.text = commentItem.nickName
            cell.imgView.sd_setImage(with: URL(string: commentItem.headUrl), placeholderImage: UIImage(named: "head_man"))
            
            cell.yesCommentBtn.setTitle(String(commentItem.hitCount), for: .normal)
            cell.noCommentBtn.setTitle(String(commentItem.hitCount), for: .normal)
            cell.noCommentBtn.isHidden = commentItem.isHit
            cell.yesCommentBtn.isHidden = !commentItem.isHit
            cell.noCommentBtn.tag = indexPath.row
            cell.yesCommentBtn.tag = indexPath.row
            cell.noCommentBtn.addTarget(self, action: #selector(noCommentBtnDidClicked(sender:)), for: .touchUpInside)
            cell.yesCommentBtn.addTarget(self, action: #selector(yesCommentBtnDidClicked(sender:)), for: .touchUpInside)
            
            return cell
        }
    }
}
