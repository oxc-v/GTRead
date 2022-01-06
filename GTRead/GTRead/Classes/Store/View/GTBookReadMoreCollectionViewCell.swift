//
//  GTBookReadMoreCollectionViewCell.swift
//  GTRead
//
//  Created by Dev on 2022/1/5.
//

import Foundation
import UIKit

class GTBookReadMoreCollectionViewCell: UICollectionViewCell {
    
    private var shadowImgView: GTShadowImageView!
    
    var imgView: UIImageView!
    var titleLab: UILabel!
    var authorLab: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        shadowImgView = GTShadowImageView(opacity: 0.25)
        imgView = shadowImgView.imgView
        shadowImgView.imgView.contentMode = .scaleAspectFill
        shadowImgView.imgView.layer.cornerRadius = 5
        shadowImgView.imgView.clipsToBounds = true
        self.contentView.addSubview(shadowImgView)
        shadowImgView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(-50)
            make.top.equalToSuperview()
        }
        
        titleLab = UILabel()
        titleLab.font = UIFont.boldSystemFont(ofSize: 13)
        titleLab.textAlignment = .center
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(20)
            make.top.equalTo(shadowImgView.snp.bottom).offset(10)
        }
        
        authorLab = UILabel()
        authorLab.font = UIFont.systemFont(ofSize: 12)
        authorLab.textAlignment = .center
        authorLab.textColor = .lightGray
        self.contentView.addSubview(authorLab)
        authorLab.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(20)
            make.top.equalTo(titleLab.snp.bottom)
        }
    }
}
