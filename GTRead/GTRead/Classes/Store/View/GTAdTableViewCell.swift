//
//  GTAdTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/23.
//

import Foundation
import UIKit
import SDWebImage
import UIImageColors

class GTAdTableViewCell: UITableViewCell {
    
    private var collectionView: UICollectionView!
    private var separatorView: UIView!
    var viewController: GTBookStoreTableViewController?
    
    var dataModel: GTBookStoreADBookDataModel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        dataModel = GTUserDefault.shared.data(forKey: GTUserDefaultKeys.GTShelfDataModel)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
    
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
        collectionView.register(GTAdCollectionViewCell.self, forCellWithReuseIdentifier: "GTAdCollectionViewCell")
        self.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.top.equalTo(separatorView.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
}

extension GTAdTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.dataModel.lists!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTAdCollectionViewCell", for: indexPath) as! GTAdCollectionViewCell
        cell.titleLabel.text = self.dataModel.lists![indexPath.section].bookTitle
        cell.imgView.sd_setImage(with: URL(string: self.dataModel.lists![indexPath.section].downInfo.bookHeadUrl), placeholderImage: UIImage(named: "book_placeholder"))
        cell.imgView.image?.getColors(quality: .high) { colors in
            guard let colors = colors else { return }
            
            cell.bgView.backgroundColor = colors.background
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GTAdCollectionViewCell
        cell.clickedAnimation(withDuration: 0.1, completion: { _ in
            let vc =  GTBaseNavigationViewController(rootViewController: GTBookDetailTableViewController(self.dataModel!.lists![indexPath.section]))
            self.viewController?.present(vc, animated: true)
        })
    }
}

extension GTAdTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 370, height: 310)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
}
