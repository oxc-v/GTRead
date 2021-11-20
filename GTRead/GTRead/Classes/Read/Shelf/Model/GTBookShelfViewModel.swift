//
//  GTBookShelfViewModel.swift
//  GTRead
//
//  Created by YangJie on 2021/3/21.
//

import UIKit
import PDFKit
import SwiftEntryKit

class GTBookShelfViewModel: NSObject {
    
    let collectionView: UICollectionView
    let viewController: GTBaseViewController
    let kGTScreenWidth = UIScreen.main.bounds.width
    let KGTScreenHeight = UIScreen.main.bounds.height
    let itemMargin: CGFloat = 60
    let itemCountInRow = 4;
    var itemWidth: CGFloat = 0
    var itemHeight: CGFloat = 0
    var isEditing: Bool = false
    var isSeletedAll: Bool = false
    var seletedEvent: ((_ count: Int)->())?
    var dataModel: GTShelfBookModel?
    var books = [GTShelfBookItemModel]()
    var selectedBooks = [GTShelfBookItemModel]()
    
    init(viewController: GTBaseViewController,collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.viewController = viewController
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        itemWidth = floor((kGTScreenWidth - 16 * 6 - (CGFloat(itemCountInRow - 1) * itemMargin)) / CGFloat(itemCountInRow))
        itemHeight = floor(itemWidth * 1.55)
    }
    
    // 加载本地缓存
    func loadBookShelfData() {
        if GTNet.shared.networkAvailable() {
            self.createBookShelfData(refreshControl: nil)
        } else {
            if let obj: GTShelfBookModel = GTDiskCache.shared.getViewObject((UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "") + "_shelf_view") {
                self.dataModel = obj
                self.books.removeAll()
                if self.dataModel!.count != -1 {
                    for item in self.dataModel!.lists! {
                        self.books.append(item)
                    }
                    self.collectionView.reloadData()
                }
                self.viewController.hideActivityIndicatorView()
            }
        }
    }
    
    // 请求书架数据
    func createBookShelfData(refreshControl: UIRefreshControl?) {
        GTNet.shared.getShelfBook(failure: { json in
            refreshControl?.endRefreshing()
            self.viewController.hideActivityIndicatorView()
            if GTNet.shared.networkAvailable() {
                self.viewController.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.viewController.showNotificationMessageView(message: "网络连接不可用")
            }
        }, success: { json in
            refreshControl?.endRefreshing()
            self.viewController.hideActivityIndicatorView()
            self.books.removeAll()
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            if let dataModel = try? decoder.decode(GTShelfBookModel.self, from: data!) {
                self.dataModel = dataModel
                if dataModel.count != -1 {
                    for item in dataModel.lists! {
                        self.books.append(item)
                    }
                    
                    // 对书架数据进行缓存
                    GTDiskCache.shared.saveViewObject((UserDefaults.standard.string(forKey: UserDefaultKeys.AccountInfo.account) ?? "") + "_shelf_view", value: self.dataModel)
                }
                DispatchQueue.main .async {
                    self.collectionView.reloadData()
                }
            } else {
                self.viewController.showNotificationMessageView(message: "服务器数据错误")
            }
        })
    }
    
    // 开启编辑
    func startEditing(isEditIng: Bool) {
        selectedBooks.removeAll()
        self.isEditing = isEditIng
        self.collectionView.reloadData()
    }
    // 取消选中
    func cancelEditing() {
        self.isEditing = false
        self.isSeletedAll = false
        self.collectionView.reloadData()
    }
    // 选中全部
    func seletedAll() {
        selectedBooks.removeAll()
        selectedBooks = books
        
        self.isEditing = true
        self.isSeletedAll = true
        self.collectionView.reloadData()
        seletedEvent?(selectedBooks.count)
    }
    
    // 删除
    func deleteImages() {
        self.cancelEditing()
        self.collectionView.reloadData()
        
        // 请求删除书架书籍
        GTNet.shared.delShelfBook(books: self.selectedBooks, failure: {json in
            if GTNet.shared.networkAvailable() {
                self.viewController.showNotificationMessageView(message: "服务器连接中断")
            } else {
                self.viewController.showNotificationMessageView(message: "网络连接不可用")
            }
        }, success: { json in
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            let dataModel = try? decoder.decode(GTDelShelfBookModel.self, from: data!)
            
            if dataModel == nil {
                self.viewController.showNotificationMessageView(message: "服务器数据错误")
            } else if dataModel?.FailBookIds == nil {
                self.viewController.showNotificationMessageView(message: "书籍删除成功")
                self.viewController.showActivityIndicatorView()
                self.createBookShelfData(refreshControl: nil)
            } else {
                self.viewController.showNotificationMessageView(message: "个别书籍删除失败")
            }
        })
    }
    
}

extension GTBookShelfViewModel: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCollectioncell", for: indexPath) as! GTBookCollectionCell

        if self.books.count > indexPath.row {
            let book = self.books[indexPath.row]
            cell.updateData(imageURL: book.bookHeadUrl, title: book.bookName)
            if isEditing {
                cell.StartEdit()
                if isSeletedAll {
                    cell.hiddenRightImageView(hidden: false)
                }
            }else{
                cell.endEdit()
            }
        }
        return cell
    }
    
    // ----点击事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isEditing {
            let cell = collectionView.cellForItem(at: indexPath) as! GTBookCollectionCell
            cell.hiddenRightImageView(hidden: cell.selectedStatu)
            if cell.selectedStatu {
                // 选中
                selectedBooks.append((self.dataModel?.lists?[indexPath.row])!)
            }else{
                // 取消选中
                let book = self.dataModel?.lists?[indexPath.row]
                selectedBooks.removeAll(where: {$0.bookId == book?.bookId})
            }
            seletedEvent?(selectedBooks.count)
        } else{
            // 读取缓存
            let fileName = self.dataModel?.lists?[indexPath.row].bookId ?? ""
            if let url = GTDiskCache.shared.getPDF(fileName) {
                let vc = GTReadViewController(path: url, bookId: fileName)
                vc.hidesBottomBarWhenPushed = true;
                self.viewController.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = GTLoadPDFViewContrlloer(model: (self.dataModel?.lists?[indexPath.row])!)
                vc.hidesBottomBarWhenPushed = true;
                self.viewController.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension GTBookShelfViewModel: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemMargin
    }
}
