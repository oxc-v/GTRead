//
//  GTReadChartTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/19.
//

import Foundation
import UIKit

class GTReadChartTableViewCell: UITableViewCell {
    
    private var collectionView: UICollectionView!

//    private var item = [Int]()
    private let itemCount = 3;
    private let itemCountInRow = 2;
    private var itemWidth: CGFloat = 0
    private var itemHeight: CGFloat = 0
    private let itemMargin: CGFloat = 50
    
    var dataModel: GTAnalyseDataModel? {
        didSet {
//            if dataModel?.lists != nil {
//                item.append(0)
//            }
//            if dataModel?.speedPoints != nil {
//                item.append(1)
//            }
//            if dataModel?.scatterDiagram != nil {
//                item.append(2)
//            }
            collectionView.reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        itemWidth = floor((UIScreen.main.bounds.width - 2 * GTViewMargin - (CGFloat(itemCountInRow - 1) * itemMargin)) / CGFloat(itemCountInRow))
        itemHeight = floor(itemWidth * 1.05)

        // CollectionView
        self.setupCollectionView()
    }
    
    // CollectionView
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 30, left: GTViewMargin, bottom: 30, right: GTViewMargin)
        collectionView = GTDynamicCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GTReadSpeedChartCollectionViewCell.self, forCellWithReuseIdentifier: "GTReadSpeedChartCollectionViewCell")
        collectionView.register(GTReadTimeChartCollectionViewCell.self, forCellWithReuseIdentifier: "GTReadTimeChartCollectionViewCell")
        collectionView.register(GTReadBehaviourChartCollectionViewCell.self, forCellWithReuseIdentifier: "GTReadBehaviourChartCollectionViewCell")
        self.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(GTViewMargin)
            make.left.equalToSuperview().offset(-GTViewMargin)
        }
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
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        collectionView.layoutIfNeeded()
        collectionView.frame = CGRect(x: 0, y: 0, width: targetSize.width, height: 1)
        
        let size = CGSize(width: targetSize.width, height: collectionView.collectionViewLayout.collectionViewContentSize.height)
        return size
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GTReadChartTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTReadTimeChartCollectionViewCell", for: indexPath) as! GTReadTimeChartCollectionViewCell
            if self.dataModel != nil {
                cell.updateWithData(model: self.dataModel!)
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTReadSpeedChartCollectionViewCell", for: indexPath) as! GTReadSpeedChartCollectionViewCell
            if self.dataModel != nil {
                cell.updateWithData(model: self.dataModel!)
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTReadBehaviourChartCollectionViewCell", for: indexPath) as! GTReadBehaviourChartCollectionViewCell
            if self.dataModel != nil {
                cell.updateWithData(model: self.dataModel!)
            }
            return cell
        }
       
    }
}

extension GTReadChartTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.row {
        case 0:
            return CGSize(width: UIScreen.main.bounds.width - 2 * GTViewMargin, height: 380)
        case 1, 2:
            return CGSize(width: itemWidth, height: itemHeight)
        default:
            return CGSize.zero
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.itemMargin
    }
}
