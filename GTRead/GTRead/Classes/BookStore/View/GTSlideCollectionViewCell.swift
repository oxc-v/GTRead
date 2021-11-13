//
//  GTSlideCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2021/11/12.
//

import Foundation
import UIKit

import UIKit

class GTSlideCollectionViewCell: UICollectionViewCell {
    lazy var imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = contentView.bounds
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
