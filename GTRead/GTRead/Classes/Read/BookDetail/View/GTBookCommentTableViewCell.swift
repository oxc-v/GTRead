//
//  GTBookCommentTableViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/12/30.
//

import Foundation
import UIKit

class GTBookCommentTableViewCell: UITableViewCell {
    
    private var titleLabel: UILabel!
    private var readMoreBtn: UIButton!
    private var collectionView: UICollectionView!
    var viewController: UIViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupView()
    }
    
    private func setupView() {
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.text = "用户评论"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(GTViewMargin - 10)
            make.left.equalTo(GTViewMargin)
            make.width.lessThanOrEqualTo(80)
            make.height.equalTo(20)
        }
        
        readMoreBtn = UIButton()
        readMoreBtn.setTitle("查看更多", for: .normal)
        readMoreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        readMoreBtn.setTitleColor(.black, for: .normal)
        readMoreBtn.setImage(UIImage(named: "right_>"), for: .normal)
        readMoreBtn.semanticContentAttribute = .forceRightToLeft
        readMoreBtn.contentHorizontalAlignment = .right
        readMoreBtn.addTarget(self, action: #selector(readMoreBtnDidClicked), for: .touchUpInside)
        self.contentView.addSubview(readMoreBtn)
        readMoreBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(GTViewMargin - 10)
            make.left.equalTo(titleLabel.snp.right)
            make.right.equalTo(-GTViewMargin)
            make.height.equalTo(20)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.contentInset = UIEdgeInsets(top: 0, left: GTViewMargin, bottom: 0, right: 0)
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GTBookSmallCommentCollectionViewCell.self, forCellWithReuseIdentifier: "GTBookSmallCommentCollectionViewCell")
        self.contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(150)
            make.top.equalTo(titleLabel.snp.bottom).offset(GTViewMargin - 10)
            make.bottom.equalToSuperview().offset(-GTViewMargin + 10)
        }
    }
    
    // 查看更多评论
    @objc private func readMoreBtnDidClicked() {
        let layout = GTCommentCollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: GTViewMargin, bottom: 0, right: GTViewMargin)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        
        let vc = GTBookCommentCollectionViewController(collectionViewLayout: layout)
        
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GTBookCommentTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookSmallCommentCollectionViewCell", for: indexPath) as! GTBookSmallCommentCollectionViewCell

        return cell
    }
}

extension GTBookCommentTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 280, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
}
