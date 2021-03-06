//
//  GTBookPublicationInfoViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/26.
//

import Foundation
import UIKit

class GTBookPublicationInfoTableViewCell: UITableViewCell {
    
    private var collectionView: UICollectionView!
    
    var dataModel: GTBookDataModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GTBookPublicationInfoCollectionViewCell.self, forCellWithReuseIdentifier: "GTBookPublicationInfoCollectionViewCell")
        self.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(70)
            make.top.equalToSuperview().offset(GTViewMargin - 10)
            make.bottom.equalToSuperview().offset(-GTViewMargin + 10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GTBookPublicationInfoTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookPublicationInfoCollectionViewCell", for: indexPath) as! GTBookPublicationInfoCollectionViewCell
            
            let type = self.dataModel!.baseInfo.bookType
            let index = type < bookTypeStr.count ? type : 0
            
            cell.titleLabel.text = "??????"
            cell.imgView.isHidden = false
            cell.imgView.image = UIImage(named: "bookType_" + String(index))
            cell.contentLabel.isHidden = false
            cell.subtitleLabel.text = bookTypeStr[index]
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookPublicationInfoCollectionViewCell", for: indexPath) as! GTBookPublicationInfoCollectionViewCell
            cell.titleLabel.text = "????????????"
            cell.contentLabel.text = "2022???"
            cell.subtitleLabel.text = "1???6???"
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookPublicationInfoCollectionViewCell", for: indexPath) as! GTBookPublicationInfoCollectionViewCell
            cell.titleLabel.text = "??????"
            cell.contentLabel.text = String(self.dataModel!.baseInfo.bookPage)
            cell.subtitleLabel.text = "???"
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookPublicationInfoCollectionViewCell", for: indexPath) as! GTBookPublicationInfoCollectionViewCell
            cell.titleLabel.text = "?????????"
            cell.contentLabel.text = self.dataModel!.baseInfo.publishHouse
            cell.contentLabel.font = UIFont.systemFont(ofSize: 13)
            cell.subtitleLabel.isHidden = true
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookPublicationInfoCollectionViewCell", for: indexPath) as! GTBookPublicationInfoCollectionViewCell
            cell.titleLabel.text = "??????"
            cell.contentLabel.text = "CN"
            cell.subtitleLabel.text = "????????????"
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookPublicationInfoCollectionViewCell", for: indexPath) as! GTBookPublicationInfoCollectionViewCell
            cell.titleLabel.text = "??????"
            cell.contentLabel.text = String(format: "%.1f", self.dataModel!.downInfo.fileSize / 1024 / 1024)
            cell.subtitleLabel.text = "M"
            return cell
        }
    }
}

extension GTBookPublicationInfoTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: 140, height: 70)
        } else if indexPath.row == 3 {
            return CGSize(width: 130, height: 70)
        } else {
            return CGSize(width: 110, height: 70)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
