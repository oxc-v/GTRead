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
    let itemMargin: CGFloat = 32
    let itemCountInRow = 4;
    var imageURLs = [String]()
    var itemWidth: CGFloat = 0
    var itemHeight: CGFloat = 0
    var isEditing: Bool = false
    var isSeletedAll: Bool = false
    var seletedImageURLs = [String]()
    var selectedBookId = [String]()
    var seletedEvent: ((_ count: Int)->())?
    var dataModel: GTShelfBookModel?
    
    
    init(viewController: GTBaseViewController,collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.viewController = viewController
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    func createBookShelfData(refreshControl: UIRefreshControl) {
        
        var width = kGTScreenWidth - 16 * 6 - (CGFloat(itemCountInRow - 1) * itemMargin)
        
        width = floor(width/CGFloat(itemCountInRow))
        
        let height = floor(width * 1.45)
        
        itemWidth = width
        itemHeight = height
        
        GTNet.shared.getShelfBook(failure: { json in
            refreshControl.endRefreshing()
            self.viewController.showNotificationMessageView(message: "获取书架数据失败")
        }, success: { json in
            refreshControl.endRefreshing()
            self.imageURLs.removeAll()
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = JSONDecoder()
            let dataModel = try! decoder.decode(GTShelfBookModel.self, from: data!)
            self.dataModel = dataModel
            if dataModel.count != -1 {
                for item in dataModel.lists! {
                    self.imageURLs.append(item.bookHeadUrl)
                }
                self.collectionView.reloadData()
            }
        })
    }
    
    // 开启编辑
    func startEditing(isEditIng: Bool) {
        self.isEditing = isEditIng
        self.collectionView.reloadData()
    }
    // 取消选中
    func cancelEditing() {
        seletedImageURLs.removeAll()
        selectedBookId.removeAll()
        self.isEditing = false
        self.isSeletedAll = false
        self.collectionView.reloadData()
    }
    // 选中全部
    func seletedAll() {
        seletedImageURLs.removeAll()
        seletedImageURLs = imageURLs
        
        for i in 0..<(self.dataModel?.lists?.count ?? 0) {
            selectedBookId.append(self.dataModel?.lists?[i].bookId ?? "")
        }
        
        self.isEditing = true
        self.isSeletedAll = true
        self.collectionView.reloadData()
        seletedEvent?(seletedImageURLs.count)
    }
    
    // 删除
    func deleteImages() {
        imageURLs = imageURLs.filter({!seletedImageURLs.contains($0)})
        self.cancelEditing()
        self.collectionView.reloadData()
        
        GTNet.shared.delShelfBook(bookIds: self.selectedBookId, failure: {json in }) { json in
            
        }
    }
    
}

extension GTBookShelfViewModel: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCollectioncell", for: indexPath) as! GTBookCollectionCell
        if self.imageURLs.count > indexPath.row {
            let imageURL = self.imageURLs[indexPath.row]
            cell.updateData(imageURL: imageURL, title: (self.dataModel?.lists?[indexPath.row].bookName) ?? "")
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
                seletedImageURLs.append(imageURLs[indexPath.row])
                selectedBookId.append(self.dataModel?.lists?[indexPath.row].bookId ?? "")
            }else{
                // 取消选中
                let image = imageURLs[indexPath.row]
                let bookId = self.dataModel?.lists?[indexPath.row].bookId ?? ""
                seletedImageURLs.removeAll(where: {$0 == image})
                selectedBookId.removeAll(where: {$0 == bookId})
            }
            seletedEvent?(seletedImageURLs.count)
        } else{
            // 读取缓存
            let fileName = self.dataModel?.lists?[indexPath.row].bookId ?? ""
            if GTDiskCache.sharedCachePDF.isExist(fileName) {
                let vc = GTReadViewController(path: URL(fileURLWithPath: GTDiskCache.sharedCachePDF.getFileURL(fileName)))
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
