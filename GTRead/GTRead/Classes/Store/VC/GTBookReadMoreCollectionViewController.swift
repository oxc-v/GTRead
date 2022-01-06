//
//  GTBookReadMoreCollectionViewController.swift
//  GTRead
//
//  Created by Dev on 2022/1/5.
//

import Foundation
import UIKit
import SDWebImage

class GTBookReadMoreCollectionViewController: GTCollectionViewController {
    
    private let itemCountInRow = 4;
    private var itemWidth: CGFloat = 0
    private var itemHeight: CGFloat = 0
    private let itemMargin: CGFloat = 30
    
    init(title: String, layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        
        self.navigationItem.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setupCollectionView()
    }
    
    private func setupNavigationBar() {
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupCollectionView() {
        
        itemWidth = floor((UIScreen.main.bounds.width - 2 * GTViewMargin - (CGFloat(itemCountInRow - 1) * itemMargin)) / CGFloat(itemCountInRow))
        itemHeight = floor(itemWidth * 1.87)
        
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.register(GTBookReadMoreCollectionViewCell.self, forCellWithReuseIdentifier: "GTBookReadMoreCollectionViewCell")
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GTBookReadMoreCollectionViewCell", for: indexPath) as! GTBookReadMoreCollectionViewCell
        cell.titleLab.text = "斗破苍穹"
        cell.authorLab.text = "天蚕土豆"
        cell.imgView.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: "book_placeholder"))
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension GTBookReadMoreCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
