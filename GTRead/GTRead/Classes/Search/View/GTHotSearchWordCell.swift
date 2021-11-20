//
//  GTHotSearchWordCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/17.
//

import Foundation
import UIKit

class GTHotSearchWordCell: UITableViewCell {

    private let itemMargin = 20.0
    private let itemWidth = (UIScreen.main.bounds.width - 40 - 20) / 2.0
    private let itemHeight = GTCustomPlainCellHeight
    private let cellWidth: CGFloat
    var collectionView: UICollectionView!
    var dataModel: GTCustomPlainTableViewCellDataModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        cellWidth = UIScreen.main.bounds.width - 40
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        collectionView = GTDynamicCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.register(GTCustomPlainCollectionViewCell.self, forCellWithReuseIdentifier: "GTCustomPlainCollectionViewCell")
        self.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.width.equalTo(cellWidth)
            make.left.equalTo(20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        collectionView.layoutIfNeeded()
        collectionView.frame = CGRect(x: 0, y: 0, width: targetSize.width, height: 1)
        
        let size = CGSize(width: cellWidth, height: collectionView.collectionViewLayout.collectionViewContentSize.height)
        return size
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.dataModel = nil
    }
}

extension GTHotSearchWordCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = dataModel?.count ?? 0
        let itemCount = (count == -1 ? 0 : count)
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTCustomPlainCollectionViewCell", for: indexPath) as! GTCustomPlainCollectionViewCell
        if let itemDataModel = dataModel?.lists?[indexPath.row] {
            cell.dataModel = itemDataModel
        }
        let itemCount = dataModel?.count ?? 0
        if indexPath.row == itemCount - 1 || indexPath.row == itemCount - 2 {
            cell.isHideLine = true
        }
        cell.tableView.reloadData()
        return cell
    }
}

extension GTHotSearchWordCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
