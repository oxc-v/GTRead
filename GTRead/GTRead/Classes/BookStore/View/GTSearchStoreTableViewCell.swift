//
//  GTSearchStoreTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/15.
//

import Foundation
import UIKit

class GTSearchStoreTableViewCell: UITableViewCell {
    
    private var recommendBookNameView: GTDynamicCollectionView!
    private var recommendBookNameTitleLable: UILabel!
    private var hotBookTitleLable: UILabel!
    private var hotBooksView = [GTHotSearchBookView]()
    
    private var testData = ["斗破苍穹", "完美世界", "星辰变", "斗罗大陆", "镜·双城", "灵域", "凡人修仙转", "灵剑尊", "逆剑狂神", "大唐扫把星", "太古剑帝诀", "万界剑祖", "盗墓笔记", "万古极皇"]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 推荐书名区域
        self.setupRecommendBookNameView()
        // 热搜书籍区域
        self.setupHotBookView()
    }
    
    // 推荐书名区域
    private func setupRecommendBookNameView() {
        recommendBookNameTitleLable = UILabel()
        recommendBookNameTitleLable.text = "搜索发现"
        recommendBookNameTitleLable.textAlignment = .left
        recommendBookNameTitleLable.font = UIFont.systemFont(ofSize: 13)
        recommendBookNameTitleLable.textColor = UIColor(hexString: "#b4b4b4")
        self.addSubview(recommendBookNameTitleLable)
        recommendBookNameTitleLable.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(30)
        }
        
        recommendBookNameView = GTDynamicCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        recommendBookNameView.backgroundColor = .white
        recommendBookNameView.delegate = self
        recommendBookNameView.dataSource = self
        recommendBookNameView.isScrollEnabled = false
        recommendBookNameView.register(GTSearchStoreCollectionViewCell.self, forCellWithReuseIdentifier: "GTSearchStoreCollectionViewCell")
        self.addSubview(recommendBookNameView)
        recommendBookNameView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(recommendBookNameTitleLable.snp.bottom).offset(10)
        }
    }
    
    // 热搜书籍区域
    private func setupHotBookView() {
        hotBookTitleLable = UILabel()
        hotBookTitleLable.text = "热搜书籍"
        hotBookTitleLable.textAlignment = .left
        hotBookTitleLable.font = UIFont.systemFont(ofSize: 13)
        hotBookTitleLable.textColor = UIColor(hexString: "#b4b4b4")
        self.addSubview(hotBookTitleLable)
        hotBookTitleLable.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(recommendBookNameView.snp.bottom).offset(30)
        }
        
        var tmpView: UIView = hotBookTitleLable
        for i in 1...8 {
            let view = GTHotSearchBookView()
            view.numberImgView.image = UIImage(named: "hot_" + String(i))
            view.bookImgView.image = UIImage(named: "test2")
            view.bookNameLable.text = "斗破苍穹" + String(i)
            view.bookDetailLabel.text = "这里是属于斗气的世界，没有花俏艳丽的魔法，有的，仅仅是繁衍到巅峰的斗气！"
            view.clipsToBounds = true
            switch i {
            case 1, 2, 3:
                view.hotBookImgView.isHidden = false
            default:
                view.hotBookImgView.isHidden = true
            }
            hotBooksView.append(view)
            self.addSubview(view)
            view.snp.makeConstraints { make in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(100)
                make.top.equalTo(tmpView.snp.bottom).offset(10)
            }
            tmpView = view
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        recommendBookNameView.layoutIfNeeded()
        recommendBookNameView.frame = CGRect(x: 0, y: 0, width: targetSize.width , height: 1)
        let size = CGSize(width: UIScreen.main.bounds.width, height: recommendBookNameView.collectionViewLayout.collectionViewContentSize.height + recommendBookNameTitleLable.frame.size.height + hotBookTitleLable.frame.size.height + 70 + 880)
        return size
    }
}

// UICollectionView
extension GTSearchStoreTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTSearchStoreCollectionViewCell", for: indexPath) as! GTSearchStoreCollectionViewCell
        cell.titleBtn.setTitle(testData[indexPath.row], for: .normal)
        switch indexPath.row {
        case 0, 1, 2:
            cell.imageView.isHidden = false
        default:
            cell.imageView.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}

// UICollectionView
extension GTSearchStoreTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.text = testData[indexPath.item]
        label.sizeToFit()
        
        var size: CGSize
        let width = label.frame.width > searStoreCollectViewCellBtnMaxWidth ? searStoreCollectViewCellBtnMaxWidth : label.frame.width
        switch indexPath.row {
        case 0, 1, 2:
            size = CGSize(width: width + 20 + 25, height: 32)
        default:
            size = CGSize(width: width + 14, height: 32)
        }
        
        return size
    }
}
