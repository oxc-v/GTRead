//
//  GTCommentFiltrateCollectionViewcell.swift
//  GTRead
//
//  Created by Dev on 2022/1/3.
//

import Foundation
import UIKit

class GTCommentFiltrateCollectionViewcell: UICollectionViewCell {
    
    var filtrateBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        self.contentView.backgroundColor = .white
        
        filtrateBtn = UIButton()
        filtrateBtn.setTitle("最有帮助", for: .normal)
        filtrateBtn.setTitleColor(.black, for: .normal)
        filtrateBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        filtrateBtn.setImage(UIImage(named: "bottom_>"), for: .normal)
        filtrateBtn.imageView?.contentMode = .scaleAspectFit
        filtrateBtn.contentVerticalAlignment = .center
        filtrateBtn.semanticContentAttribute = .forceRightToLeft
        self.contentView.addSubview(filtrateBtn)
        filtrateBtn.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.height.equalTo(60)
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 60)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
