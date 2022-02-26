//
//  GTRankingListTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/25.
//

import Foundation
import UIKit

class GTRankingListTableViewCell: UITableViewCell {
    
    private var collectionView: UICollectionView!
    private var separatorView: UIView!
    
    var viewController: GTBookStoreTableViewController?
    
    private var headerText = [String]()
    private var bookListsDataModel = [GTBookListsDataModel]()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupCollectionView()
        self.getRankingLists()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        
        separatorView = UIView()
        separatorView.backgroundColor = UIColor(hexString: "#cacacc")
        self.contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.top.equalToSuperview()
            make.left.equalTo(GTViewMargin)
            make.right.equalTo(-GTViewMargin)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        collectionView.register(GTRankingListCollectionViewCell.self, forCellWithReuseIdentifier: "GTRankingListCollectionViewCell")
        self.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.top.equalTo(separatorView.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func getRankingLists() {
        for i in 0..<GTBookType.allCases.count {
            GTNet.shared.getBookListsForType(type: GTBookType.allCases[i], offset: 0, count: 3, failure: { e in
                if GTNet.shared.networkAvailable() {
                    self.viewController?.showNotificationMessageView(message: "服务器连接中断")
                } else {
                    self.viewController?.showNotificationMessageView(message: "网络连接不可用")
                }
            }, success: { json in
                let data = try? JSONSerialization.data(withJSONObject: json, options: [])
                let decoder = JSONDecoder()
                if let dataModel = try? decoder.decode(GTBookListsDataModel.self, from: data!) {
                    if dataModel.count == 3 {
                        self.headerText.append(bookTypeStr[i])
                        self.bookListsDataModel.append(dataModel)
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                } else {
                    self.viewController?.showNotificationMessageView(message: "服务器数据错误")
                }
            })
        }
    }
}

extension GTRankingListTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.headerText.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTRankingListCollectionViewCell", for: indexPath) as! GTRankingListCollectionViewCell
        cell.dataModel = self.bookListsDataModel[indexPath.row]
        cell.viewController = self.viewController
        cell.headerText = self.headerText[indexPath.row]
        return cell
    }
}

extension GTRankingListTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 360, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
