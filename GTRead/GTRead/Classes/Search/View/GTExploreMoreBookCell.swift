//
//  GTExploreMoreBookCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/16.
//

import Foundation
import UIKit

class GTExploreMoreBookCell: UITableViewCell {
    
    private let itemMargin = 30.0
    private let itemWidth: CGFloat
    private let itemHeight = 120.0
    private let cellWidth: CGFloat
    
    var collectionView: UICollectionView!
    var dataModel: GTCustomComplexTableViewCellDataModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        cellWidth = UIScreen.main.bounds.width - GTViewMargin * 2
        itemWidth = (cellWidth - itemMargin) / 2.0
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        collectionView = GTDynamicCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.register(GTCustomComplexCollectionViewCell.self, forCellWithReuseIdentifier: "GTCustomComplexCollectionViewCell")
        self.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.width.equalToSuperview()
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
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set(newFrame) {
            var frame = newFrame
            let newWidth = UIScreen.main.bounds.width - GTViewMargin * 2
            let space = (frame.width - newWidth) / 2
            frame.size.width = newWidth
            frame.origin.x += space
            super.frame = frame
        }
    }
}

extension GTExploreMoreBookCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = dataModel?.count ?? 0
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTCustomComplexCollectionViewCell", for: indexPath) as! GTCustomComplexCollectionViewCell
        cell.cellIndex = indexPath.row
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
extension GTExploreMoreBookCell: UICollectionViewDelegateFlowLayout {
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
