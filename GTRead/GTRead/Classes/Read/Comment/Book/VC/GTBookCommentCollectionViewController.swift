//
//  GTBookCommentCollectionViewController.swift
//  GTRead
//
//  Created by Dev on 2022/1/2.
//

import Foundation
import UIKit

class GTBookCommentCollectionViewController: GTCollectionViewController {
    
    private var editCommentBtn: UIButton!
    private var test = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
    private let filterInfo = ["最有帮助", "最高评价", "最低评价", "最新发表"]
    
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
        self.collectionView.contentInsetAdjustmentBehavior = .always
        self.collectionView.backgroundColor = .white
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.register(GTBookGradeCollectionViewCell.self, forCellWithReuseIdentifier: "GTBookGradeCollectionViewCell")
        self.collectionView.register(GTCommentFiltrateCollectionViewcell.self, forCellWithReuseIdentifier: "GTCommentFiltrateCollectionViewcell")
        self.collectionView.register(GTBookBigCommentCollectionViewCell.self, forCellWithReuseIdentifier: "GTBookBigCommentCollectionViewCell")
    }
    
    @objc private func noCommentBtnDidClicked(sender: UIButton) {
        sender.zoomOut()
        sender.isHidden = true
        
        let cell = self.collectionView.cellForItem(at: IndexPath(row: sender.tag + 2, section: 0)) as! GTBookBigCommentCollectionViewCell
        cell.yesCommentBtn.isHidden = false
        cell.yesCommentBtn.zoomIn()
        
        self.test[sender.tag] = false
    }
    
    @objc private func yesCommentBtnDidClicked(sender: UIButton) {
        sender.zoomOut()
        sender.isHidden = true
        
        let cell = self.collectionView.cellForItem(at: IndexPath(row: sender.tag + 2, section: 0)) as! GTBookBigCommentCollectionViewCell
        cell.noCommentBtn.isHidden = false
        cell.noCommentBtn.zoomIn()
        
        self.test[sender.tag] = true
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
        }
    }
    
    // 处理编辑评论按钮点击事件
    @objc private func editCommentBtnDidClicked(sender: UIButton) {
        let vc = GTCommentNavigationController(rootViewController: GTBookCommentEditTableViewController(style: .plain))
        self.present(vc, animated: true)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return test.count + 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookGradeCollectionViewCell", for: indexPath) as! GTBookGradeCollectionViewCell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTCommentFiltrateCollectionViewcell", for: indexPath) as! GTCommentFiltrateCollectionViewcell
            cell.filtrateBtn.addTarget(self, action: #selector(filtrateBtnDidClicked(sender:)), for: .touchUpInside)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookBigCommentCollectionViewCell", for: indexPath) as! GTBookBigCommentCollectionViewCell
            cell.yesCommentBtn.isHidden = self.test[indexPath.row - 2]
            cell.noCommentBtn.isHidden = !(cell.yesCommentBtn.isHidden)
            cell.noCommentBtn.tag = indexPath.row - 2
            cell.yesCommentBtn.tag = indexPath.row - 2
            cell.noCommentBtn.addTarget(self, action: #selector(noCommentBtnDidClicked(sender:)), for: .touchUpInside)
            cell.yesCommentBtn.addTarget(self, action: #selector(yesCommentBtnDidClicked(sender:)), for: .touchUpInside)
            
            return cell
        }
    }
}
