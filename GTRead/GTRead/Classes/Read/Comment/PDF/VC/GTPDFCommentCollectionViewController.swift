//
//  GTPDFCommentCollectionViewController.swift
//  GTRead
//
//  Created by Dev on 2022/1/6.
//

import Foundation
import UIKit

class GTPDFCommentCollectionViewController: GTCollectionViewController {
    
    private var cancelBtn: UIButton!
    private var editCommentBtn: UIButton!
    
    private let filterInfo = ["最有帮助", "最少点赞", "最新发表"]
    private var test = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setupCollectionView()
        
        // 评论筛选值变化
        NotificationCenter.default.addObserver(self, selector: #selector(handleGTCommentFilterValueChangedNotification(notif:)), name: .GTCommentFilterValueChanged, object: nil)
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
        collectionView.backgroundColor = .white
        collectionView.register(GTCommentFiltrateCollectionViewcell.self, forCellWithReuseIdentifier: "GTCommentFiltrateCollectionViewcell")
        collectionView.register(GTPDFCommentCollectionViewCell.self, forCellWithReuseIdentifier: "GTPDFCommentCollectionViewCell")
    }
    
    // 取消按钮点击事件
    @objc private func cancelBtnDidClicked(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // 处理编辑评论按钮点击事件
    @objc private func editCommentBtnDidClicked(sender: UIButton) {
        let vc = GTCommentNavigationController(rootViewController: GTPDFEdiCommentTableViewController(style: .plain))
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
        }
    }
    
    @objc private func noCommentBtnDidClicked(sender: UIButton) {
        sender.zoomOut()
        sender.isHidden = true
        let cell = self.collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as! GTPDFCommentCollectionViewCell
        cell.yesCommentBtn.isHidden = false
        cell.yesCommentBtn.zoomIn()
        
        self.test[sender.tag - 1] = false
    }
    
    @objc private func yesCommentBtnDidClicked(sender: UIButton) {
        sender.zoomOut()
        sender.isHidden = true
        
        let cell = self.collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as! GTPDFCommentCollectionViewCell
        cell.noCommentBtn.isHidden = false
        cell.noCommentBtn.zoomIn()
        
        self.test[sender.tag - 1] = true
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.test.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTCommentFiltrateCollectionViewcell", for: indexPath) as! GTCommentFiltrateCollectionViewcell
            cell.filtrateBtn.addTarget(self, action: #selector(filtrateBtnDidClicked(sender:)), for: .touchUpInside)
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTPDFCommentCollectionViewCell", for: indexPath) as! GTPDFCommentCollectionViewCell
            cell.yesCommentBtn.isHidden = self.test[indexPath.row - 1]
            cell.noCommentBtn.isHidden = !(cell.yesCommentBtn.isHidden)
            cell.noCommentBtn.tag = indexPath.row
            cell.yesCommentBtn.tag = indexPath.row
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
        let vc = GTPDFReplyCommentCollectionViewController(collectionViewLayout: layout)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
