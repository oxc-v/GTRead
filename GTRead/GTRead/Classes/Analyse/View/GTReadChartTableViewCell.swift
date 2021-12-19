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
    
    private var collectionViewCellHeaderTxt = [String]()
    
    var dataModel: GTAnalyseDataModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if dataModel?.lists != nil {
            self.collectionViewCellHeaderTxt.append("阅读时间")
        }
        if dataModel?.speedPoints != nil {
            self.collectionViewCellHeaderTxt.append("视线速度")
        }
        if dataModel?.scatterDiagram != nil {
            self.collectionViewCellHeaderTxt.append("视线特征")
        }
        
        // CollectionView
        self.setupCollectionView()
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
        
        collectionView.register(GTReadSpeedChartCollectionViewCell.self, forCellWithReuseIdentifier: "GTReadSpeedChartCollectionViewCell")
        collectionView.register(GTReadBehaviourChartCollectionViewCell.self, forCellWithReuseIdentifier: "GTReadBehaviourChartCollectionViewCell")
        collectionView.register(GTReadTimeChartCollectionViewCell.self, forCellWithReuseIdentifier: "GTReadTimeChartCollectionViewCell")
        
        self.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(GTViewMargin)
            make.left.equalToSuperview().offset(-GTViewMargin)
            make.top.equalToSuperview().offset(GTViewMargin - 30)
            make.bottom.equalToSuperview().offset(-GTViewMargin + 30)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GTReadChartTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionViewCellHeaderTxt.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTReadTimeChartCollectionViewCell", for: indexPath) as! GTReadTimeChartCollectionViewCell
            cell.titleLabel.text = self.collectionViewCellHeaderTxt[indexPath.row]
            if self.dataModel != nil {
                cell.updateWithData(model: self.dataModel!)
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTReadSpeedChartCollectionViewCell", for: indexPath) as! GTReadSpeedChartCollectionViewCell
            cell.titleLabel.text = self.collectionViewCellHeaderTxt[indexPath.row]
            if self.dataModel != nil {
                cell.updateWithData(model: self.dataModel!)
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTReadBehaviourChartCollectionViewCell", for: indexPath) as! GTReadBehaviourChartCollectionViewCell
            cell.titleLabel.text = self.collectionViewCellHeaderTxt[indexPath.row]
            if self.dataModel != nil {
                cell.updateWithData(model: self.dataModel!)
            }
            return cell
        }
       
    }
}

extension GTReadChartTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 310)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
