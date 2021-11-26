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
            make.right.equalToSuperview().offset(GTViewMargin)
            make.left.equalToSuperview().offset(-GTViewMargin)
            make.height.equalTo(70)
            make.top.equalToSuperview().offset(GTViewMargin - 10)
            make.bottom.equalToSuperview().offset(-GTViewMargin + 10)
        }
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set(newFrame) {
            var frame = newFrame
            let newWidth = 704 - GTViewMargin * 2
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

extension GTBookPublicationInfoTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookPublicationInfoCollectionViewCell", for: indexPath) as! GTBookPublicationInfoCollectionViewCell
            cell.titleLabel.text = "类型"
            cell.imgView.isHidden = false
            cell.imgView.image = UIImage(named: "type_education")
            cell.contentLabel.isHidden = false
            cell.subtitleLabel.text = "文学"
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookPublicationInfoCollectionViewCell", for: indexPath) as! GTBookPublicationInfoCollectionViewCell
            cell.titleLabel.text = "发行日期"
            cell.contentLabel.text = "2021年"
            cell.subtitleLabel.text = "11月27日"
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookPublicationInfoCollectionViewCell", for: indexPath) as! GTBookPublicationInfoCollectionViewCell
            cell.titleLabel.text = "长度"
            cell.contentLabel.text = "1056"
            cell.subtitleLabel.text = "页"
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookPublicationInfoCollectionViewCell", for: indexPath) as! GTBookPublicationInfoCollectionViewCell
            cell.titleLabel.text = "出版社"
            cell.contentLabel.text = "清华大学计算机研究院附属科室405"
            cell.contentLabel.font = UIFont.systemFont(ofSize: 13)
            cell.subtitleLabel.isHidden = true
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookPublicationInfoCollectionViewCell", for: indexPath) as! GTBookPublicationInfoCollectionViewCell
            cell.titleLabel.text = "语言"
            cell.contentLabel.text = "CN"
            cell.subtitleLabel.text = "简体中文"
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookPublicationInfoCollectionViewCell", for: indexPath) as! GTBookPublicationInfoCollectionViewCell
            cell.titleLabel.text = "大小"
            cell.contentLabel.text = "46.7"
            cell.subtitleLabel.text = "M"
            return cell
        }
    }
}
extension GTBookPublicationInfoTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 3 {
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
