//
//  GTReadDetailTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/19.
//

import Foundation
import UIKit

class GTReadDetailTableViewCell: UITableViewCell {
    
    private var collectionView: UICollectionView!
    
    private let collectionViewCellTitle = ["时间", "专注度", "行数", "页数"]
    private let collectionViewCellImg = ["this_time", "this_concentration", "this_line", "this_page"]
    var dataModel: GTAnalyseDataModel? {
        didSet {
            if dataModel != nil {
                self.collectionView.reloadData()
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // CollectionView
        self.setupCollectionView()
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // CollectionView
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        collectionView.register(GTReadDetailCollectionViewCell.self, forCellWithReuseIdentifier: "GTReadDetailCollectionViewCell")
        self.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(GTViewMargin)
            make.left.equalToSuperview().offset(-GTViewMargin)
            make.top.equalToSuperview().offset(GTViewMargin - 30)
            make.bottom.equalToSuperview().offset(-GTViewMargin + 30)
        }
    }
}

extension GTReadDetailTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionViewCellTitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTReadDetailCollectionViewCell", for: indexPath) as! GTReadDetailCollectionViewCell
        
        var dataTxt: String = ""
        switch indexPath.row {
        case 0:
            dataTxt = String(dataModel?.hour ?? 0) + "时" + String(dataModel?.min ?? 0) + "分"
        case 1:
            dataTxt = String(format: "%.2f", (dataModel?.focus ?? 0) * 100) + "%"
        case 2:
            dataTxt = String(dataModel?.rows ?? 0)
        default:
            dataTxt = String(dataModel?.pages ?? 0)
        }
        cell.setupViewData(img: self.collectionViewCellImg[indexPath.row], dataTxt: dataTxt, titleTxt: self.collectionViewCellTitle[indexPath.row])
        
        return cell
    }
}

extension GTReadDetailTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
