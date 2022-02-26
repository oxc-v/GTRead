//
//  GTBookReadMoreCollectionViewController.swift
//  GTRead
//
//  Created by Dev on 2022/1/5.
//

import Foundation
import UIKit
import SDWebImage
import MJRefresh

class GTBookReadMoreCollectionViewController: GTCollectionViewController {
    
    private let itemCountInRow = 4;
    private var itemWidth: CGFloat = 0
    private var itemHeight: CGFloat = 0
    private let itemMargin: CGFloat = 30
    
    private var offset = 0
    private let maxCount = 12
    private let bookType: GTBookType
    
    private var dataModel: GTBookListsDataModel?
    
    init(type: GTBookType, title: String, layout: UICollectionViewLayout) {
        self.bookType = type
        super.init(collectionViewLayout: layout)
        
        self.navigationItem.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setupCollectionView()
        
        // 加载书籍
        self.collectionView.mj_footer?.beginRefreshing()
        
        // 注册书本下载完毕通知
        NotificationCenter.default.addObserver(self, selector: #selector(downloadBookFinishedNotification(notification:)), name: .GTDownloadBookFinished, object: nil)
    }
    
    private func setupNavigationBar() {
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupCollectionView() {
        let footer = MJRefreshAutoNormalFooter()
        footer.setTitle("释放加载", for: .pulling)
        footer.setTitle("正在加载...", for: .refreshing)
        footer.setTitle("已经到底啦～", for: .noMoreData)
        footer.setRefreshingTarget(self, refreshingAction: #selector(refreshSearchData(refreshControl:)))
        collectionView.mj_footer = footer
        
        itemWidth = floor((UIScreen.main.bounds.width - 2 * GTViewMargin - (CGFloat(itemCountInRow - 1) * itemMargin)) / CGFloat(itemCountInRow))
        itemHeight = floor(itemWidth * 1.87)
        
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.register(GTBookReadMoreCollectionViewCell.self, forCellWithReuseIdentifier: "GTBookReadMoreCollectionViewCell")
    }
    
    // 获取某个类型的书籍
    @objc private func getBookListsForType() {
        GTNet.shared.getBookListsForType(type: self.bookType, offset: self.offset, count: self.maxCount, failure: { e in
            if GTNet.shared.networkAvailable() {
                self.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.showNotificationMessageView(message: "网络连接不可用")
            }
            self.collectionView.mj_footer?.endRefreshing()
        }, success: { json in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            if let dataModel = try? decoder.decode(GTBookListsDataModel.self, from: data!) {
                if dataModel.count > 0 {
                    if self.dataModel != nil {
                        for item in dataModel.lists! {
                            self.dataModel!.lists!.append(item)
                        }
                        self.offset += dataModel.lists!.count
                    } else {
                        self.dataModel = dataModel
                        self.offset += dataModel.lists!.count
                    }
                }
                
                if dataModel.count < self.maxCount {
                    self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    self.collectionView.mj_footer?.endRefreshing()
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } else {
                self.showNotificationMessageView(message: "服务器数据错误")
                self.collectionView.mj_footer?.endRefreshing()
            }
        })
    }
    
    // 书本下载完毕通知
    @objc private func downloadBookFinishedNotification(notification: Notification) {
        
        if self.tabBarController?.selectedIndex == 2 {
            if let dataModel = notification.userInfo?["dataModel"] as? GTBookDataModel {
                let fileName = dataModel.bookId
                if let url = GTDiskCache.shared.getPDF(fileName) {
                    self.dismiss(animated: true, completion: {
                        let vc = GTReadViewController(path: url, bookId: fileName)
                        vc.hidesBottomBarWhenPushed = true;
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                } else {
                    self.showNotificationMessageView(message: "文件打开失败")
                }
            }
        }
    }
    
    // 上拉加载操作
    @objc private func refreshSearchData(refreshControl: UIRefreshControl) {
        self.getBookListsForType()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataModel?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookReadMoreCollectionViewCell", for: indexPath) as! GTBookReadMoreCollectionViewCell
        cell.titleLab.text = self.dataModel!.lists![indexPath.row].baseInfo.bookName
        cell.authorLab.text = self.dataModel!.lists![indexPath.row].baseInfo.authorName
        cell.imgView.sd_setImage(with: URL(string: self.dataModel!.lists![indexPath.row].downInfo.bookHeadUrl), placeholderImage: UIImage(named: "book_placeholder"))
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 读取缓存
        let fileName = self.dataModel?.lists?[indexPath.row].bookId ?? ""
        if let url = GTDiskCache.shared.getPDF(fileName) {
            let vc = GTReadViewController(path: url, bookId: fileName)
            vc.hidesBottomBarWhenPushed = true;
            
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = GTBaseNavigationViewController(rootViewController: GTBookDetailTableViewController((self.dataModel?.lists?[indexPath.row])!))
            self.present(vc, animated: true)
        }
    }
}

extension GTBookReadMoreCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
