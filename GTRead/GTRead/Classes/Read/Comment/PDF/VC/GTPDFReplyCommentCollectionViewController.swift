//
//  GTPDFReplyCommentCollectionViewController.swift
//  GTRead
//
//  Created by Dev on 2022/1/6.
//

import Foundation
import UIKit

class GTPDFReplyCommentCollectionViewController: GTCollectionViewController {
    
    private var editCommentBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setupCollectionView()
    }
    
    private func setupNavigationBar() {
        
        self.navigationItem.title = "评论"
        
        editCommentBtn = UIButton(type: .custom)
        editCommentBtn.setImage(UIImage(named: "edit_comment"), for: .normal)
        editCommentBtn.addTarget(self, action: #selector(editCommentBtnDidClicked(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editCommentBtn)
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(GTPDFReplyCommentCollectionViewCell.self, forCellWithReuseIdentifier: "GTPDFReplyCommentCollectionViewCell")
        collectionView.register(GTPDFParentCommentCollectionViewCell.self, forCellWithReuseIdentifier: "GTPDFParentCommentCollectionViewCell")
    }
    
    // 处理编辑评论按钮点击事件
    @objc private func editCommentBtnDidClicked(sender: UIButton) {
        let vc = GTCommentNavigationController(rootViewController: GTPDFEdiCommentTableViewController(style: .plain))
        self.present(vc, animated: true)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTPDFParentCommentCollectionViewCell", for: indexPath) as! GTPDFParentCommentCollectionViewCell
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTPDFReplyCommentCollectionViewCell", for: indexPath) as! GTPDFReplyCommentCollectionViewCell
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTPDFParentCommentCollectionViewCell", for: indexPath) as! GTPDFParentCommentCollectionViewCell
            return cell
        }
    }
}
