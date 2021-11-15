//
//  GTDynamicCollectionView.swift
//  GTRead
//
//  Created by Dev on 2021/11/15.
//

import Foundation
import UIKit

class GTDynamicCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }
}
