//
//  GTGTThumbnailGridViewController.swift
//  GTRead
//
//  Created by YangJie on 2021/4/21.
//

import UIKit
import PDFKit

private let reuseIdentifier = "GTThumbnailGridViewCell"

protocol GTThumbnailGridViewControllerDelegate: AnyObject {
    func thumbnailGridViewController(_ thumbnailGridViewController: GTThumbnailGridViewController, didSelectPage page: PDFPage)
}

class GTThumbnailGridViewController: UICollectionViewController {

    var pdfDocument: PDFDocument?
    private var finishedBtn: UIButton!
    weak var delegate: GTThumbnailGridViewControllerDelegate?
    let itemWidth: CGFloat = 210
    let itemHeight: CGFloat = 300
    let itemMargin: CGFloat = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "缩略图"
        self.collectionView.register(GTThumbnailCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.backgroundColor = .white
        
        finishedBtn = UIButton(type: .custom)
        finishedBtn.setTitle("完成", for: .normal)
        finishedBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        finishedBtn.setTitleColor(.systemBlue, for: .normal)
        finishedBtn.addTarget(self, action: #selector(finishedBtnDidClicked(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: finishedBtn)
    }
    
    // finishedBtn clicked
    @objc private func finishedBtnDidClicked(sender: UIButton) {
        sender.clickedAnimation(withDuration: 0.1, completion: { _ in
            self.dismiss(animated: true, completion: nil)
        })
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pdfDocument?.pageCount ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GTThumbnailCollectionViewCell
        
        if let page = pdfDocument?.page(at: indexPath.item) {
            let thumbnail = page.thumbnail(of: cell.bounds.size, for: PDFDisplayBox.cropBox)
            cell.image = thumbnail
            cell.pageLab.text = page.label
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let page = pdfDocument?.page(at: indexPath.item) {
            delegate?.thumbnailGridViewController(self, didSelectPage: page)
        }
    }
}

extension GTThumbnailGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemMargin
    }
}
